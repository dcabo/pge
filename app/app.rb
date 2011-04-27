require "rubygems"
require "bundler/setup"

require 'sinatra/base'
require 'haml'

require 'app/model'

class StateBudgetApp < Sinatra::Base
  
  # Enable serving of static files
  set :static, true
  set :public, 'public'
  
  get '/' do
    haml :index
  end
  
  # FIXME: Social Security missing here, since the parsing doesn't generate a section-level heading
  # FIXME: The consolidation relies on the section/entities/programme ids remaining constant across the years!!
  get '/by_section' do
    @sections, @years = Expense.section_headings.consolidate_by_year_on &:description
    
    #  This gets complicated, but is needed given the structure of the incoming data.
    # State sections and entities are displayed together in one budget page, and a total is given
    # for the section (~ 'Ministerio'). But there are also non-state agencies that depend
    # organically from that section; the budget for these agencies is not included in those
    # totals, since they're listed separately, so we need to recalculate them here.
    #
    #  Initially we added up all the entities' subtotals, but that counted the internal transfers
    # twice (the transfer payment in the parent, plus the actual expense in the child). So 
    # now we calculate the section totals adding upwards from the programme level, 
    # ignoring the 'internal transfers' programme.
    #
    #  The results should match the table in budget pages like N_10_E_R_6_2_R_3_1.HTM
    programmes = Expense.programme_headings.not_internal_transfer
    bottom_up_totals, = programmes.consolidate_by_year_on &:section
    @sections.each_value do |s|
      s[:expenses].each_key {|year| s[:expenses][year] = bottom_up_totals[s[:section_id]][:expenses][year] }
    end
    
    @totals = calculate_total_expenses(@sections.values, @years)
    add_deltas(@sections.values, @years)
    haml :by_section
  end
  
  get '/section/:section' do
    @section = Expense.section(params[:section]).section_headings.first

    all_entities = Expense.section(params[:section]).entity_headings
    @entities, @years = all_entities.consolidate_by_year_on &:description

    #  See comment above on recalculating subtotals to avoid double accounting.
    # TODO: A better data model would help here, instead of working off the original data all the time.
    programmes = Expense.section(params[:section]).programme_headings.not_internal_transfer
    bottom_up_totals, = programmes.consolidate_by_year_on &:entity_id
    @entities.each_value do |e|
      e[:expenses].each_key {|year| e[:expenses][year] = bottom_up_totals[e[:entity_id]][:expenses][year] if bottom_up_totals[e[:entity_id]]}
    end
        
    @totals = calculate_total_expenses(@entities.values, @years)
    add_deltas(@entities.values, @years)
    haml :section
  end
  
  get '/section/:section/entity/:entity' do
    @section = Expense.section(params[:section]).section_headings.first
    @entity = Expense.entity(params[:section], params[:entity]).entity_headings.first
    
    all_programmes = Expense.entity(params[:section], params[:entity]).programme_headings
    @programmes, @years = all_programmes.consolidate_by_year_on &:description
    
    # Note that we don't count internal transfers on the totals!
    @totals = calculate_total_expenses(@programmes.values.find_all{|p| !p[:is_internal_transfer]}, @years)
    add_deltas(@programmes.values, @years)
    haml :entity
  end
  
  get '/section/:section/entity/:entity/programme/:programme' do
    @section = Expense.section(params[:section]).section_headings.first
    @entity = Expense.entity(params[:section], params[:entity]).entity_headings.first
    @programme_name = Expense.entity(params[:section], params[:entity]).programme(params[:programme]).programme_headings.first.description
    
    all_expenses = Expense.entity(params[:section], params[:entity]).programme(params[:programme]).expenses
    @expenses, @years = all_expenses.consolidate_by_year_on {|e| "#{e.concept} #{e.description}"}
    
    @totals = calculate_total_expenses(@expenses.values.select{|e| e[:concept].length==1}, @years)
    add_deltas(@expenses.values, @years)    
    haml :programme
  end
  
  # Note that a program can be split across many entities so, for a particular programme, the total budget
  # is the result of adding up the budgets of all the entities assigned to it.
  # We consolidate on programme ID (123X), ignoring the slight modifications on descriptions
  # that happen across the years. Originally I cautiously used the full description to match,
  # but now it seems more reasonable to rely on ID alone.
  # TODO: With proper data model, we could have all names across years available on views
  get '/by_programme' do
    @programmes, @years = Expense.programme_headings.consolidate_by_year_on &:programme
    
    # Note that we don't count internal transfers on the totals!
    @totals = calculate_total_expenses(@programmes.values.find_all{|p| !p[:is_internal_transfer]}, @years)
    add_deltas(@programmes.values, @years)
    haml :by_programme
  end
  
  # TODO: Do we want to show also the expenses split per entity?
  get '/programme/:programme' do
    # Pick all headings for given programme, which can be managed by a number of entities
    programme_headings = Expense.programme_headings.programme(params[:programme])
    
    # Retrieve the managing entities information. The assignment can happen across all years
    # or just one, and the entity name may actually change, so we retrieve the details for all 
    # assignments and all years...
    @programme_breakdown = []
    programme_headings.each do |p| 
      @programme_breakdown << {
        :section => p.section,
        :entity => p.entity_id,
        :programme => p.programme,
        # TODO: Ugly to do so many queries, but given current (poor) data model...
        :description => Expense.entity(p.section, p.entity_id).entity_headings.first(:year => p.year).description
      }
    end
    @programme_breakdown.uniq!   # ...and then de-duplicate 
    
    # The programme description should be the same across all managing entities, so just pick one
    @programme_name = programme_headings.first.description
    
    all_expenses = Expense.programme(params[:programme]).expenses
    # Note that for the same 'economic concept code' we may have more than one description *sigh* 
    # across programme assignments, and the same description can be given to entries in different
    # categories with different codes *sigh again*. In order not to lose information, we group by 
    # concept _and_ description
    @expenses, @years = all_expenses.consolidate_by_year_on {|e| "#{e.concept} #{e.description}"}
    
    # When calculating programme total expenses, we count only the top level, or we'd count twice
    @totals = calculate_total_expenses(@expenses.values.select{|e| e[:concept].length==1}, @years)
    add_deltas(@expenses.values, @years)
    haml :programme
  end


  private
  
  def calculate_delta(a, b)
    return "%.2f" % (100.0 * (b.to_f / a.to_f - 1.0)) unless a.nil? or b.nil? or a==0
  end
  
  # Given a list of items, calculate total expense amounts per year
  def calculate_total_expenses(items, years)
    totals = items.inject({}) do |sum, s|
      s[:expenses].each_key {|year| sum[year] = (sum[year]||0) + (s[:expenses][year]||0) }
      sum
    end
    totals[:delta] = calculate_delta(totals[years[-2]], totals[years.last])
    totals
  end
    
  # Given a list of items, add previous-to-last-year deltas
  # TODO: Better on a yearly basis? Feels like a hack now
  def add_deltas(items, years)
    items.each do |s|
      s[:delta] = calculate_delta(s[:expenses][years[-2]], s[:expenses][years.last])
    end
  end
end

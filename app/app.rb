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
  
  # FIXME: The consolidation relies on the section/entities/programme ids remaining constant across the years!!
  get '/by_section' do
    @sections, @years = Expense.section_headings.consolidate_by_year_on &:description
    
    # This gets complicated, but is needed given the structure of the incoming data.
    # State sections and entities are displayed together in one page, and a total is given
    # for the section (~ 'Ministerio'). But there are also non-state agencies that depend
    # organically from that section; the budget for these agencies is not included in the 
    # total, since they're listed separately, so we recalculate them here.
    # (Consecuence of having such a poor data model right now.)
    bottom_up_totals, = Expense.entity_headings.consolidate_by_year_on &:section
    @sections.each_value do |s|
      s[:expenses].each_key {|year| s[:expenses][year] = bottom_up_totals[s[:section_id]][:expenses][year] }
    end
    
    @totals = calculate_stats(@sections.values, @years)
    haml :by_section
  end
  
  get '/section/:section' do
    @section = Expense.section(params[:section]).section_headings.first

    all_entities = Expense.section(params[:section]).entity_headings
    @entities, @years = all_entities.consolidate_by_year_on &:description
    @totals = calculate_stats(@entities.values, @years)
    haml :section
  end
  
  get '/section/:section/entity/:entity' do
    @section = Expense.section(params[:section]).section_headings.first
    @entity = Expense.entity(params[:section], params[:entity]).entity_headings.first
    @programmes = Expense.entity(params[:section], params[:entity]).programme_headings
    haml :entity
  end
  
  get '/section/:section/entity/:entity/programme/:programme' do
    @section = Expense.section(params[:section]).section_headings.first
    @entity = Expense.entity(params[:section], params[:entity]).entity_headings.first
    @programme = Expense.entity(params[:section], params[:entity]).programme(params[:programme]).programme_headings.first
    @expenses = Expense.entity(params[:section], params[:entity]).programme(params[:programme]).expenses
    haml :programme
  end
  
  # Note that a program can be split across many entities so, for a particular programme, the total budget
  # is the result of adding up the budgets of all the entities assigned to it.
  get '/by_programme' do
    @programmes, @years = Expense.programme_headings.consolidate_by_year_on &:description
    @totals = calculate_stats(@programmes.values, @years)
    haml :by_programme
  end
  
  get '/programme/:programme' do
    @programmes = Expense.programme_headings.programme(params[:programme])
    @total_amount = @programmes.inject(0) {|sum,p| sum+p.amount}
    
    # Since a program can be split across many entities, we need to consolidate the expense list and add up the amounts
    # TODO: Do we want to show also the expenses split per entity?
    @expenses = {}
    Expense.programme(params[:programme]).expenses.each do |e|
      # Note that for the same 'economic concept code' we may have more than one description *sigh* so,
      # in order not to lose information, we group by concept _and_ description
      key = e.concept+e.description
      
      if (previous=@expenses[key]).nil? 
        @expenses[key] = e
      else
        previous.amount += e.amount
      end
    end
    @expenses = @expenses.values.sort {|a,b| a.concept <=> b.concept }
    haml :programme
  end


  private
  
  def calculate_delta(a, b)
    return "%.2f" % (100.0 * (b.to_f / a.to_f - 1.0)) unless a.nil? or b.nil?
  end
  
  # Given a list of items, calculate total amounts per year and add beginning-to-end deltas
  def calculate_stats(items, years)
    # Calculate total amounts
    totals = items.inject({}) do |sum, s|
      s[:expenses].each_key {|year| sum[year] = (sum[year]||0) + (s[:expenses][year]||0) }
      sum
    end
    
    # Calculate delta from beginning to end
    # TODO: Better on a yearly basis?
    totals[:delta] = calculate_delta(totals[years.first], totals[years.last])
    items.each do |s|
      s[:delta] = calculate_delta(s[:expenses][years.first], s[:expenses][years.last])
    end
    totals
  end
end

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

  get '/by_section' do
    all_sections = Expense.section_headings
    @years = all_sections.map{|s| s.year}.uniq
    @sections = all_sections.consolidate_by_year_on &:description
    haml :by_section
  end
  
  get '/section/:section' do
    @section = Expense.section(params[:section]).section_headings.first
    @entities = Expense.section(params[:section]).entity_headings
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
  
  get '/by_programme' do
    # Since a program can be split across many entities, we need to consolidate the list and add up the amounts.
    # Surprisingly, there doesn't seem to be a way to do this in DataMapper
    # TODO: Could be done through direct SQL, is it worth it?
    @programmes = {}
    Expense.programme_headings.each do |p|
      if (previous=@programmes[p.programme]).nil? 
        @programmes[p.programme] = p 
      else
        previous.amount += p.amount
      end
    end
    @programmes = @programmes.values.sort {|a,b| a.programme <=> b.programme }
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
end

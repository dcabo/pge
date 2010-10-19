require "rubygems"
require "bundler/setup"

require 'sinatra/base'
require 'haml'

require 'app/model'

class StateBudgetApp < Sinatra::Base
  get '/' do
    @sections = Expense.all(:entity_id => '')
    haml :index
  end

  get '/by_section' do
    @sections = Expense.all(:entity_id => '', :entity_type => '1')  # TODO: Remove constant!
    haml :by_section
  end
  
  get '/section/:section' do
    @section = Expense.all(:section => params[:section], :entity_id => '', :entity_type => '1').first
    @entities = Expense.all(:section => params[:section], :entity_id.not => '', :programme => '')
    haml :section
  end
  
  # TODO: Move all this logic to model
  get '/section/:section/entity/:entity' do
    @section = Expense.all(:section => params[:section], :entity_id => '').first
    @entity = Expense.all(:section => params[:section], :entity_id => params[:entity], :programme => '').first
    @programmes = Expense.all(:section => params[:section], :entity_id => params[:entity], :programme.not => '', :concept => '')
    haml :entity
  end
  
  get '/section/:section/entity/:entity/programme/:programme' do
    @section = Expense.all(:section => params[:section], :entity_id => '').first
    @entity = Expense.all(:section => params[:section], :entity_id => params[:entity], :programme => '').first
    @programme = Expense.all(:section => params[:section], :entity_id => params[:entity], :programme => params[:programme], :concept => '').first
    @expenses = Expense.all(:section => params[:section], :entity_id => params[:entity], :programme => params[:programme], :concept.not => '')
    haml :programme
  end
  
  get '/by_programme' do
    # Since a program can be split across many entities, we need to consolidate the list and add up the amounts.
    # Surprisingly, there doesn't seem to be a way to do this in DataMapper
    @programmes = {}
    Expense.all(:programme.not => '', :concept => '').each do |p|
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
    @programmes = Expense.all(:programme => params[:programme], :concept => '')
    @total_amount = @programmes.inject(0) {|sum,p| sum+p.amount}
    
    # Since a program can be split across many entities, we need to consolidate the expense list and add up the amounts
    # TODO: Do we want to show also the expenses split per entity?
    @expenses = {}
    Expense.all(:programme => params[:programme], :concept.not => '').each do |e|
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

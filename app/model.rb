require "rubygems"
require "bundler/setup"
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Expense
  include DataMapper::Resource  
  
  property :id,           String, :length => 20, :key => true
  property :year,         String, :length => 5
  property :section,      String, :length => 2
  property :entity_type,  String, :length => 1
  property :entity_id,    String, :length => 3
  property :programme,    String, :length => 4
  property :concept,      String, :length => 5
  property :description,  String, :length => 500
  property :amount,       Decimal
  
  def internal_transfer?
    programme == '000X'
  end
  
  # Given an expense concept, return the parent concept it belongs to; or nil if none.
  # This is calculated using purely string manipulation (removing one or two characters
  # from the end of the concept), relying on knowledge from the budget structure.
  # Example "120" (Retribuciones básicas) returns "12" (Funcionarios).
  def parent_concept
    case concept.length
    when 2,3
      concept[0..concept.length-2]
    when 5
      concept[0..2] 
    end
  end
  
  # Convenience scope methods
  def self.section(section)
    all(:section => section)
  end

  def self.entity(section, entity)
    section(section).all(:entity_id => entity)
  end

  def self.programme(programme)
    all(:programme => programme)
  end
  
  def self.not_internal_transfer
    all(:programme.not => '000X')
  end
  
    
  # Top level section headings are the ones not belonging to any entity (2nd level)
  def self.section_headings
    all(:entity_id => '')
  end

  # Entity level headings are the ones not belonging to a particular programme
  def self.entity_headings
    all(:entity_id.not => '', :programme => '')
  end

  # Programme level headings are the ones not belonging to a particular expense category
  def self.programme_headings
    all(:entity_id.not => '', :programme.not => '', :concept => '')
  end
  
  # ...and the rest are expenses
  def self.expenses
    all(:concept.not => '')
  end 
end


# We add a convenience method to the DataMapper Collection class in order to 
# consolidate the results as we want them. It takes a block method to use as the 
# key to group by. The expenses for two items with the same key are added together.
# The returned list of years is sorted.
class DataMapper::Collection 
  
  # TODO: A bit of a hack, really, putting it inside the DataMapper class. worth it?
  def consolidate_by_year_on
    aggregates = {}
    years = Set.new()
    self.each {|i|
      key = yield(i)
      if (aggregate = aggregates[key]).nil?
        aggregate = {:expenses => {}}
        aggregate[:section_id] = i.section
        aggregate[:entity_id] = i.entity_id
        aggregate[:programme] = i.programme
        aggregate[:concept] = i.concept
        aggregate[:parent_concept] = i.parent_concept
        aggregate[:description] = i.description
        aggregate[:is_internal_transfer] = i.internal_transfer? # TODO: Smells! Create MultiYearExpense class?
      end
      aggregate[:expenses][i.year] = i.amount.to_i + (aggregate[:expenses][i.year]||0)
      aggregates[key] = aggregate
      years.add(i.year)
    }
    return aggregates, years.to_a.sort
  end
end

DataMapper.auto_upgrade!
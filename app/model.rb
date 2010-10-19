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

DataMapper.auto_upgrade!
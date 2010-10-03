require "rubygems"
require "bundler/setup"
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Expense
  include DataMapper::Resource  
  
  property :id,           String, :length => 20, :key => true
  property :section,      String, :length => 2
  property :entity_type,  String, :length => 1
  property :entity_id,    String, :length => 3
  property :programme,    String, :length => 4
  property :concept,      String, :length => 5
  property :description,  String, :length => 500
  property :amount,       Decimal
end

DataMapper.auto_upgrade!
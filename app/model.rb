require "rubygems"
require "bundler/setup"
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Expense
  include DataMapper::Resource  
  
  property :id,           String, :key => true
  property :section,      String
  property :entity_type,  String
  property :entity_id,    String
  property :programme,    String
  property :concept,      String
  property :description,  String
  property :amount,       Decimal
end

DataMapper.auto_upgrade!
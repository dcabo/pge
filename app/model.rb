require "rubygems"
require "bundler/setup"
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Expense
  include DataMapper::Resource  
  
  property :id,           String, :key => true
  property :section,      Integer
  property :entity_type,  Integer
  property :entity_id,    Integer
  property :programme,    String
  property :concept,      String
  property :description,  String
  property :amount,       Decimal
end

DataMapper.auto_upgrade!
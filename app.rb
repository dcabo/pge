require "rubygems"
require "bundler/setup"

require 'sinatra/base'

class StateBudgetApp < Sinatra::Base  
  get '/' do
    "Hello world, it's #{Time.now} at the server!"
  end
end

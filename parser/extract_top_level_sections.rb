#!/usr/bin/ruby

require 'budget'
require 'economic_breakdown'

# TODO: Missing Social Security here
puts 'Id, Nombre'
Budget.new(ARGV[0]).economic_breakdowns.each do |bkdown| 
  puts "#{bkdown.section},#{bkdown.name}" if bkdown.is_state_entity
end


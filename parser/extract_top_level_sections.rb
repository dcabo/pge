#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

puts 'Id, Nombre'
Budget.new().economic_breakdowns.each do |bkdown| 
  puts "#{bkdown.section},#{bkdown.name}" if bkdown.is_state_entity
end


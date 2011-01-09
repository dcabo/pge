#!/usr/bin/ruby

require 'budget'
require 'entity_breakdown'

# TODO: Missing Social Security here
puts 'Id,Sección,Tipo,Organismo'
Budget.new(ARGV[0]).entity_breakdowns.each do |bkdown|
  bkdown.children.each do |child|
    key = "#{bkdown.section}.#{bkdown.entity_type}.#{child[:id]}"
    puts "#{key},#{bkdown.section},#{bkdown.entity_type},#{child[:name]}"
  end
end



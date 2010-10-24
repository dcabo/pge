#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

puts 'Id,Sección,Tipo,Organismo'
Budget.new().economic_breakdowns.each do |bkdown|
  bkdown.children.each do |child|
    key = "#{bkdown.section}.#{bkdown.entity_type}.#{child[:id]}"
    puts "#{key},#{bkdown.section},#{bkdown.entity_type},#{child[:name]}"
  end
end



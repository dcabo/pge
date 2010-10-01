#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

puts 'Id, Nombre'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    section_id = $2
    puts "#{section_id},#{EconomicBreakdown.new(filename).name}"
  end
}



#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

puts 'Id, Nombre'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    bkdown = EconomicBreakdown.new(filename)
    puts "#{bkdown.section},#{bkdown.name}"
  end
}



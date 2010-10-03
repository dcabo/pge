#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

puts 'Id,Sección,Tipo,Organismo'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if (  filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN or
        filename =~ NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN )

    bkdown = EconomicBreakdown.new(filename)
    bkdown.children.each {|child|
      key = "#{bkdown.section}.#{bkdown.entity_type}.#{child[:id]}"
      puts "#{key},#{bkdown.section},#{bkdown.entity_type},#{child[:name]}"
    }
  end
}



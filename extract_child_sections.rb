#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

puts 'Id,Sección,Tipo,Organismo'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    entity_type = $1 # We know it's 1 though
    section_id = $2
    
    EconomicBreakdown.new(filename).rows.each {|row|
      unless ( row[:service].empty? )
        entity_id = "#{section_id}.#{entity_type}.#{row[:service]}"
        puts "#{entity_id},#{section_id},#{entity_type},#{row[:description]}"
      end
    }
    
  elsif ( filename =~ NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    entity_type = $1
    section_id = $2
    entity_id = "#{section_id}.#{entity_type}.#{$3}"
    
    name = EconomicBreakdown.new(filename).name
    puts "#{entity_id},#{section_id},#{entity_type},#{name}"
  end
}



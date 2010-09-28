#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'filenames'

def extract_entity_name(doc)
  # Note: the section name may include accented characters, so '\w' doesn't work
  doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
  $1
end

def extract_service_names(doc)
  # Get data rows
  rows = doc.css('table.S0ESTILO8 tr')
  rows.shift # Skip header  
  
  # Search for 'service' headers in table
  subsections = []
  rows.each do |row|
    columns = row.css('td')
    service_id = columns[0].text.strip
    description = columns[3].text.strip
    subsections << {:id=>service_id, :name=>description} if ( service_id != '' )
  end
  subsections
end

puts 'Id,Sección,Tipo,Organismo'
Dir["master/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ ESTATE_ENTITY_EXPENSES_ECON_BKDOWN )
    entity_type = $1 # We know it's 1 though
    section_id = $2
    doc = Nokogiri::HTML(open(filename))
    extract_service_names(doc).each {|subsection|
      entity_id = "#{section_id}.#{entity_type}.#{subsection[:id]}"
      puts "#{entity_id},#{section_id},#{entity_type},#{subsection[:name]}"
    }
    
  elsif ( filename =~ NON_ESTATE_ENTITY_EXPENSES_ECON_BKDOWN )
    entity_type = $1
    section_id = $2
    entity_id = "#{section_id}.#{entity_type}.#{$3}"
    doc = Nokogiri::HTML(open(filename))
    puts "#{entity_id},#{section_id},#{entity_type},#{extract_entity_name(doc)}"
  end
}



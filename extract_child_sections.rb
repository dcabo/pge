#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'filenames'

def extract_entity_name(doc)
  # Note: the section name may include accented characters, so '\w' doesn't work
  doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
  $1.capitalize
end

puts 'Id,Sección,Tipo,Organismo'
Dir["master/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ NON_ESTATE_ENTITY_EXPENSES_ECON_BKDOWN )
    entity_type = $1
    section_id = $2
    entity_id = "#{section_id}.#{entity_type}.#{$3}"
    doc = Nokogiri::HTML(open(filename))
    puts "#{entity_id},#{section_id},#{entity_type},#{extract_entity_name(doc)}"
  end
}



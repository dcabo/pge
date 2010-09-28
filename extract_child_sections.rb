#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

def extract_entity_name(doc)
  # Note: the section name may include accented characters, so '\w' doesn't work
  doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
  $1.capitalize
end

puts 'Id,Sección,Tipo,Organismo'
Dir["master/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ /N_10_E_V_1_10([234])_2_2_2_1(\d\d)_1_2_1(\d\d\d)_1.HTM/ )
    entity_type = $1
    section_id = $2
    entity_id = "#{section_id}.#{entity_type}.#{$3}"
    doc = Nokogiri::HTML(open(filename))
    puts "#{entity_id},#{section_id},#{entity_type},#{extract_entity_name(doc)}"
  end
}



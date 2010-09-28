#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

def extract_section_name(doc)
  # Note: the section name may include accented characters, so '\w' doesn't work
  doc.css('.S0ESTILO2').text.strip =~ /^Sección: \d\d (.+)$/
  return $1
end

puts 'Id, Nombre'
Dir["master/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ /N_10_E_V_1_101_2_2_2_1(\d\d)_1_1_1.HTM/ )
    section_id = $1
    doc = Nokogiri::HTML(open(filename))
    puts "#{section_id},#{extract_section_name(doc)}"
  end
}



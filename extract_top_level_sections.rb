#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'filenames'


def extract_section_name(doc)
  # Note: the section name may include accented characters, so '\w' doesn't work
  doc.css('.S0ESTILO2').text.strip =~ /^Sección: \d\d (.+)$/
  return $1
end

puts 'Id, Nombre'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ ESTATE_ENTITY_EXPENSES_ECON_BKDOWN )
    section_id = $2
    doc = Nokogiri::HTML(open(filename))
    puts "#{section_id},#{extract_section_name(doc)}"
  end
}



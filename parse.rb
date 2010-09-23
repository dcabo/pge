#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open('master/doc/HTM/N_10_E_R_31_124_1_1_1_1144A_2.HTM'))

area = doc.css('.S0ESTILO1').text
year = doc.css('.S0ESTILO2').text.strip
section = doc.css('.S0ESTILO3').first.text
programme = doc.css('.S0ESTILO3').last.text

rows = doc.css('table.S0ESTILO8 tr')
rows.shift # Skip header

puts area
puts year
puts section
puts programme
puts rows.size

rows.each do |row|
  puts row.css('td')[2].text
end
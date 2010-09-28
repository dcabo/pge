#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open('N_10_E_V_1_101_2_2_2_113_1_1_1.HTM'))

area = doc.css('.S0ESTILO1').text
year = doc.css('.S0ESTILO3').last.text
section = doc.css('.S0ESTILO2').text.strip

puts "Ámbito: #{area}"
puts "Año: #{year}"
puts "#{section}"

rows = doc.css('table.S0ESTILO8 tr')
rows.shift # Skip header

rows[0..10].each do |row|
  columns = row.css('td')
  service = columns[0].text.strip
  programme = columns[1].text.strip
  econ_type = columns[2].text.strip
  description = columns[3].text.strip
  subtotal = columns[4].text.strip
  total = columns[5].text.strip

  puts "#{service}|#{programme}|#{econ_type}|#{description}|#{subtotal}|#{total}"
end
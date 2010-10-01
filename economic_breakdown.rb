require 'rubygems'
require 'nokogiri'
require 'open-uri'

class EconomicBreakdown
  def initialize(filename)
    @doc = Nokogiri::HTML(open(filename))
    @is_state_entity = (filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN)
  end
  
  def name
    # Note: the name may include accented characters, so '\w' doesn't work in regex
    @is_state_entity ?
      @doc.css('.S0ESTILO2').text.strip =~ /^Sección: \d\d (.+)$/ :
      @doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
    $1
  end
  
  def rows
    rows = []
    # Iterate through HTML table, skipping header
    @doc.css('table.S0ESTILO8 tr')[1..-1].each do |row|
      columns = row.css('td').map{|td| td.text.strip}
      rows << { :service => columns[0], 
                :programme => columns[1], 
                :expense_concept => columns[2], 
                :description => columns[3],
                :amount => (columns[4] != '') ? columns[4] : columns[5] }
    end
    rows
  end
end
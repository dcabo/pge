require 'rubygems'
require 'nokogiri'
require 'open-uri'

class EconomicBreakdown
  attr_reader :section, :entity, :entity_type, :is_state_entity
  
  def initialize(filename)
    if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
      @is_state_entity = true
      @entity_type = $1   # Always 1 for state entities
      @section = $2
    elsif ( filename =~ NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN )
      @is_state_entity = false
      @entity_type = $1   # Can be 2-4
      @section = $2       # Parent section
      @entity = $3        # Id of the non-state entity
    end
    @doc = Nokogiri::HTML(open(filename))
  end
  
  def name
    # Note: the name may include accented characters, so '\w' doesn't work in regex
    @is_state_entity ?
      @doc.css('.S0ESTILO2').text.strip =~ /^Sección: \d\d (.+)$/ :
      @doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
    $1
  end
  
  def children
    @is_state_entity ?
      rows.map {|row| {:id=>row[:service], :name=>row[:description]} if not row[:service].empty? }.compact :
      [{:id => @entity, :name => name}]
  end
  
  def rows
    # Iterate through HTML table, skipping header
    @doc.css('table.S0ESTILO8 tr')[1..-1].map do |row|
      columns = row.css('td').map{|td| td.text.strip}
      columns.insert(0,'') if !@is_state_entity # They lack the first column, 'service'
      { :service => columns[0], 
        :programme => columns[1], 
        :expense_concept => columns[2], 
        :description => columns[3],
        :amount => (columns[4] != '') ? columns[4] : columns[5] }
    end
  end
end
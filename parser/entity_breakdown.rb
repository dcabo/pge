require 'rubygems'
require 'nokogiri'
require 'open-uri'

# TODO: Split into separate state/non-state classes?
class EntityBreakdown
  attr_reader :year, :section, :entity, :entity_type

  def initialize(filename)
    filename =~ ENTITY_EXPENSES_BKDOWN
    @year = '20'+$1
    @entity_type = $2                       # Always 1 for state entities, 2-4 for non-state
    @section = $3                           # Parent section
    @entity = $5 unless is_state_entity?    # Id of the non-state entity
    @filename = filename
  end
  
  def is_state_entity?
    return @entity_type == '1'
  end
  
  def name
    # Note: the name may include accented characters, so '\w' doesn't work in regex
    if is_state_entity?
      # TODO: check years before 2008
      section_css_class = (year=='2008') ? '.S0ESTILO4' : '.S0ESTILO2'
      doc.css(section_css_class).text.strip =~ /^Sección: \d\d (.+)$/
    else
      doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
    end
    $1
  end
  
  def children
    is_state_entity? ?
      rows.map {|row| {:id=>row[:service], :name=>row[:description]} if not row[:service].empty? }.compact :
      [{:id => @entity, :name => name}]
  end
  
  def rows
    # Iterate through HTML table, skipping header
    rows = doc.css('table.S0ESTILO9 tr')[1..-1]               # 2008 (and earlier?)
    rows = doc.css('table.S0ESTILO8 tr')[1..-1] if rows.nil?  # 2009 onwards
    rows.map do |row|
      columns = row.css('td').map{|td| td.text.strip}
      columns.insert(0,'') unless is_state_entity? # They lack the first column, 'service'
      { :service => columns[0], 
        :programme => columns[1], 
        :expense_concept => columns[2], 
        :description => columns[3],
        :amount => (columns[4] != '') ? columns[4] : columns[5] }
    end
  end
  
  def self.entity_breakdown? (filename)
    filename=~ENTITY_EXPENSES_BKDOWN
  end
  
  private
  
  ENTITY_EXPENSES_BKDOWN =  /N_(\d\d)_[AE]_V_1_10([1234])_2_2_2_1(\d\d)_1_[12]_1((\d\d\d)_1)?.HTM/;

  def doc
    @doc = Nokogiri::HTML(open(@filename)) if @doc.nil?  # Lazy parsing of doc, only when needed
    @doc
  end
end
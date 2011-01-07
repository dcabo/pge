require 'rubygems'
require 'nokogiri'
require 'open-uri'

# TODO: Split into separate state/non-state classes?
class EconomicBreakdown
  attr_reader :year, :section, :entity, :entity_type, :is_state_entity

  def initialize(filename)
    if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
      @is_state_entity = true
    # Need to explicitely match, even if we know it to be true, so the $* below work!
    elsif ( filename =~ NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN )
      @is_state_entity = false
    end
    @year = '20'+$1
    @entity_type = $2                       # Always 1 for state entities, 2-4 for non-state
    @section = $3                           # Parent section
    @entity = $4 unless @is_state_entity    # Id of the non-state entity
    @filename = filename
  end
  
  def name
    # Note: the name may include accented characters, so '\w' doesn't work in regex
    if @is_state_entity
      # TODO: check years before 2008
      section_css_class = (year=='2008') ? '.S0ESTILO4' : '.S0ESTILO2'
      doc.css(section_css_class).text.strip =~ /^Sección: \d\d (.+)$/
    else
      doc.css('.S0ESTILO3').last.text.strip =~ /^Organismo: \d\d\d (.+)$/
    end
    $1
  end
  
  def children
    @is_state_entity ?
      rows.map {|row| {:id=>row[:service], :name=>row[:description]} if not row[:service].empty? }.compact :
      [{:id => @entity, :name => name}]
  end
  
  def rows
    # Iterate through HTML table, skipping header
    rows = doc.css('table.S0ESTILO9 tr')[1..-1]               # 2008 (and earlier?)
    rows = doc.css('table.S0ESTILO8 tr')[1..-1] if rows.nil?  # 2009 onwards
    rows.map do |row|
      columns = row.css('td').map{|td| td.text.strip}
      columns.insert(0,'') if !@is_state_entity # They lack the first column, 'service'
      { :service => columns[0], 
        :programme => columns[1], 
        :expense_concept => columns[2], 
        :description => columns[3],
        :amount => (columns[4] != '') ? columns[4] : columns[5] }
    end
  end
  
  def self.economic_breakdown? (filename)
    filename=~STATE_ENTITY_EXPENSES_ECON_BKDOWN or filename=~ NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN
  end
  
  private
  
  STATE_ENTITY_EXPENSES_ECON_BKDOWN =      /N_(\d\d)_[AE]_V_1_10(1)_2_2_2_1(\d\d)_1_1_1.HTM/;
  NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN =  /N_(\d\d)_[AE]_V_1_10([234])_2_2_2_1(\d\d)_1_2_1(\d\d\d)_1.HTM/;

  def doc
    @doc = Nokogiri::HTML(open(@filename)) if @doc.nil?  # Lazy parsing of doc, only when needed
    @doc
  end
end
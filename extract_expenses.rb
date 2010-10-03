#!/usr/bin/ruby

require 'filenames'
require 'economic_breakdown'

def convert_number(amount)
  amount.delete('.').tr(',','.')
end

puts 'section, service, programme, concept, description, amount'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    next if $2 != '17'
    
    service = ''
    programme = ''
    expense_concept = ''
    bkdown = EconomicBreakdown.new(filename)
    bkdown.rows.each {|row|
      service = row[:service] if not row[:service].empty?
      programme = row[:programme] if not row[:programme].empty?
      expense_concept = row[:expense_concept] if not row[:expense_concept].empty?
      
      # Skip service/programme/chapter headings, we only want the details
      next if row[:amount].empty? or row[:expense_concept].empty?
      
      puts "#{bkdown.section}|#{service}|#{programme}|#{expense_concept}|#{row[:description]}|#{convert_number(row[:amount])}"
    }
  end
}



#!/usr/bin/ruby

# Budget expenses are organized in chapters > articles > concepts > subconcepts. When looking at 
# an expense breakdown, the sum of all the chapters (codes of the form 'n') equals the sum of all 
# articles (codes 'nn') and the sum of all expenses (codes 'nnn'). I.e. the breakdown is exhaustive 
# down to that level. Note however that not all concepts are broken into sub-concepts (codes 'nnnnn'); 
# hence, adding up all the subconcepts will result in a much smaller amount.

require 'filenames'
require 'economic_breakdown'

def convert_number(amount)
  amount.delete('.').tr(',','.')
end

# TODO: Wouldn't mind getting auto-increment UIDs if I could get the import job to do it
def get_uid(section, entity_type, service, programme, expense_concept)
  "#{section}#{entity_type}#{service}#{programme}#{expense_concept}"
end

# Output 'id, section, entity type, service, programme, concept, description, amount'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if (  filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN or
        filename =~ NON_STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    bkdown = EconomicBreakdown.new(filename)

    # State section breakdowns contain many services, while non-state ones apply to only one
    # child entity
    service = bkdown.is_state_entity ? '' : bkdown.entity
    programme = ''
    
    # The total amounts for service/programme/chapter headings is shown when the heading is closed,
    # not opened, so we need to keep track of the open ones.
    # Note: there is an unmatched closing amount, without an opening heading, at the end
    # of the page, containing the amount for the whole section/entity, so we don't start with
    # an empty vector
    uid = get_uid(bkdown.section, bkdown.entity_type, service, programme, '')
    open_headings = ["#{uid}|#{bkdown.section}|#{bkdown.entity_type}|#{service}|#{programme}||#{bkdown.name}"]
    
    bkdown.rows.each {|row|
      next if row[:description].empty?  # Skip empty lines
      
      # Keep track of current service/programme
      if not row[:service].empty?
        service = row[:service] 
        programme = ''
      elsif not row[:programme].empty?
        programme = row[:programme] 
      end
      
      # Print expense
      uid = get_uid(bkdown.section, bkdown.entity_type, service, programme, row[:expense_concept])
      expense_description = "#{uid}|#{bkdown.section}|#{bkdown.entity_type}|#{service}|#{programme}|#{row[:expense_concept]}|#{row[:description]}"
      
      if ( row[:amount].empty? )              # opening heading
        open_headings << expense_description
      elsif ( row[:expense_concept].empty? )  # closing heading
        last_heading = open_headings.pop()
        puts "#{last_heading}|#{convert_number(row[:amount])}" unless last_heading.empty?
      else                                    # standard data row
        puts "#{expense_description}|#{convert_number(row[:amount])}"
      end
    }
  end
}



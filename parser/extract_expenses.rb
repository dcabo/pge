#!/usr/bin/ruby

# Budget expenses are organized in chapters > articles > concepts > subconcepts. When looking at 
# an expense breakdown, the sum of all the chapters (codes of the form 'n') equals the sum of all 
# articles (codes 'nn') and the sum of all expenses (codes 'nnn'). I.e. the breakdown is exhaustive 
# down to that level. Note however that not all concepts are broken into sub-concepts (codes 'nnnnn'); 
# hence, adding up all the subconcepts will result in a much smaller amount.

require 'budget'
require 'entity_breakdown'
require 'programme_breakdown'

def convert_number(amount)
  amount.delete('.').tr(',','.')
end

# TODO: Wouldn't mind getting auto-increment UIDs if I could get the import job to do it
def get_uid(year, section, entity_type, service, programme, expense_concept)
  "#{year}#{section}#{entity_type}#{service}#{programme}#{expense_concept}"
end

# Output 'id, year, section, entity type, service, programme, concept, description, amount'
def extract_expenses(bkdown, open_headings)
  bkdown.expenses.each do |row|
    uid = get_uid(bkdown.year, bkdown.section, bkdown.entity_type, row[:service], row[:programme], row[:expense_concept])
    expense_description = "#{uid}|#{bkdown.year}|#{bkdown.section}|#{bkdown.entity_type}|#{row[:service]}|#{row[:programme]}|#{row[:expense_concept]}|#{row[:description]}"
  
    # The total amounts for service/programme/chapter headings is shown when the heading is closed,
    # not opened, so we need to keep track of the open ones, and print them when closed.
    if ( row[:amount].empty? )              # opening heading
      open_headings << expense_description
    elsif ( row[:expense_concept].empty? )  # closing heading
      last_heading = open_headings.pop()
      puts "#{last_heading}|#{convert_number(row[:amount])}" unless last_heading.nil?
    else                                    # standard data row
      puts "#{expense_description}|#{convert_number(row[:amount])}"
    end
  end
end

def extract_entity_expenses
  Budget.new(ARGV[0]).entity_breakdowns.each do |bkdown|
    # Note: there is an unmatched closing amount, without an opening heading, at the end
    # of the page, containing the amount for the whole section/entity, so we don't start with
    # an empty vector
    service = bkdown.is_state_entity? ? '' : bkdown.entity
    uid = get_uid(bkdown.year, bkdown.section, bkdown.entity_type, service, '', '')
    open_headings = ["#{uid}|#{bkdown.year}|#{bkdown.section}|#{bkdown.entity_type}|#{service}|||#{bkdown.name}"]
  
    extract_expenses(bkdown, open_headings)
  end
end

def extract_programme_expenses
  Budget.new(ARGV[0]).programme_breakdowns.each do |bkdown|  
    # TODO: We don't want to insert into the DB (yet?) a programme subtotal across all entities. 
    #       It would probably break some query (as in counting twice) in the app visualizing 
    #       the data (PGE). A consecuence of the poor current data model, and having data for 
    #       different levels of detail sitting together in the same table. Another vote for
    #       re-doing the data model.
    extract_expenses(bkdown, [])
  end
end

extract_entity_expenses
extract_programme_expenses

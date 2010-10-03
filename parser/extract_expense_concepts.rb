#!/usr/bin/ruby

# The descriptions for chapters and articles ('n' and 'nn' codes) seem to be unique, and are the
# ones listed in the Blue Book. A concept id ('nnn'), however, may have different meanings across
# different sections: for most of the concept codes this is not the case, and they have a unique
# description, which is shown in the Blue Book; but not all of them (see '410' f.ex.). Subconcepts
# are even worse.

# This is a first attempt at investigating this issue.

require 'filenames'
require 'economic_breakdown'

concepts = []

puts 'Concept id, description'
Dir["PGE-ROM/doc/HTM/*.HTM"].each {|filename|
  if ( filename =~ STATE_ENTITY_EXPENSES_ECON_BKDOWN )
    EconomicBreakdown.new(filename).rows.each {|row|
      unless ( row[:expense_concept].empty? )
        concepts << "#{row[:expense_concept]}, #{row[:description]}"
      end
    }
  end
}

puts concepts.uniq.sort



require 'open3'

import 'parser/Rakefile'

def run_sqlite3_commands(commands)
  Open3.popen3("sqlite3 development.db") do |i, o, e, ts|
    commands.each {|c| i.puts c}
    s=o.read
    puts s unless s.empty?
    s=e.read
    puts s unless s.empty?
  end
end

namespace 'expenses' do

  desc "Count entries in DB (filter by year optional)"
  task :count, [:year] do |t, args|
    args.with_defaults(:year => 'year')
    run_sqlite3_commands([
      "select count(*) from expenses where year=#{args.year};",
      ".exit"
    ])
  end
  
  desc "Clear entries in DB (filter by year optional)"
  task :delete, [:year] do |t, args|
    args.with_defaults(:year => 'year')
    run_sqlite3_commands([
      "delete from expenses where year=#{args.year};",
      ".exit"
    ])
  end

  desc "Import expense data into DB for given year"
  task :import, [:year] do |t, args|
    filename = "parser/output/#{args.year}/expenses.csv"
    puts "Importing file #{filename}..."
    run_sqlite3_commands([
      '.mode csv',
      '.separator "|"',
      ".import #{filename} expenses",
      '.exit'
    ])
  end
  
  # Note: Run Rake in silent mode (-s) so output can be redirected into file easily
  desc "Export programme totals from DB, excluding internal transfers (year optional)"
  task :export_programmes, [:year] do |t, args|
    args.with_defaults(:year => 'year')
    run_sqlite3_commands([
      '.mode csv',
      '.separator "|"',
      "select programme, description, sum(amount) from expenses \
       where year=#{args.year} and programme<>'' and concept='' and programme<>'000X' \
       group by programme;",      
      ".exit"
    ])
  end
  
end

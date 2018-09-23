task :environment do
  require_relative "./lib/birthday_calendar"
end

desc "Generate ical files"
task :generate_ical => :environment do
  BirthdayCalendar.generate_all_ical_files("#{__dir__}/docs")
end

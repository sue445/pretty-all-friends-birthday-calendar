require "date"
require "yaml"
require "icalendar"
require "active_support/all"

class BirthdayCalendar
  CONFIG_PATH = "#{__dir__}/../config"

  attr_reader :config

  def initialize(name)
    @config = YAML.load_file("#{CONFIG_PATH}/#{name}.yml")
  end

  # Get birthdays within `from_year` and `to_year`
  # @param from_year [Integer]
  # @param to_year [Integer]
  # @return [Hash<Date, String>] Key: birthday, Value: character name
  def birthdays(from_year:, to_year:)
    date_characters = {}

    config["characters"].each do |character|
      (from_year..to_year).each do |year|
        date = Date.parse("#{year}/#{character["birthday"]}")
        date_characters[date] = character["name"]
      end
    end

    Hash[date_characters.sort]
  end

  # @param date_characters [Hash<Date, String>]
  # @return [String] ical data
  def birthday_ical(date_characters)
    cal = Icalendar::Calendar.new

    cal.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "#{config["title"]}の誕生日")

    date_characters.each do |date, name|
      cal.event do |e|
        e.summary = "#{name}の誕生日"
        e.dtstart = Icalendar::Values::Date.new(date)
      end
    end

    cal.publish
    cal.to_ical
  end
end

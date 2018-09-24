require "date"
require "yaml"
require "icalendar"
require "active_support/all"

class BirthdayCalendar
  CONFIG_PATH = "#{__dir__}/../config"

  attr_reader :config, :name

  def initialize(name)
    @config = YAML.load_file("#{CONFIG_PATH}/#{name}.yml").deep_symbolize_keys
    @name = name
  end

  # @param dist_dir [String]
  def self.generate_all_ical_files(dist_dir)
    config_names = Dir["#{CONFIG_PATH}/*.yml"].map { |path| File.basename(path, ".yml") }
    config_names.sort.each do |name|
      calendar = BirthdayCalendar.new(name)
      calendar.generate_ical_file(dist_dir)
    end
  end

  # @param dist_dir [String]
  # @param name [String]
  def self.generate_ical_file(dist_dir, name)
    calendar = BirthdayCalendar.new(name)
    calendar.generate_ical_file(dist_dir)
  end

  # @param dist_dir [String]
  def generate_ical_file(dist_dir)
    from_year = Date.today.year
    date_characters = birthdays(from_year: from_year, to_year: from_year + 2)
    ical = birthday_ical(date_characters)

    File.open("#{dist_dir}/#{name}.ics", "wb") do |f|
      f.write(ical)
    end
  end

  # Get birthdays within `from_year` and `to_year`
  # @param from_year [Integer]
  # @param to_year [Integer]
  # @return [Hash<Date, Hash<Symbol, String>>] Key: birthday, Value: character data
  def birthdays(from_year:, to_year:)
    date_characters = {}

    config[:characters].each do |character|
      (from_year..to_year).each do |year|
        date = Date.parse("#{year}/#{character[:birthday]}")
        date_characters[date] = character
      rescue ArgumentError => e
        # NOTE: うるう年以外で2/29をparseしようとするとエラーになるので握りつぶす
        raise unless e.message == "invalid date"
      end
    end

    Hash[date_characters.sort]
  end

  # @param date_characters [Hash<Date, Hash<Symbol, String>>]
  # @return [String] ical data
  def birthday_ical(date_characters)
    cal = Icalendar::Calendar.new

    cal.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "#{config[:title]}の誕生日")

    date_characters.each do |date, character|
      cal.event do |e|
        e.summary = "#{character[:name]}の誕生日"
        e.dtstart = Icalendar::Values::Date.new(date)
      end
    end

    cal.publish
    cal.to_ical
  end
end

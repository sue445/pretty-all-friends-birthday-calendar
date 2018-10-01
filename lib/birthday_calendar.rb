require "date"
require "yaml"
require "digest/sha2"
require "icalendar"
require "active_support/all"
require "hashie/mash"

class CalendarRow
  # @!attribute date
  #   @return [Date]
  attr_accessor :date

  # @!attribute character
  #   @return [Hashie::Mash]
  attr_accessor :chara

  def initialize(date: nil, chara: nil)
    self.date = date
    self.chara = chara
  end

  def ==(other)
    return false unless other
    return false unless other.is_a? CalendarRow

    date == other.date && chara == other.chara
  end
end

class BirthdayCalendar
  CONFIG_PATH = "#{__dir__}/../config"

  attr_reader :config_hash, :config_name

  def initialize(config_name)
    @config_hash = Hashie::Mash.new(YAML.load_file("#{CONFIG_PATH}/#{config_name}.yml"))
    @config_name = config_name
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
    calendar_rows = birthdays(from_year: from_year, to_year: from_year + 2)
    ical = birthday_ical(calendar_rows)

    File.open("#{dist_dir}/#{config_name}.ics", "wb") do |f|
      f.write(ical)
    end
  end

  # Get birthdays within `from_year` and `to_year`
  # @param from_year [Integer]
  # @param to_year [Integer]
  # @return [Array<CalendarRow>]
  def birthdays(from_year:, to_year:)
    rows = []

    config_hash.characters.each do |chara|
      (from_year..to_year).each do |year|
        date = Date.parse("#{year}/#{chara.birthday}")
        rows << CalendarRow.new(date: date, chara: chara)
      rescue ArgumentError => e
        # NOTE: うるう年以外で2/29をparseしようとするとエラーになるので握りつぶす
        raise unless e.message == "invalid date"
      end
    end

    rows.sort_by { |row| [row.date, row.chara.name] }
  end

  # @param calendar_rows [Array<CalendarRow>]
  # @return [String] ical data
  def birthday_ical(calendar_rows)
    cal = Icalendar::Calendar.new

    cal.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "#{config_hash.title}の誕生日")

    calendar_rows.each do |calendar_row|
      date = calendar_row.date
      chara = calendar_row.chara

      cal.event do |e|
        e.dtstamp = nil
        e.uid = generate_id(name: chara.name, date: date)

        e.summary = "#{chara.name}の誕生日"
        e.dtstart = Icalendar::Values::Date.new(date)

        e.description = chara.description unless chara.description.blank?
      end
    end

    cal.publish
    cal.to_ical
  end

  private

  def generate_id(name:, date:)
    Digest::SHA256.hexdigest([config_name, name, date].join)
  end
end

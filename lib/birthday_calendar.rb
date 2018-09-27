require "date"
require "yaml"
require "icalendar"
require "active_support/all"

class CalendarRow
  # @!attribute date
  #   @return [Date]
  attr_accessor :date

  # @!attribute character
  #   @return [Hash<Symbol, String>]
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
    calendar_rows = birthdays(from_year: from_year, to_year: from_year + 2)
    ical = birthday_ical(calendar_rows)

    File.open("#{dist_dir}/#{name}.ics", "wb") do |f|
      f.write(ical)
    end
  end

  # Get birthdays within `from_year` and `to_year`
  # @param from_year [Integer]
  # @param to_year [Integer]
  # @return [Array<CalendarRow>]
  def birthdays(from_year:, to_year:)
    rows = []

    config[:characters].each do |character|
      (from_year..to_year).each do |year|
        date = Date.parse("#{year}/#{character[:birthday]}")
        rows << CalendarRow.new(date: date, chara: character)
      rescue ArgumentError => e
        # NOTE: うるう年以外で2/29をparseしようとするとエラーになるので握りつぶす
        raise unless e.message == "invalid date"
      end
    end

    rows.sort_by { |row| [row.date, row.chara[:name]] }
  end

  # @param calendar_rows [Array<CalendarRow>]
  # @return [String] ical data
  def birthday_ical(calendar_rows)
    cal = Icalendar::Calendar.new

    cal.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "#{config[:title]}の誕生日")

    calendar_rows.each do |calendar_row|
      date = calendar_row.date
      chara = calendar_row.chara

      cal.event do |e|
        e.summary = "#{chara[:name]}の誕生日"
        e.dtstart = Icalendar::Values::Date.new(date)

        if chara[:description] && !chara[:description].empty?
          e.description = chara[:description]
        end
      end
    end

    cal.publish
    cal.to_ical
  end
end

require "date"
require "yaml"

class BirthdayCalendar
  CONFIG_PATH = "#{__dir__}/../config"

  def initialize(name)
    @config = YAML.load_file("#{CONFIG_PATH}/#{name}.yml")
  end

  # Get birthdays within `from_year` and `to_year`
  # @param from_year [Integer]
  # @param to_year [Integer]
  # @return [Hash<Date, String>] Key: birthday, Value: character name
  def birthdays(from_year, to_year)
    date_characters = {}

    characters.each do |character|
      (from_year..to_year).each do |year|
        date = Date.parse("#{year}/#{character["birthday"]}")
        date_characters[date] = character["name"]
      end
    end

    Hash[date_characters.sort]
  end

  # @return [Array<Hash>]
  def characters
    @config["characters"]
  end
end

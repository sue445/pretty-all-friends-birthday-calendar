RSpec.describe BirthdayCalendar do
  let(:calendar) { BirthdayCalendar.new("prichan") }

  describe ".generate_all_ical_files" do
    include_context "uses temp dir"

    subject do
      BirthdayCalendar.generate_all_ical_files(temp_dir)

      temp_dir_path.join("prichan.ics")
    end

    let(:ical_file) { temp_dir_path.join("prichan.ics") }

    it { should be_exist }
  end

  describe "#generate_ical_file" do
    include_context "uses temp dir"

    subject do
      calendar.generate_ical_file(temp_dir)

      temp_dir_path.join("prichan.ics")
    end

    let(:ical_file) { temp_dir_path.join("prichan.ics") }

    it { should be_exist }
  end

  describe "#birthdays" do
    subject { calendar.birthdays(from_year: from_year, to_year: to_year) }

    let(:from_year) { 2018 }
    let(:to_year)   { 2020 }

    it { should include(Date.new(2018, 7, 12) => { name: "桃山みらい", birthday: "7/12" }) }
    it { should include(Date.new(2018, 9, 9) => { name: "萌黄えも", birthday: "9/9"}) }
    it { should include(Date.new(2020, 7, 12) => { name: "桃山みらい", birthday: "7/12"}) }
  end

  describe "#birthday_ical" do
    subject { calendar.birthday_ical(date_characters) }

    let(:date_characters) do
      {
        Date.new(2018, 7, 12) => { name: "桃山みらい", birthday: "7/12" },
        Date.new(2018, 9, 9)  => { name: "萌黄えも", birthday: "9/9"},
      }
    end

    it { should include "X-WR-CALNAME;VALUE=TEXT:キラッとプリ☆チャンの誕生日" }
    it { should include "DTSTART;VALUE=DATE:20180712" }
    it { should include "SUMMARY:桃山みらいの誕生日" }
    it { should include "DTSTART;VALUE=DATE:20180909" }
    it { should include "SUMMARY:萌黄えもの誕生日" }
  end
end

RSpec.describe BirthdayCalendar do
  let(:calendar) { BirthdayCalendar.new("prichan") }

  let(:mirai) { {name: "桃山みらい", birthday: "7/12", description: "デコレーションケーキの日" } }
  let(:emo)   { {name: "萌黄えも", birthday: "9/9", description: "ポップコーンの日" } }

  describe ".generate_all_ical_files" do
    include_context "uses temp dir"

    subject do
      BirthdayCalendar.generate_all_ical_files(temp_dir)

      temp_dir_path.join("prichan.ics")
    end

    it { should be_exist }
  end

  describe "#generate_ical_file" do
    include_context "uses temp dir"

    subject do
      calendar.generate_ical_file(temp_dir)

      temp_dir_path.join("prichan.ics")
    end

    it { should be_exist }
  end

  describe "#birthdays" do
    subject { calendar.birthdays(from_year: from_year, to_year: to_year) }

    let(:from_year) { 2018 }
    let(:to_year)   { 2020 }

    it { should include(CalendarRow.new(date: Date.new(2018, 7, 12), chara: mirai)) }
    it { should include(CalendarRow.new(date: Date.new(2018, 9, 9),  chara: emo)) }
    it { should include(CalendarRow.new(date: Date.new(2018, 7, 12), chara: mirai)) }
  end

  describe "#birthday_ical" do
    subject { calendar.birthday_ical(calendar_rows) }

    let(:calendar_rows) do
      [
        CalendarRow.new(date: Date.new(2018, 7, 12), chara: mirai),
        CalendarRow.new(date: Date.new(2018, 9, 9),  chara: emo),
      ]
    end

    it { should include "X-WR-CALNAME;VALUE=TEXT:キラッとプリ☆チャンの誕生日" }
    it { should include "DTSTART;VALUE=DATE:20180712" }
    it { should include "SUMMARY:桃山みらいの誕生日" }
    it { should include "DESCRIPTION:デコレーションケーキの日" }
    it { should include "DTSTART;VALUE=DATE:20180909" }
    it { should include "SUMMARY:萌黄えもの誕生日" }
    it { should include "DESCRIPTION:ポップコーンの日" }
  end
end

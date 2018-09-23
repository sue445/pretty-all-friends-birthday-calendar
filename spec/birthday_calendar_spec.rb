RSpec.describe BirthdayCalendar do
  let(:calendar) { BirthdayCalendar.new("prichan") }

  describe "#birthdays" do
    subject { calendar.birthdays(from_year, to_year) }

    let(:from_year) { 2018 }
    let(:to_year)   { 2020 }

    it { should include(Date.new(2018, 7, 12) => "桃山みらい") }
    it { should include(Date.new(2018, 9, 9) => "萌黄えも") }
    it { should include(Date.new(2020, 7, 12) => "桃山みらい") }
  end
end

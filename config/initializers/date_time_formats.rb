Time::DATE_FORMATS.merge!({
  weekday_short: '%a, %b %-d',
  weekday_long: '%A, %b %-d',
  long_date_no_year: '%A, %B %d',
  full_time: '%I:%M %p',
  clean: "%l:%M %p",
  rfc_2445: '%Y%m%dT%H%M%SZ',
  rfc_822_no_zone: '%Y-%m-%d %H:%M:%S',
  weekday_short_time: '%a, %b %-d at %l:%M %p', # Thu, Jul 12 at 11:15 pm
  weekday_long_time: '%A, %B %-d at %l:%M %p' # Thursday, July 12 at 11:15 pm
})

Date::DATE_FORMATS.merge!({
  clean:  "%B %-d",
  clean_short: lambda { |date|
    if date.year == Time.now.year
      date.strftime "%b %-d"
    else
      date.strftime "%b %-d, %Y"
    end
  },
  default: "%B %-d, %Y",
  standard: '%m/%d/%Y',
  standard_dashed: '%m-%d-%Y',
  month_year: '%B %Y',
  short_month_day: '%m/%d',

  strip_month_day: '%m/%-d',
  weekday_short: '%a, %b %-d',
  weekday_long: '%A, %b %-d'
})


# Time#to_smart_s gives a human-friendly, relative date-time, client-side.
# >> 1.hour.ago.to_smart_s
# => "12:55 pm"
# >> 1.day.ago.to_smart_s
# => "1:55 pm Thursday"
# >> 1.week.ago.to_smart_s
# => "May 11"
# >> 1.month.ago.to_smart_s
# => "Apr 18"
# >> 1.year.ago.to_smart_s
# => "5/18/11"

class Time
  def to_smart_s
    if self.to_date == Time.zone.now.to_date
      self.strftime('%l:%M %p').downcase.strip
    elsif self.to_date == 1.day.ago.to_date # yesterday
      self.strftime('%l:%M %p').downcase.strip + self.strftime(' %A')
    elsif self >= Time.zone.now.beginning_of_year
      self.strftime('%b ') + self.day.to_s
    else
      self.month.to_s + '/' + self.day.to_s + '/' + self.strftime('%y')
    end
  end

  def to_smart_s_short
    if self.to_date == Time.zone.now.to_date
      self.strftime('%l:%M %p').downcase.strip
    elsif self.to_date == 1.day.ago.to_date # yesterday
      self.strftime('%l:%M %p').downcase.strip + self.strftime(' %a')
    elsif self >= Time.zone.now.beginning_of_year
      self.strftime('%b ') + self.day.to_s
    else
      self.month.to_s + '/' + self.day.to_s + '/' + self.strftime('%y')
    end
  end

  def to_smart_s_with_prep
    smart_s = self.to_smart_s
    smart_s.include?(':') ? "at #{smart_s}" : "on #{smart_s}"
  end
end



module ApplicationHelper
  def smart_time(time)
    now = Time.current
    diff_seconds = now - time

    if diff_seconds < 24.hours
      time_ago_in_words(time) + " ago"
    elsif time.to_date == Date.yesterday
      "Yesterday at #{time.strftime('%-l:%M %p')}"
    elsif time.year == now.year
      time.strftime("%b %-d at %-l:%M %p")
    else
      time.strftime("%b %-d, %Y at %-l:%M %p")
    end
  end

  def full_timestamp(time)
    time.strftime("%B %-d, %Y at %-l:%M %p")
  end
end

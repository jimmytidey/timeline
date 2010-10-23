require 'machinist/active_record'
  
User.blueprint do
  name { "Mr. #{sn}" }
  identifier { "http://www.facebook.com/profile.php?id=#{sn}" }
  email { "test#{sn}@example.com" }
end

TimelineChart.blueprint do
  user_id { 1 }
  title { "The Last 50 Years in Computing" }
  start_date { Time.now - 50}
  end_date { Time.now }
  granularity { 'years' }
end

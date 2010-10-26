require 'machinist/active_record'
  
User.blueprint do
  id { sn }
  timeline_charts(2)
  name { "Mr. #{sn}" }
  identifier { "http://www.facebook.com/profile.php?id=#{sn}" }
  email { "test#{sn}@example.com" }
end

TimelineChart.blueprint do
  id { sn }
  events(3)
  user_id { 1 }
  title { "The Last 50 Years in Computing" }
  start_date { Time.now - 50}
  end_date { Time.now }
  granularity { 'years' }
end

Event.blueprint do
  id { sn }
  title { "Life of Darwin" }
  start_date { Time.now - 10}
  end_date { Time.now }
  timeline_chart_id { 1 }
end

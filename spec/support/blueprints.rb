require 'machinist/active_record'
  
User.blueprint do
  timeline_charts(2)
  name { "Mr. #{sn}" }
  identifier { "http://www.facebook.com/profile.php?id=#{sn}" }
  email { "test#{sn}@example.com" }
end

TimelineChart.blueprint do
  id { sn }
  events(2)
  user_id { 1 }
  title { "The Last 50 Years in Computing" }
  start_date { Time.now - 50}
  end_date { Time.now }
  zoom { TimelineChart::PERIOD[:Decade] }
  private { false }
  hits { 0 }
end

TimelineChart.blueprint(:hidden) do
  id { sn }
  events(2)
  user_id { 1 }
  title { "The Lost Temple of Doom" }
  start_date { Time.now - 500.years}
  end_date { Time.now - 100.years}
  zoom { TimelineChart::PERIOD[:Decade] }
  private { true }
  hits { 0 }
end

Event.blueprint do
  id { sn }
  title { "Life of Darwin" }
  start_date { Time.now - 10}
  end_date { Time.now }
  timeline_chart_id { 1 }
end

if User.first.blank? then
  User.make!(2)
  TimelineChart.make!(:hidden)
end
#Make a hidden chart

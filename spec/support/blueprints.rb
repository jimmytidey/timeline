require 'machinist/active_record'
 
User.blueprint do
  timeline_charts(2)
  name { "Mr. #{sn}" }
  identifier { "http://www.facebook.com/profile.php?id=#{sn}" }
  email { "test#{sn}@example.com" }
  admin { false }
end

TimelineChart.blueprint do
  #id { sn }
  events(2)
  user_id { 1 }
  title { Faker::Lorem.sentence(1) }
  start_date { Date.civil((-1100...999).to_a.rand,1,1) }
  end_date { Date.civil((1201...1800).to_a.rand,1,1) }
  zoom { TimelineChart::PERIOD[:Decade] }
  private { false }
  hits { 0 }
end

TimelineChart.blueprint(:hidden) do
  #id { sn }
  events(2)
  user_id { 1 }
  title { "The Hidden Temple of Doom" }
  start_date { Time.now - 500.years}
  end_date { Time.now - 100.years}
  zoom { TimelineChart::PERIOD[:Decade] }
  private { true }
  hits { 0 }
end

Event.blueprint do
  #id { sn }
  title { "Life of " + Faker::Name.name }
  start_date { Date.civil((1000...1130).to_a.rand,1,1) }
  end_date { Date.civil((1131...1200).to_a.rand,1,1) }
  timeline_chart_id { 1 }
end

# Make a hidden chart. Note that this tests if the db is populated
# because autotest doesn't reset the db, but the rake task does.
if User.first.blank? then
  User.make!(2)
  TimelineChart.make!(:hidden, :user_id => User.first.id)
end

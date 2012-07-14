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
  center_date { Date.civil(1100) }
  zoom { 3 }
  private { false }
  hits { rand 100 }
end

TimelineChart.blueprint(:hidden) do
  #id { sn }
  events(2)
  user_id { 1 }
  title { "The Hidden Temple of Doom" }
  center_date { Date.civil(1100) }
  zoom { 3 }
  private { true }
  hits { 0 }
end

TimelineChart.blueprint(:empty) do
  #id { sn }
  events(0)
  user_id { 99 }
  title { Faker::Lorem.sentence(1) }
  center_date { nil }
  zoom { 3 }
  private { false }
  hits { rand 0 }
end

Event.blueprint do
  #id { sn }
  title { "Life of " + Faker::Name.name }
  start_date { Date.civil((1000...1130).to_a.rand,1,1) }
  end_date { Date.civil((1131...1200).to_a.rand,1,1) }
  timeline_chart_id { 1 }
  color { %w{red yellow blue green orange}.rand }
end

# Make a hidden chart. Note that this tests if the db is populated
# because autotest doesn't reset the db, but the rake task does.
if User.first.blank? then
  User.make!(2)
  TimelineChart.make!(:hidden, :user_id => User.first.id)
end
# Make the first timeline top, so we can click it from the homepage
tc = TimelineChart.find(1)
tc.title = "Tommy's Tom Timeline"
tc.hits = 9999999
tc.save


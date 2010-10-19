require 'machinist/active_record'
  
User.blueprint do
  name { "Mr. #{sn}" }
  identifier { "http://www.facebook.com/profile.php?id=#{sn}" }
  email { "test#{sn}@example.com" }
end

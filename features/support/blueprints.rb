require Rails.root.join('spec','support','blueprints.rb')

begin
  @user = User.make!
  @tc = @user.timeline_charts.first
rescue
end

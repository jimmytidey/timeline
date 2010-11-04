#Begin unfortunate monkey patch...
    # Temporary hack until either one of the capybara drivers can post, or rack can share cookies with
    # one of the capybara drivers: http://avdi.org/devblog/2010/06/18/rack-test-and-capybara-are-uneasy-bedfellows/
    # 
    # What not to try again...
    # capybara default driver => No js support. visit() is GET only, never POST
    # selenium                => Doesn't have visibility of interactions between the browser & Janrain
    # rack                    => cookie is lost after post()
    # envjs                   => Cant work out what to do with RPXNOW in cdata section.
    # jruby                   => This doesn't work either. Can't remember why.
class UsersController
  def cuke
    raise 'Testing only' unless Rails.env.test? # better safe than sorry

    RPXNow.stubs(:user_data).with('123456').returns({:email => "rpxuser@email.com",:identifier => "test",:username => "rpxusername"})
    params[:token] = '123456'
    self.create
  end
end


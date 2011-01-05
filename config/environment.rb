# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Timeline::Application.initialize!

ActiveSupport::CoreExtensions::Time::Conversions::DATE_  
  FORMATS.update(:default => '%Y-%m-%d %H:%M:%S')  
ActiveSupport::CoreExtensions::Date::Conversions::DATE_    
  FORMATS.update(:default => '%Y-%m-%d')  
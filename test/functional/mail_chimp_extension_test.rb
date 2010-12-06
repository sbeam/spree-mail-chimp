require File.dirname(__FILE__) + '/../test_helper'

class MailChimpExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_subscription
      
      User.create(:email => 'rand1'+rand(1000)+'@example.com', :password => 'abc123', :password_confirmation => 'abc123');

    
  end
  
  def test_initialization
    assert_equal File.join(File.expand_path(Rails.root), 'spree_mail_chimp'), MailChimp.root
    #assert_equal 'Mail Chimp', MailChimp.name
  end
  
end

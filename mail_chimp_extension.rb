# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class MailChimpExtension < Spree::Extension
  version "1.0"
  description "Mail Chimp API integration with your Spree Store, using the hominid gem"
  url "http://github.com/sbeam/spree-mail-chimp.git"


  def self.require_gems(config)
      config.gem 'hominid', '>= 2.2.0'
  end
  
  def activate

    require 'hominid' # http://github.com/bgetting/hominid
    ActiveRecord::Base.send(:include, MailChimp::Sync)
    User.class_eval do 
      sync_with_mailchimp
      attr_accessible :is_mail_list_subscriber
    end 
    
    # make our helper avaliable in all views
    Spree::BaseController.class_eval do
       helper MailChimpHelper
    end
  end
end

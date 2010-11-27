require 'spree_core'
require 'mail_chimp_hooks'
require 'mail_chimp_sync'
require 'hominid'

module MailChimp
  class Engine < Rails::Engine

	config.autoload_paths += %W(#{config.root}/lib)
	
    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
	  
      Spree::BaseController.class_eval do
        helper MailChimpHelper
    end
	
	UsersController.send(:include, MailChimpSync::Sync)

	User.class_eval do 
     attr_accessible :is_mail_list_subscriber
	end 

 end
    
    config.to_prepare &method(:activate).to_proc
  end
end
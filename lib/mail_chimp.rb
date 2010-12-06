require 'spree_core'
require 'mail_chimp_hooks'
require 'mail_chimp_sync'
require 'hominid'

module MailChimp
  class Engine < Rails::Engine

      config.autoload_paths += %W(#{config.root}/lib)

      def self.activate

          Spree::BaseController.class_eval do
              helper MailChimpHelper
          end

          UsersController.send(:include, MailChimpSync::Sync)

          User.class_eval do 
              attr_accessible :is_mail_list_subscriber
          end 

          AppConfiguration.class_eval do
              preference :mailchimp_double_opt_in, :boolean, :default => false
              preference :mailchimp_send_welcome, :boolean, :default => false
              preference :mailchimp_send_notify, :boolean, :default => false
              preference :mailchimp_merge_vars, :string, :default => ''
              preference :mailchimp_list_id, :string
              preference :mailchimp_api_key, :string
          end

      end
    
      config.to_prepare &method(:activate).to_proc
  end
end

module MailChimp
  module Sync

      def self.included(target)
          target.class_eval do
              create.after :create_in_mailchimp
              update.after :update_in_mailchimp
              destroy.after :remove_from_mailchimp
          end
      end

      def mc_api_key
          Spree::Config.get(:mailchimp_api_key)
      end
      def mc_list_id
          Spree::Config.get(:mailchimp_list_id)
      end

      def create_in_mailchimp
          return unless @user.is_mail_list_subscriber

          hom = Hominid::Base.new({:api_key => mc_api_key})
          User.class.benchmark "Adding mailchimp subscriber (list id=#{mc_list_id})" do
              hom.subscribe(mc_list_id, @user.email, Spree::Config.get(:mailchimp_subscription_opts))
          end
          User.class.benchmark "Fetching new mailchimp subscriber info" do
              mc_member = hom.member_info(mc_list_id, @user.email)
              logger.debug mc_member.inspect
              @user.send(:attributes=, { :mailchimp_subscriber_id => mc_member[:id]}, false)
          end
          #rescue
          #logger.warn "mailchimp-API: Failed to create contact #{id} in mailchimp: #{$1}"
      end

      # run before_update, but we don't want to do this everytime
      # spree/authlogic update the user's timestamps. So need to detect if
      # subscription checkbox is set, that means it was the user editing form.
      def update_in_mailchimp
        self.class.benchmark "Updating contact in MailChimp" do

        unless params[:is_mail_list_subscriber].nil? # works if not checked ?
            hom = Hominid::Base.new({:api_key => mc_api_key})

            if self.is_mail_list_subscriber && !self.mailchimp_subscriber_id.blank?
                hom.update_member(mc_list_id, self.email, {:EMAIL => self.email})
            elsif self.is_mail_list_subscriber && self.mailchimp_subscriber_id.nil?
                create_in_mailchimp 
            elsif !self.is_mail_list_subscriber && !self.mailchimp_subscriber_id.blank?
                remove_from_mailchimp
            end

          end
        end
      #rescue
        #logger.warn "mailchimp-API: Falhou ao atualizar o contato #{id} no mailchimp"
      end

      def remove_from_mailchimp 
        hom = Hominid::Base.new({:api_key => mc_api_key})

        self.class.benchmark "removing subscriber from mailchimp" do
            if self.mailchimp_subscriber_id
                hom.unsubscribe(mc_list_id, self.email)
            end
        end
      #rescue
        #logger.warn "mailchimp-API: could not remove user id=#{id} from Mailchimp"
      end

      
    end
    
    


  
  


          
end



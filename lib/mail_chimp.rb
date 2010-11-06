module MailChimp
  module Sync

      def self.included(target)
          target.class_eval do
              after_filter :create_in_mailchimp, :only => [:create]
              after_filter :update_in_mailchimp, :only => [:update]
              destroy.after :remove_from_mailchimp # can use r_c?
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
          User.benchmark "Adding mailchimp subscriber (list id=#{mc_list_id})" do
              hom.subscribe(mc_list_id, @user.email, Spree::Config.get(:mailchimp_subscription_opts))
          end
          logger.debug "Fetching new mailchimp subscriber info"
          mc_member = hom.member_info(mc_list_id, @user.email)
          logger.debug mc_member.inspect
          @user.mailchimp_subscriber_id = mc_member['id']
          @user.save
      rescue
          # TODO alert someone there is a problem with mailchimp
          logger.warn "mailchimp-API: Failed to create contact #{id} in mailchimp: #{$1}"
      end

      # run before_update, but we don't want to do this everytime
      # spree/authlogic update the user's timestamps. So need to detect if
      # subscription checkbox is set, that means it was the user editing form.
      def update_in_mailchimp

        if params && params[:user] && params[:user][:is_mail_list_subscriber] # works if not checked because 0 is true

            if params[:user][:is_mail_list_subscriber].to_i.equal?(1) && !@user.mailchimp_subscriber_id.blank?
                hom = Hominid::Base.new({:api_key => mc_api_key})
                User.benchmark "Updating mailchimp subscriber (list id=#{mc_list_id}, member=#{@user.mailchimp_subscriber_id})" do
                    hom.update_member(mc_list_id, @user.mailchimp_subscriber_id, {:EMAIL => @user.email})
                end
            elsif params[:user][:is_mail_list_subscriber].to_i.equal?(1) && @user.mailchimp_subscriber_id.blank?
                create_in_mailchimp 
            elsif params[:user][:is_mail_list_subscriber].to_i.zero? && !@user.mailchimp_subscriber_id.blank?
                remove_from_mailchimp
            end

        end
      rescue
        logger.warn "mailchimp-API: Failed to update mailchimp record for user id=#{@user.id}"
      end

      def remove_from_mailchimp 
        hom = Hominid::Base.new({:api_key => mc_api_key})

        if @user.mailchimp_subscriber_id
            @user.mailchimp_subscriber_id = nil
            @user.save
            User.benchmark "removing subscriber #{@user.mailchimp_subscriber_id} from mailchimp" do
                hom.unsubscribe(mc_list_id, @user.email)
            end
        end
      rescue
        logger.warn "mailchimp-API: could not remove user id=#{@user.id} from Mailchimp"
      end

      
    end
    
    


  
  


          
end



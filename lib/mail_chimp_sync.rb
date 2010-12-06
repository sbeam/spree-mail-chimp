module MailChimpSync 

  module Sync

      def self.included(target)
          target.class_eval do
              after_filter :create_in_mailchimp, :only => [:create]
              after_filter :update_in_mailchimp, :only => [:update]
              destroy.after :remove_from_mailchimp # can use r_c?

              def hominid
                  @hominid ||= Hominid::Base.new({:api_key => Spree::Config.get(:mailchimp_api_key)})
              end

              def mc_list_id
                  Spree::Config.get(:mailchimp_list_id)
              end
          end
      end

      def create_in_mailchimp
          return unless @user.is_mail_list_subscriber

          merge_vars = {}
          if Spree::Config.get(:mailchimp_merge_user_attribs)
            mailchimp_merge_user_attribs = YAML::load Spree::Config.get(:mailchimp_merge_user_attribs)
            mailchimp_merge_user_attribs.each_pair do |mc_prop, meth|
              merge_vars[mc_prop] = @user.send(meth) if @user.respond_to? meth
            end
          end

          if subscription_opts = Spree::Config.get(:mailchimp_subscription_opts)
              subscription_opts = YAML::load subscription_opts ## config gives us yaml :/
          end
          
          User.benchmark "Adding mailchimp subscriber (list id=#{mc_list_id})" do
              hominid.subscribe(mc_list_id, @user.email, merge_vars, subscription_opts)
          end
          logger.debug "Fetching new mailchimp subscriber info"
          mc_member = hominid.member_info(mc_list_id, @user.email)
          logger.debug mc_member.inspect
          @user.mailchimp_subscriber_id = mc_member['id']
          @user.save # this probably isn't kosher in an after-filter method
      rescue
          # TODO alert someone there is a problem with mailchimp
         logger.warn "MailChimp::Sync: Failed to create contact #{id} in mailchimp: #{$1}"
      end

      # run before_update, but we don't want to do this everytime
      # spree/authlogic update the user's timestamps. So need to detect if
      # subscription checkbox is set, that means it was the user editing form.
      def update_in_mailchimp

        if params && params[:user] && params[:user][:is_mail_list_subscriber] # works if not checked because 0 is true

            if params[:user][:is_mail_list_subscriber].to_i.equal?(1) && !@user.mailchimp_subscriber_id.blank?
                User.benchmark "Updating mailchimp subscriber (list id=#{mc_list_id}, member=#{@user.mailchimp_subscriber_id})" do
                    hominid.update_member(mc_list_id, @user.mailchimp_subscriber_id, {:EMAIL => @user.email})
                end
            elsif params[:user][:is_mail_list_subscriber].to_i.equal?(1) && @user.mailchimp_subscriber_id.blank?
                create_in_mailchimp 
            elsif params[:user][:is_mail_list_subscriber].to_i.zero? && !@user.mailchimp_subscriber_id.blank?
                remove_from_mailchimp
            end

        end
      rescue
       logger.warn "MailChimp::Sync: Failed to update mailchimp record for user id=#{@user.id}"
      end

      def remove_from_mailchimp 

        if @user.mailchimp_subscriber_id
            @user.mailchimp_subscriber_id = nil
            @user.save
            User.benchmark "removing subscriber #{@user.mailchimp_subscriber_id} from mailchimp" do
                hominid.unsubscribe(mc_list_id, @user.email)
            end
        end
      rescue
        logger.warn "MailChimp::Sync: could not remove user id=#{@user.id} from Mailchimp"
      end

      
    end
end

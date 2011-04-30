module MailChimpSync 

  module Sync

      def self.included(target)
          target.class_eval do
              after_filter :create_in_mailchimp, :only => [:create]
              after_filter :update_in_mailchimp, :only => [:update]

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
          
          User.benchmark "Adding mailchimp subscriber (list id=#{mc_list_id})" do
              hominid.subscribe(mc_list_id, @user.email, mc_merge_vars, MailChimpSync::Sync::mc_subscription_opts)
          end
          logger.debug "Fetching new mailchimp subscriber info"
          mc_member = hominid.member_info(mc_list_id, @user.email)
          logger.debug mc_member.inspect
          @user.mailchimp_subscriber_id = mc_member['id']
          @user.save # this probably isn't kosher in an after-filter method
      rescue Hominid::APIError => e
          # TODO alert someone there is a problem with mailchimp
         logger.warn "MailChimp::Sync: Failed to create contact #{id} in mailchimp: #{e.message}"
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
      rescue Hominid::APIError => e
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
      rescue Hominid::APIError => e
        logger.warn "MailChimp::Sync: could not remove user id=#{@user.id} from Mailchimp"
      end

      
      private

      def mc_merge_vars
          merge_vars = {}
          if mailchimp_merge_user_attribs = Spree::Config.get(:mailchimp_merge_vars)
            mailchimp_merge_user_attribs.split(',').each do |meth|
              merge_vars[meth.upcase] = @user.send(meth.downcase) if @user.respond_to? meth.downcase
            end
          end
          merge_vars
      end

      def self.mc_subscription_opts
          options = {}
          [:mailchimp_double_opt_in, :mailchimp_send_welcome, :mailchimp_send_notify].each do |opt|
              options[opt.to_s.gsub(/^mailchimp_/,'')] = Spree::Config.get(opt)
          end
          options
      end

    end
end

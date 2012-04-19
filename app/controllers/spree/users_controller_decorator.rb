Spree::UsersController.class_eval do

  after_filter :update_in_mailchimp, :only => [:update]

  def hominid
    Hominid::API.new(Spree::Config.get(:mailchimp_api_key))
  end

  def mc_list_id
    Spree::Config.get(:mailchimp_list_id)
  end

  private

  def update_in_mailchimp
    if params && params[:user] && params[:user][:is_mail_list_subscriber] # works if not checked because 0 is true

      if params[:user][:is_mail_list_subscriber].to_i.equal?(1) && !@user.mailchimp_subscriber_id.blank?
        Spree::User.benchmark "Updating mailchimp subscriber (list id=#{mc_list_id}, member=#{@user.mailchimp_subscriber_id})" do
          hominid.update_member(mc_list_id, @user.mailchimp_subscriber_id, {:EMAIL => @user.email})
        end
      end
    end
    rescue Hominid::APIError => e
      logger.warn "MailChimp::Sync: Failed to update mailchimp record for user id=#{@user.id}"
  end

end

Spree::UsersController.class_eval do

  after_filter :create_in_mailchimp, :only => [:create]
  after_filter :update_in_mailchimp, :only => [:update]
  # destroy.after :remove_from_mailchimp # can use r_c?


  # Generates the subsubcription options for the application
  #
  # The option values are returned as an Array in the following order:
  #
  # double_optin      - Flag to control whether a double opt-in confirmation
  #                     message is sent, defaults to true. Abusing this may
  #                     cause your account to be suspended. (default: false)
  # update_existing   - Flag to control whether existing subscribers should be
  #                     updated instead of throwing an error. (default: true)
  #                     ( MailChimp's default is false )
  # replace_interests - Flag to determine whether we replace the interest
  #                     groups with the groups provided or we add the provided
  #                     groups to the member's interest groups. (default: true)
  # send_welcome      - If the double_optin is false and this is true, a welcome
  #                     email is sent out. If double_optin is true, this has no
  #                     effect. (default: false)
  #
  # Returns an Array of subscription options
  #
  # TODO: Add configuration options for 'update_existing' and 'replace_interests'
  # TODO: Remove configuration options for :mailchimp_send_notify
  # TODO: Move this into a module as it probably does not belong in the controller
  def mc_subscription_opts
    [Spree::Config.get(:mailchimp_double_opt_in), true, true, Spree::Config.get(:mailchimp_send_welcome)]
  end

  def hominid
    Hominid::API.new(Spree::Config.get(:mailchimp_api_key))
  end

  def mc_list_id
    Spree::Config.get(:mailchimp_list_id)
  end

  private

  def create_in_mailchimp
    return unless @user.is_mail_list_subscriber

    Spree::User.benchmark "Adding mailchimp subscriber (list id=#{mc_list_id})" do
      hominid.list_subscribe(mc_list_id, @user.email, mc_merge_vars, 'html', *mc_subscription_opts)
    end

    logger.debug "Fetching new mailchimp subscriber info"

    mc_member = hominid.list_member_info(mc_list_id, @user.email)

    logger.debug mc_member.inspect

    @user.mailchimp_subscriber_id = mc_member['id']
    @user.save # this probably isn't kosher in an after-filter method
    rescue Hominid::APIError => e
      # TODO alert someone there is a problem with mailchimp
      logger.warn "MailChimp::Sync: Failed to create contact in mailchimp: #{e.message}"
  end

  def remove_from_mailchimp
    if @user.mailchimp_subscriber_id
      @user.mailchimp_subscriber_id = nil
      @user.save
      Spree::User.benchmark "removing subscriber #{@user.mailchimp_subscriber_id} from mailchimp" do
        hominid.unsubscribe(mc_list_id, @user.email)
      end
    end
    rescue Hominid::APIError => e
      logger.warn "MailChimp::Sync: could not remove user id=#{@user.id} from Mailchimp"
  end

  def update_in_mailchimp
    if params && params[:user] && params[:user][:is_mail_list_subscriber] # works if not checked because 0 is true

      if params[:user][:is_mail_list_subscriber].to_i.equal?(1) && !@user.mailchimp_subscriber_id.blank?
        Spree::User.benchmark "Updating mailchimp subscriber (list id=#{mc_list_id}, member=#{@user.mailchimp_subscriber_id})" do
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

  def mc_merge_vars
    merge_vars = {}
    if mailchimp_merge_user_attribs = Spree::Config.get(:mailchimp_merge_vars)
      mailchimp_merge_user_attribs.split(',').each do |meth|
        merge_vars[meth.upcase] = @user.send(meth.downcase) if @user.respond_to? meth.downcase
      end
    end
    merge_vars
  end

end

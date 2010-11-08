class MailChimpHooks < Spree::ThemeSupport::HookListener


  insert_after :signup_below_password_fields, 'subscribe_to_newsletter_field'

  # Add js for ajaxy subscriptions from footer or wherever
  insert_after :inside_head do
    "<%= javascript_include_tag 'mailchimp_subscribe' %>"
  end


end

class MailChimpHooks < Spree::ThemeSupport::HookListener


  insert_after :signup_below_password_fields, 'subscribe_to_newsletter_field'

  


end

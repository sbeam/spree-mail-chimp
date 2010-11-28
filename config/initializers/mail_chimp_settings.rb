if Spree::Config.instance 
    Spree::Config.set(:mailchimp_api_key => '')
    Spree::Config.set(:mailchimp_list_id => '')
    Spree::Config.set(:mailchimp_subscription_opts => {:email_type => 'html', :secure => true, :double_opt_in => true})
end 


# here are the default subscription opts that hominid uses, override above as needed:
#       :double_opt_in => false,
#       :merge_tags => {},
#       :replace_interests => true,
#       :secure => false,
#       :send_goodbye => false,
#       :send_notify => false,
#       :send_welcome => false,
#       :timeout => nil,
#       :update_existing => true

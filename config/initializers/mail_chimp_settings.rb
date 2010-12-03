if Spree::Config.instance 
    Spree::Config.set(:mailchimp_api_key => '29fac3ec027eb71badafce2b1edb72b0-us2')
    Spree::Config.set(:mailchimp_list_id => '6ec957aa45')
    MAILCHIMP_SUBSCRIPTION_OPTS = {:email_type => 'html'}
    # MAILCHIMP_MERGE_USER_ATTRIBS = {} # map MC merge id's to User methods, eg :AGE => :age, :LANG => :language
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

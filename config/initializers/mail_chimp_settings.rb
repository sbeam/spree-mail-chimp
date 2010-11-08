if Spree::Config.instance 
    Spree::Config.set(:mailchimp_api_key => '29fac3ec027eb71badafce2b1edb72b0-us2')
    Spree::Config.set(:mailchimp_list_id => '6ec957aa45')
    Spree::Config.set(:mailchimp_subscription_opts => {:email_type => 'html', :secure => true, :double_opt_in => true})
end 

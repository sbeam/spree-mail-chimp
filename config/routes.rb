Rails.application.routes.draw do

resources :subscriptions, :only => :create
#resources :sync, :only => :create_in_mailchimp
#resources :subscriptions do
  #    resources :sync, :only => :create_in_mailchimp
    #end

end
class SubscriptionsController < Spree::BaseController

    def hominid
        @hominid ||= Hominid::Base.new({:api_key => Spree::Config.get(:mailchimp_api_key)})
    end

    def create
        @errors = []

        if params[:email].blank?
            @errors << "missing email"
        else
            begin
                self.class.benchmark "Checking if address exists and/or is valid" do
                    @mc_member = hominid.member_info(Spree::Config.get(:mailchimp_list_id), params[:email])
                end
            rescue Hominid::ListError => e
            end

            if @mc_member
                @errors << t('that_address_is_already_subscribed')
            else
                begin
                    self.class.benchmark "Adding mailchimp subscriber" do
                        hominid.subscribe(Spree::Config.get(:mailchimp_list_id), params[:email], Spree::Config.get(:mailchimp_subscription_opts))
                    end
                rescue Hominid::ValidationError => e
                    logger.debug "MUST BE HERE"
                    @errors << t('invalid_address')
                end
            end
        end

        respond_to do |wants|
            wants.js  
        end
    end
end

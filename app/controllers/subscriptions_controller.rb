class SubscriptionsController < Spree::BaseController


    def hominid
        @hominid ||= Hominid::Base.new({:api_key => Spree::Config.get(:mailchimp_api_key)})
    end

    def create
        @errors = []

        if params[:email].blank?
            @errors << t('missing_email')
        elsif params[:email] !~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
            @errors << t('invalid_email_address')
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
                        hominid.subscribe(Spree::Config.get(:mailchimp_list_id), params[:email], {}, SpreeMailChimpSync::Sync::mc_subscription_opts)
                    end
                rescue Hominid::ValidationError => e
                    @errors << t('invalid_email_address')
                end
            end
        end

        respond_to do |wants|
            wants.js  
        end
    end
end

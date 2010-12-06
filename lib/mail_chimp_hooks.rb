class MailChimpHooks < Spree::ThemeSupport::HookListener
	insert_after :signup_below_password_fields, 'users/subscribe_to_newsletter_field'
	insert_after :footer_left, 'shared/newsletter_subscribe_form'

	# Add js for ajaxy subscriptions from footer or wherever
	insert_after :inside_head do
        "<%= stylesheet_link_tag 'mail_chimp' %>
		<%= javascript_include_tag 'jquery.simplemodal.1.4.min.js','mailchimp_subscribe' %>"
    end

    insert_after :admin_configurations_menu do
        %[
          <tr>
            <td><%= link_to t("mail_chimp_settings"), admin_mail_chimp_settings_path %></td>
            <td><%= t("mail_chimp_settings_description") %></td>
          </tr>
        ] 
    end

end

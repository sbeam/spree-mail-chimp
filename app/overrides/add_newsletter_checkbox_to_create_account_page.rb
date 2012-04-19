Deface::Override.new(:virtual_path => "spree/shared/_user_form",
                     :name         => "add_newsletter_checkbox_to_create_account_page",
                     :insert_top   => "[data-hook='signup_below_password_fields']",
                     :partial      => "spree/users/subscribe_to_newsletter_field" )

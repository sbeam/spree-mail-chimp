Deface::Override.new(:virtual_path  => 'spree/admin/shared/_configuration_menu',
                     :name          => 'add_mail_chimp_admin_menu_link',
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                    :text => %q{
                        <%= configurations_sidebar_menu_item 'Mail Chimp', admin_mail_chimp_settings_path %>
                     }) 
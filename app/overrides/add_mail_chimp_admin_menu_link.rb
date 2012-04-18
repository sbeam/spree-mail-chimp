Deface::Override.new(:virtual_path  => 'spree/admin/configurations/index',
                     :name          => 'add_mail_chimp_admin_menu_link',
                     :insert_bottom => "[data-hook='admin_configurations_menu']",
                     :partial       => 'spree/admin/configurations/spree_mail_chimp_configuration_link' )

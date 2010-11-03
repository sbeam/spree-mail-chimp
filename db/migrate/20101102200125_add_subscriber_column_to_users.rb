class AddSubscriberColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_mail_list_subscriber, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :is_mail_list_subscriber
  end
end

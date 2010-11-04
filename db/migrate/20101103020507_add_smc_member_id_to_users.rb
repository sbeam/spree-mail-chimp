class AddSmcMemberIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mailchimp_subscriber_id, :string, :length => 31
  end

  def self.down
    remove_column :users, :mailchimp_subscriber_id
  end
end

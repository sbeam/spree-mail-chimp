module Spree::MailChimp
  class Config < Spree::Config
    class << self
      def instance
        return nil unless ActiveRecord::Base.connection.tables.include?('configurations')
        MailChimpConfiguration.find_or_create_by_name("MailChimp configuration")
      end
    end
  end
end
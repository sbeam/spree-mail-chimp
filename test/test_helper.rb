require 'test/unit'
# Load the environment
unless defined? SPREE_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["SPREE_ENV_FILE"]
    require File.dirname(ENV["SPREE_ENV_FILE"]) + "/boot"
  when File.dirname(__FILE__) =~ %r{spree_mail_chimp}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/boot"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/boot"
  end
end
require "#{SPREE_ROOT}/test/test_helper"

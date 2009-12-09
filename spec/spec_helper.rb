require File.dirname(__FILE__) + "/../../../../spec/spec_helper"

# Plant admin user before the importer overrides :user factory.
Factory(:user, :admin => true)

require "lib/crm_highrise_importer"
require "spec/factories"
require "spec/backends"

require "rails_admin_clone/engine"

module RailsAdminClone
end

require 'rails_admin/config/actions'

module RailsAdmin
  module Config
    module Actions
      class Clone < Base
        RailsAdmin::Config::Actions.register(self)
        
        register_instance_option :object_level do
          true
        end
      end
    end
  end
end


require 'rails_admin/config/sections/base'

module RailsAdmin
  module Config
    module Sections
      # Configuration of the clone action
      class CloneConfig < RailsAdmin::Config::Sections::Base

        register_instance_option :custom_method do
          nil
        end

      end
    end
  end
end

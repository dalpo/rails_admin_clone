
module RailsAdmin
  module Config
    module Actions
      class Clone < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :http_methods do
          [:get]
        end

        register_instance_option :controller do
          Proc.new do

            @object = @abstract_model.new

            @authorization_adapter && @authorization_adapter.attributes_for(:new, @abstract_model).each do |name, value|
              @object.send("#{name}=", value)
            end

            if object_params = params[@abstract_model.to_param]
              @object.set_attributes(@object.attributes.merge(object_params))
            end

            respond_to do |format|
              format.html { render @action.template_name }
              format.js   { render @action.template_name, :layout => false }
            end

          end
        end

        register_instance_option :template_name do
          :new
        end

        register_instance_option :link_icon do
          'icon-copy'
        end
      end
    end
  end
end

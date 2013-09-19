
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

            @old_object = @object
            @object = @abstract_model.new

            attributes = @old_object.attributes.select do |k,v|
              ![@object.class.primary_key, 'created_at', 'updated_at'].include?(k)
            end

            # clone old_object
            @object.assign_attributes attributes, without_protection: true

            # clone has_one associations
            @object.class.reflect_on_all_associations(:has_one).each do |class_association|
              association_name = class_association.name
              old_association = @old_object.send(association_name)

              if old_association
                primary_key = association_name.singularize.camelize.constantize.try(:primary_key) || 'id'

                attributes = old_association.attributes.select do |k,v|
                  ![primary_key, class_association.try(:foreign_key), class_association.try(:type), 'created_at', 'updated_at'].include?(k)
                end

                @object.send(:"build_#{association_name}").tap do |a|
                  a.assign_attributes attributes, without_protection: true
                end
              end
            end

            # clone has_many associations
            @object.class.reflect_on_all_associations(:has_many).each do |class_association|
              association_name = class_association.name
              primary_key = association_name.singularize.camelize.constantize.try(:primary_key) || 'id'

              @old_object.send(association_name).each do |old_association|
                attributes = old_association.attributes.select do |k,v|
                  ![primary_key, class_association.try(:foreign_key), class_association.try(:type), 'created_at', 'updated_at'].include?(k)
                end

                @object.send(association_name).build.tap do |a|
                  a.assign_attributes old_association.attributes, without_protection: true
                end
              end
            end

            # clone has_and_belongs_to_many associtations
            @object.class.reflect_on_all_associations(:has_and_belongs_to_many).each do |class_association|
              association_name = class_association.name
              method_ids = "#{association_name.to_s.singularize.to_sym}_ids"

              @object.send(method_ids, @old_object.send(method_ids))
            end

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

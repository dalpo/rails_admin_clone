module RailsAdminClone
  class ModelCloner

    def initialize(original_model)
      @original_model = original_model
    end

    def original_model
      @original_model
    end

    def class_model
      original_model.class
    end

    def default_clone
      new_object = clone_object(original_model)
      clone_recursively!(original_model, new_object)

      new_object
    end

    def method_clone(method)
      original_model.send(method)
    end

  protected

    # def class_with_strong_parameters?(klass)
    #   defined?(ActiveModel::ForbiddenAttributesProtection) && klass.include?(ActiveModel::ForbiddenAttributesProtection)
    # end

    def timestamp_columns
      %w(created_at created_on updated_at updated_on)
    end

    def attributes_black_list_from_model(model)
      [model.primary_key, model.inheritance_column] + timestamp_columns
    end

    def attributes_black_list_from_association(association)
      model = association.class_name.constantize
      attributes = attributes_black_list_from_model(model)
      attributes + [association.try(:foreign_key), association.try(:type)]
    end

    def get_model_attributes_from(object)
      object.attributes.select do |k,v|
        !attributes_black_list_from_model(object.class).include?(k)
      end
    end

    def get_association_attributes_from(object, association)
      object.attributes.select do |k,v|
        !attributes_black_list_from_association(association).include?(k)
      end
    end

    def assign_attributes_for(object, attributes)
      if Rails.version < '4.0.0'
        object.assign_attributes attributes
      else
        object.assign_attributes attributes, without_protection: true
      end
    end

    def clone_recursively!(old_object, new_object)
      new_object = clone_has_one  old_object, new_object
      new_object = clone_habtm    old_object, new_object
      new_object = clone_has_many old_object, new_object

      new_object
    end

    # clone object without associations
    def clone_object(old_object)
      object     = build_from(old_object)
      # attributes = old_object.attributes.select do |k,v|
      #   ![object.class.primary_key, 'created_at', 'updated_at'].include?(k)
      # end

      assign_attributes_for(object, get_model_attributes_from(old_object))

      object
    end

    # clone has_one associations
    def clone_has_one(old_object, new_object)
      old_object.class.reflect_on_all_associations(:has_one).each do |association|
        # association_name  = association.name
        # association_class = association.class_name.constantize
        # primary_key = association_class.primary_key
        # sti_column  = association_class.inheritance_column

        if old_association = old_object.send(association.name)
          # attributes = old_association.attributes.select do |k,v|
          #   ![primary_key, sti_column, association.try(:foreign_key), association.try(:type), 'created_at', 'updated_at'].include?(k)
          # end

          new_object.send(:"build_#{association.name}").tap do |new_association|
            assign_attributes_for(new_association, get_association_attributes_from(old_association, association))
            new_association = clone_recursively!(old_association, new_association)
          end
        end
      end

      new_object
    end

    # clone has_many associations
    def clone_has_many(old_object, new_object)
      associations = old_object.class.reflect_on_all_associations(:has_many)
        .select{|a| !a.options.keys.include?(:through)}

      associations.each do |association|
        # association_name = association.name
        # association_class = association.class_name.constantize
        # primary_key = association_class.primary_key
        # sti_column  = association_class.inheritance_column

        old_object.send(association.name).each do |old_association|
          # attributes = old_association.attributes.select do |k,v|
          #   ![primary_key, sti_column, association.try(:foreign_key), association.try(:type), 'created_at', 'updated_at'].include?(k)
          # end

          new_object.send(association.name).build.tap do |new_association|
            assign_attributes_for(new_association, get_association_attributes_from(old_association, association))
            new_association = clone_recursively!(old_association, new_association)
          end
        end
      end

      new_object
    end

    # clone has_and_belongs_to_many associtations
    def clone_habtm(old_object, new_object)
      associations = old_object.class.reflect_on_all_associations.select do |a|
        a.macro == :has_and_belongs_to_many || (a.macro == :has_many && a.options.keys.include?(:through))
      end

      associations.each do |association|
        method_ids       = "#{association.name.to_s.singularize.to_sym}_ids"
        new_object.send(:"#{method_ids}=", old_object.send(method_ids))
      end

      new_object
    end

    def build_from(object)
      object.class.new
    end
  end
end





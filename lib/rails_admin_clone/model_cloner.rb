module RailsAdminClone
  class ModelCloner

    def initialize(original_model)
      @original_model = original_model
    end

    def original_model
      @original_model
    end

    def default_clone
      new_object = self.clone_object(self.original_model)

      self.clone_recursively!(self.original_model, new_object)
      begin
        self.clone_recursively!(self.original_model, new_object)
      rescue Exception => e
        Rails.logger.info "RailsAdminClone Exception on clone_recursively!:\n#{e}"
      end

      new_object
    end

    def method_clone(method)
      self.original_model.send(method)
    end

  protected

    def clone_recursively!(old_object, new_object)
      new_object = clone_has_one(old_object, new_object)
      new_object = clone_habtm(old_object, new_object)
      new_object = clone_has_many(old_object, new_object)


      new_object
    end

    # clone object without associations
    def clone_object(old_object)
      object     = build_from(old_object)
      attributes = old_object.attributes.select do |k,v|
        ![object.class.primary_key, 'created_at', 'updated_at'].include?(k)
      end

      object.assign_attributes attributes
      object
    end

    # clone has_one associations
    def clone_has_one(old_object, new_object)
      old_object.class.reflect_on_all_associations(:has_one).each do |class_association|
        association_name = class_association.name
        old_association  = old_object.send(association_name)

        if old_association
          # primary_key = association_name.to_s.singularize.camelize.constantize.try(:primary_key) || 'id'
          primary_key = 'id'

          attributes = old_association.attributes.select do |k,v|
            ![primary_key, class_association.try(:foreign_key), class_association.try(:type), 'created_at', 'updated_at'].include?(k)
          end

          new_object.send(:"build_#{association_name}").tap do |new_association|
            new_association.assign_attributes attributes
            new_association = self.clone_recursively!(old_association, new_association)
          end
        end
      end

      new_object
    end

    # clone has_many associations
    def clone_has_many(old_object, new_object)
      associations = old_object.class.reflect_on_all_associations(:has_many)
        .select{|a| !a.options.keys.include?(:through)}

      associations.each do |class_association|
        association_name = class_association.name
        # primary_key      = association_name.to_s.singularize.camelize.constantize.try(:primary_key) || 'id'
        primary_key = 'id'

        old_object.send(association_name).each do |old_association|
          attributes = old_association.attributes.select do |k,v|
            ![primary_key, class_association.try(:foreign_key), class_association.try(:type), 'created_at', 'updated_at'].include?(k)
          end

          new_object.send(association_name).build.tap do |new_association|
            new_association.assign_attributes attributes
            new_association = self.clone_recursively!(old_association, new_association)
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

      associations.each do |class_association|
        association_name = class_association.name
        method_ids       = "#{association_name.to_s.singularize.to_sym}_ids"

        Rails.logger.info "**** association_name: #{association_name}"

        new_object.send(:"#{method_ids}=", old_object.send(method_ids))
      end

      new_object
    end

    def build_from(object)
      object.class.new
    end
  end
end





module DevelopmentHelpers
  module MetaDataPreset

    class << self 

      TABLES=[ "meta_keys",
        "meta_terms", "meta_keys_meta_terms",
        "meta_context_groups", "meta_contexts",
        "meta_key_definitions",
        "permission_presets",
        "copyrights"]

      def create_hash
        h = {}
        table_name_models.each do |table_name,model| 
          h[table_name] = model.order(model.primary_key).all.collect(&:attributes)
        end
        h
      end

      def load_minimal_yaml
        file_name = Rails.root.join("features","data","minimal_meta").to_s + ".yml"
        h = YAML.load File.read file_name
        import_hash h
      end

      def import_hash h
        tnm = table_name_models
        ActiveRecord::Base.transaction do
          h.keys.each do |table_name|
            klass = tnm[table_name]
            klass.attribute_names.each { |attr| klass.attr_accessible attr}
            h[table_name].each do |attributes|
              klass.create attributes
            end
            SQLHelper.reset_autoinc_sequence_to_max klass
          end
        end
      end

      private 

      def table_name_models
        Hash[
        ]
        h = {}
        TABLES.each do |table_name| 
          klass = ("raw_"+table_name).classify
          eval %Q{
            class ::#{klass} < ActiveRecord::Base
              set_table_name :#{table_name}
            end
          }
          h[table_name] = klass.constantize
        end
        h
      end

    end
  end
end

require 'rake'

module PersonasDBHelper
  class << self

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def base_file_name
      'empty_medienarchiv_instance_with_personas'
    end

    def current_db_version
      ActiveRecord::Migrator.current_version
    end

    def clone_persona_to_test_db
      persona_config = check_for_persona_db_config
      persona_database_name = persona_config['database']
      #ActiveRecord::Base.connection_pool.disconnect!
      ActiveRecord::Base.remove_connection
      DBHelper.terminate_open_connections Rails.configuration.database_configuration[Rails.env]
      ActiveRecord::Base.establish_connection(persona_config) 
      DBHelper.drop(Rails.configuration.database_configuration[Rails.env])
      if SQLHelper.adapter_is_postgresql?
        DBHelper.create_from_template(Rails.configuration.database_configuration[Rails.env],persona_config)
      else
        DBHelper.create_from_template_for_mysql(Rails.configuration.database_configuration[Rails.env], {:template_config => persona_config})
      end
      #ActiveRecord::Base.connection_pool.disconnect! 
      ActiveRecord::Base.remove_connection
      ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration[Rails.env])
    end

    def load_and_migrate_persona_data
      config = check_for_persona_db_config
      persona_path = PersonasDBHelper.path_to_native_dump
      puts "Restoring static persona DB file '#{persona_path}' and migrating '#{config['database']}' database to latest version."
      DBHelper.restore_native persona_path, {:config => config}
      puts `bundle exec rake db:migrate 2>&1 RAILS_ENV=personas`
      unless  $?.exitstatus == 0
        puts "MIGRATION FAILED"
        exit $?.exitstatus
      else
        puts "migration succeeded"
        $?.exitstatus
      end
    end

    def check_for_persona_db_config
      config = Rails.configuration.database_configuration['personas']
      if config.nil?
        raise "You need to define a 'personas' database section in your database.yml and then load and migrate a current dump using PersonasDBHelper.load_and_migrate_persona_data"
      else
        return config
      end
    end

    def path_to_native_dump
      Rails.root.join('db',"#{base_file_name}.#{DBHelper.file_extension}")
    end

     def restore_personas_to_max_migration
      config = check_for_persona_db_config
      PersonasDBHelper.load_and_migrate_persona_data # Does not need 'config', it always works in the 'personas' env
    end
  end
end

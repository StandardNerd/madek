# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Permissions

    def self.included(base)

      base.class_eval do

        extend(ClassMethods) # look way below

        has_many :userpermissions, :dependent => :destroy do
          def allows(user, action)
            where(:user_id => user, action => true).exists?
          end
          def disallows(user, action)
            where(:user_id => user, action => false).exists?
          end
        end
        
        has_many :grouppermissions, :dependent => :destroy do
          def allows(user, action)
            joins('INNER JOIN "groups_users" ON "groups_users"."group_id" = "grouppermissions"."group_id"').
            where(action => true, :groups_users => {:user_id => user}).exists?
          end
        end

      end
    end


    def is_public?
      view?
    end

    def is_private?(user)
      (user_id == user.id and
        not is_public? and
        not userpermissions.where(:view => true).where(["user_id != ?", user]).exists? and
        not grouppermissions.where(:view => true).exists?)
    end

    def is_shared?(user)
      not is_public? and not is_private?(user)
    end


    #############################################
  
    module ClassMethods 

      def userpermissions_disallowed user,action
        Userpermission.where(action => false, :user_id => user)
      end

      def grouppermissions_not_disallowed user,action
        Grouppermission 
          .where(action => true)
          .joins("INNER JOIN groups_users ON groups_users.group_id = grouppermissions.group_id ")
          .where("groups_users.user_id = #{user.id}")
          .where <<-SQL  
              media_resource_id NOT IN ( 
                  #{userpermissions_disallowed(user, action).select("media_resource_id").to_sql} 
              )
              SQL
      end

      ##############################

      # TODO: try to dry user and group to subject
      def accessible_by_user(user, action = :view)
        action = (action || :view).to_sym

        if user.nil? or user.is_guest?
          if action == :manage
            where("0=1")
          else
            where(action => true)
          end
        else
          resource_ids_by_userpermission = Userpermission.select("media_resource_id").where(action => true, :user_id => user)
          subquery = if action == :manage
            resource_ids_by_ownership = MediaResource.select("media_resources.id").where(["media_resources.user_id = ?", user])
            "#{resource_ids_by_userpermission.to_sql}
              UNION
            #{resource_ids_by_ownership.to_sql}"
          else
            resource_ids_by_ownership_or_public_permission = MediaResource.select("media_resources.id").where(["media_resources.user_id = ? OR media_resources.#{action} = ?", user, true])
            "#{resource_ids_by_userpermission.to_sql}
              UNION
            #{grouppermissions_not_disallowed(user,action).select("media_resource_id").to_sql}
              UNION
            #{resource_ids_by_ownership_or_public_permission.to_sql}"
          end
          where("media_resources.id IN (#{subquery})")
        end
      end
      
      def accessible_by_group(group, action = :view)
        action = (action || :view).to_sym
        return where("0=1") if action == :manage

        # TODO inner join sql
        resource_ids_by_grouppermission = Grouppermission.select("media_resource_id").where(action => true, :group_id => group)
        where(:id => resource_ids_by_grouppermission)
      end
      
      # TODO merge to accessible_by_user with additional argument
      def entrusted_to_user(user, action = :view)
        action = (action || :view).to_sym
        resource_ids_by_userpermission = Userpermission.select("media_resource_id").where(action => true, :user_id => user)
        subquery = if action == :manage
          resource_ids_by_userpermission.to_sql
        else
          "#{resource_ids_by_userpermission.to_sql}
            UNION
          #{grouppermissions_not_disallowed(user,action).select("media_resource_id").to_sql}"
        end
        where("media_resources.id IN (#{subquery})")
      end

    end

  end

end



# -*- encoding : utf-8 -*-
class GroupsController < ApplicationController
  include SQLHelper

  before_filter do
    unless (params[:group_id] ||= params[:id]).blank?
      @group = current_user.groups.find(params[:group_id])
    end
  end

######################################################

  ##
  # Get a collection of Groups
  # 
  # @resource /groups
  #
  # @action GET
  # 
  # @optional [String] query The search query to find matching groups 
  #
  # @example_request {}
  # @example_response [{"id":1,"name":"Editors"},{"id":2,"name":"Archiv"},{"id":3,"name":"Experts"}] 
  #
  # @example_request {"query": "editors"}
  # @example_response [{"id":1,"name":"Editors"}] 
  #
  def index(query = params[:query])
    respond_to do |format|
      format.html {
        @groups = current_user.groups
        @private_groups = @groups.select{|g| g.type == "Group" and not g.is_readonly?}
        @system_groups = @groups.select{|g| g.type == "Group" and g.is_readonly?}
        @department_groups = @groups.select{|g| g.type == "MetaDepartment"}
      }
      format.json {
        # OPTIMIZE index groups to fulltext ??
        groups = 
          if  adapter_is_mysql?
            Group.where("name LIKE :query OR ldap_name LIKE :query", {:query => "%#{query}%"})
          elsif adapter_is_postgresql?
            Group.where("name ILIKE :query OR ldap_name ILIKE :query", {:query => "%#{query}%"})
          else 
            raise "sql adapter is not supported"
          end
        render :partial => "groups/index.json.rjson", :locals => {:groups => groups}
      }
    end
  end

  def show
    respond_to do |format|
      format.json { 
        @include_users = params[:include_users] and params[:include_users] == 'true'
        @users = @group.type != "MetaDepartment" ?  @group.users : []
        render :partial => "groups/group.json.rjson", :locals => {:group => @group, :users => @users}
      }
    end
  end

  def new
    @group = current_user.groups.build
  end
  
  ##
  # Create group:
  # 
  # @resource /groups
  #
  # @action POST
  # 
  # @required [String] name The name of the group that has to be created. 
  #
  # @example_request {"name": "Librarian-Workgroup"}
  # @example_request_description This creates a group with the name "Librarian-Workgroup"
  # @example_respons {"id": 6, "name": "Librarian-Workgroup"}
  # @example_response_description The response contains the new created group.
  # 
  # @response_field [Integer] id The id of the new group.
  # @response_field [Sgtring] name The name of the new group.
  # 
  def create(name = params[:name] || raise("Name has to be present."))
    group = current_user.groups.create(params[:group])
    
    respond_to do
      format.json{
        if group.persisted?
          render :partial => group
        else
          render :json => {:error => group.errors.full_messages}, :status => :bad_request 
        end        
      }
    end
  end

  def edit
    not_authorized! and return if @group.is_readonly?
    # TODO authorized?
  end

  def update
    not_authorized! and return if @group.is_readonly?
    # TODO authorized?
    @group.update_attributes(params[:group])
    respond_to do |format|
      format.html { redirect_to edit_group_path(@group) }
      format.js { render :text => @group.name } # OPTIMIZE
    end
  end

  def destroy
    not_authorized! and return if @group.is_readonly?
    @group.destroy
    redirect_to groups_path
  end

######################################################

  # TODO refactor to update method and use accepted_nested_attributes ?? 
  def membership
    @user = User.find(params[:user_id])
    if request.post?
      @group.users << @user
      respond_to do |format|
        format.js { render :partial => "user", :object => @user }
      end
    elsif request.delete?
      @group.users.delete(@user)
      respond_to do |format|
        format.js { render :nothing => true } # TODO check if successfully deleted
      end
    end
  end

end

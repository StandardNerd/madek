# -*- encoding : utf-8 -*-
class MediaEntriesController < ApplicationController

  before_filter do
    if [:edit_multiple, :update_multiple, :remove_multiple].include? request[:action].to_sym
      begin
        if !params[:media_set_id].blank?
          action = case request[:action].to_sym
            when :remove_multiple
              :edit
          end
          @media_set = MediaSet.accessible_by_user(current_user, action).find(params[:media_set_id])
        elsif !params[:media_entry_ids].blank?
          selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
          action = case request[:action].to_sym
            when :edit_multiple, :update_multiple
              :edit
            when :remove_multiple
              :view
          end
          @media_entries = MediaEntry.accessible_by_user(current_user, action).find(selected_ids)
        else
          flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
          redirect_to :back
        end
      rescue
        not_authorized!
      end

    else

      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      @media_set = (@user? @user.media_sets : MediaSet).find(params[:media_set_id]) unless params[:media_set_id].blank? # TODO shallow
  
      unless (params[:media_entry_id] ||= params[:id] || params[:media_entry_ids]).blank?
        action = case request[:action].to_sym
          when :show, :map, :browse, :media_sets
            :view
          when :update
            :edit
          when :document
            :download
        end
  
        begin
          @media_entry =  if @media_set
                            @media_set.child_media_resources.media_entries.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          elsif @user
                            @user.media_entries.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          # TODO if @user and @media_set ??
                          else
                            MediaResource.media_entries_or_media_entry_incompletes.accessible_by_user(current_user, action).find(params[:media_entry_id])
                          end
        rescue
          not_authorized!
        end
      end
    end

  end

#####################################################
  
  before_filter lambda{
    @main_context_group = MetaContextGroup.sorted_by_position.first
    other_context_groups = MetaContextGroup.where(MetaContextGroup.arel_table[:position].not_eq(1)).sorted_by_position
    @other_relevant_context_groups = other_context_groups.select do |meta_context_group|
      meta_context_group.meta_contexts.select{ |meta_context|
        @media_entry.meta_data.for_context(meta_context, false).any?
      }.any? or (meta_context_group.meta_contexts & @media_entry.individual_contexts).any?
    end
  }, :only => [:show, :map, :more_data, :parents, :context_group]

  def show
    respond_to do |format|
      format.html {
        @core_context = MetaContext.core
        @core_meta_data = @media_entry.meta_data.for_context @core_context
        @can_download = current_user.authorized?(:download, @media_entry)
        @original_file = @media_entry.media_file
        @original_file_available = (@original_file and File.exist?(@original_file.file_storage_location)) # NOTE it could be a zip file
        @format_original_file = view_context.file_format_for(@original_file)
        @x_large_file = @media_entry.media_file.get_preview(:x_large)
        @x_large_file_available = (@x_large_file and File.exist?(@x_large_file.full_path))
      }
      format.xml { render :xml=> @media_entry.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end
  end

  def document
    respond_to do |format|
      format.html
    end
  end
  
  def map
    meta_data = @media_entry.media_file.meta_data
    @lat = meta_data["GPS:GPSLatitude"]
    @lng = meta_data["GPS:GPSLongitude"]

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def browse
  end

  def more_data
    @edit_sessions = @media_entry.edit_sessions.limit(5)
    @objective_meta_data = [["Filename", @media_entry.media_file.filename]] + @media_entry.media_file.meta_data_without_binary.sort
  end

  def parents
    @parents = @media_entry.parents.accessible_by_user(current_user)
  end

  def context_group
    @context_group = MetaContextGroup.find_by_name(params[:name]) || raise("No MetaContextGroup found")
    # @meta_contexts = (@context_group.meta_contexts & @media_entry.individual_contexts) |
    #   @context_group.meta_contexts.select{ |meta_context| @media_entry.meta_data.for_context(meta_context, false).any? }

    @meta_contexts = @context_group.meta_contexts.select {|mc| (not mc.individual_context?) or @media_entry.individual_contexts.include?(mc) }

  end
  
#####################################################

  ##
  # Manage parent media sets from a specific media entry.
  # 
  # @url [POST] /media_entries/media_sets?[arguments]
  # @url [DELETE] /media_entries/media_sets?[arguments]
  # 
  # @argument [parent_media_set_ids] array The ids of the parent media sets to remove/add
  # @argument [media_entry_ids] array The ids of the entries that have to be added to the sets given as "parent_media_set_ids"
  #
  # @example_request
  #   {"parent_media_set_ids": [1,2,3], "media_entry_ids": [5,6,7]}
  #
  # @request_field [Array] media_set_ids The ids of the parent media sets to remove/add  
  #
  # @example_response
  #   [{"id":407},{"id":406}]
  # 
  # @response_field [Integer] id The id of a removed or an added parent set 
  # 
  def media_sets(parent_media_set_ids = params[:parent_media_set_ids])
    parent_media_sets = MediaSet.accessible_by_user(current_user, :edit).where(:id => parent_media_set_ids.map(&:to_i))

    parent_media_sets.each do |media_set|
      if request.post?
        media_set.child_media_resources << @media_entry
      else
        media_set.child_media_resources.delete(@media_entry)
      end
    end
    
    respond_to do |format|
      format.json {
        render json: view_context.json_for(parent_media_sets)
      }
    end
  end

  # TODO refactor to KeywordsController#index
  def keywords

    # FIXME all fetch keywords associated to media_resources I can see ??   
    @all_keywords = Keyword.select("*, COUNT(*) AS q").group(:meta_term_id).order("q DESC")
    @my_keywords = Keyword.select("*, COUNT(*) AS q").where(:user_id => current_user).group(:meta_term_id).order("q DESC")
    
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
#####################################################
# BATCH actions

  def remove_multiple
    @media_set.child_media_resources.delete(@media_entries)
    flash[:notice] = "Die Medieneinträge wurden aus dem Set gelöscht."
    redirect_to media_set_url(@media_set)
  end
  
  def edit_multiple
    labels = ["title", "author", "uploaded at", "uploaded by", "keywords", "copyright notice", "portrayed object dates"]
    @info_to_json = @media_entries.map do |me|
      core_info = view_context.hash_for(me, {:image => {:as => "base64"}})
      # TODO add more attributes using hash_for helper as here before
      labels.each do |label|
        core_info[label.gsub(' ', '_')] = ""
      end
      me.meta_data.get_for_labels(labels).each do |md|
        core_info[md.meta_key.label.gsub(' ', '_')] = md.to_s
      end
      me.attributes.merge!(core_info)
    end.to_json
  end
  
  def update_multiple
    @media_entries.each do |media_entry|
      if media_entry.update_attributes(params[:resource], current_user)
        flash[:notice] = "Die Änderungen wurden gespeichert." # TODO appending success message and resource reference (id, title)
      else
        flash[:error] = "Die Änderungen wurden nicht gespeichert." # TODO appending success message and resource reference (id, title)
      end
    end
    
    redirect_back_or_default(media_resources_path)
  end
  
end

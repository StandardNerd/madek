# -*- encoding : utf-8 -*-
class MetaDataController < ApplicationController

  layout "meta_data"

  before_filter do
    unless (params[:media_resource_id] ||= params[:media_entry_id] || params[:media_set_id] || params[:collection_id]).blank?
      action = case request[:action].to_sym
        when :index
          :view
        when :edit, :update, :edit_multiple, :update_multiple
          :edit
      end
      
      begin
        media_resource_ids = (params[:collection_id] ? MediaResource.by_collection(current_user.id, params[:collection_id]) : params[:media_resource_id])
        @resource = MediaResource.accessible_by_user(current_user, action).find(media_resource_ids)
      rescue
        not_authorized!
      end
    end
    
    @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
    @context ||= MetaContext.core
  end

#################################################################
  

  def index
    @meta_data = @resource.meta_data.for_context(@context, false)
    respond_to do |format|
      format.js { render :layout => (params[:layout] != "false") }
      format.json {
        with = {:label => {:context => @context.name}}
        render :json => view_context.json_for(@meta_data, with)
      }
    end
  end

  ### 
  # PUT /media_resources/1/meta_data/title {value: "My new title"}
  #
  def update(meta_key_name = params[:id],
             value = params[:value])
    
    attrs = {"meta_data_attributes"=>
                {
                  "0"=>{"meta_key_label" => meta_key_name, "value" => value}
                }
            }
    
    media_resources = Array(@resource)
    
    begin
      media_resources.each do |media_resource|
        media_resource.update_attributes(attrs, current_user)
      end      
      
      respond_to do |format|
        format.json { render json: {} }
      end
    rescue => e
      respond_to do |format|
        format.json { render json: e.to_s, status: :unprocessable_entity }
      end
    end
  end

#################################################################

  def edit_multiple
    meta_data = @resource.meta_data.for_context(@context)
    respond_to do |format|
      format.js { render :partial => "edit_multiple_without_form", :locals => {:context => @context, :meta_data => meta_data } }
    end
  end

  def update_multiple
    if @resource.update_attributes(params[:resource], current_user)
      flash[:notice] = "Die Änderungen wurden gespeichert."
    else
      flash[:error] = "Die Änderungen wurden nicht gespeichert."
    end

    respond_to do |format|
      format.html {
        redirect_to @resource
      }
    end
  end

end

class AppAdmin::MediaFilesController < AppAdmin::BaseController
  def index

    @media_files = MediaFile.order("created_at DESC").page(params[:page])

    if !params[:fuzzy_search].blank?
      @media_files= @media_files.fuzzy_search(params[:fuzzy_search])
    end

    if !params[:incomplete_encoded_videos].blank?
      @media_files = @media_files.send(:incomplete_encoded_videos)
    end

    if !params[:only_with_media_entry].blank?
      @media_files = @media_files.joins(:media_entry)
    end


  end

  def show
    @media_file = MediaFile.find params[:id]
  end

  def reencode
    begin 
      @media_file = MediaFile.find params[:id]
      @media_file.previews.destroy_all
      ZencoderJob.create(media_file: @media_file).submit
      redirect_to app_admin_media_file_path(@media_file), flash: {success: "The Zencoder.job has been submitted"}
    rescue => e 
      redirect_to app_admin_media_file_path(@media_file), flash: {error: e}
    end

  end

  def reencode_incomplete_videos 
    MediaFile.joins(:media_entry).incomplete_encoded_videos.each do |media_file|

      begin
        ActiveRecord::Base.transaction do
          media_file.previews.destroy_all
          ZencoderJob.create(media_file: media_file).submit
        end
      rescue => e
        logger.error Formatter.error_to_s(e)
      end

      redirect_to :back, flash: {success: "The jobs have been submitted."}
    end
  end

  def recreate_thumbnails
    begin 
      @media_file = MediaFile.find params[:id]
      @media_file.previews.destroy_all
      @media_file.make_thumbnails
      redirect_to app_admin_media_file_path(@media_file), flash: {success: "The thumbnails have been recreated"}
    rescue => e 
      redirect_to app_admin_media_file_path(@media_file), flash: {error: e}
    end
  end

end

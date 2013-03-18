class ZencoderJobsController < ActionController::Base

  def post_notification
    begin 
      @job = ZencoderJob.find params[:id]
      if @job.state == 'submitted'
        # TODO check if response is an error and set state to failed 
        @job.update_attributes notification: params
        @job.import_previews #error handling within @job
      end
    ensure
      # always respond with OK 
      respond_to  do |format|
        format.json{ render json: {}.to_json }
      end
    end
  end
end

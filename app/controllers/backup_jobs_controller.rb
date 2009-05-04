class BackupJobsController < ApplicationController

  def create
    begin
      b=BackupJob.create_from_params(params)
      resp={:success=>true, :backup_job=>b.attributes}
    rescue
      resp={:success=>false, :error=>$!.to_s}
    end

    respond_to do |fmt|
      fmt.html { render :text=>"Hi!" }
      fmt.json do 
        render :json=>resp
      end
    end
  end

  def index
    respond_to do |fmt|
      fmt.html { render :text=>"Hi!" }
    end
  end
end

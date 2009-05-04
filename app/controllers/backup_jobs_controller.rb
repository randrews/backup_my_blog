class BackupJobsController < ApplicationController

  def create
    with_error_trap do
      b=BackupJob.create(:url=>params[:url])
      b.save!
      {:backup_job=>b.attributes}
    end
  end

  def show
    with_error_trap do
      b=BackupJob.find(params[:id])
      {:backup_job=>b.attributes}
    end
  end

  def start
    with_error_trap do
      b=BackupJob.find(params[:id])
      raise "This job is already running" if b.status=="running"
      raise "This job has failed" if b.status=="error"

      # We'll pretend to start it
      b.status='running'
      b.save!

      {:backup_job=>b.attributes}
    end
  end

  def index
    respond_to do |fmt|
      fmt.html { render :text=>"Hi!" }
    end
  end

  private

  def with_error_trap
    begin
      obj=yield
      obj[:success]=true
      obj
    rescue
      obj={:success=>false, :error=>$!.to_s}
    end

    respond_to do |fmt|
      fmt.json { render :json=>obj }
    end
  end
end

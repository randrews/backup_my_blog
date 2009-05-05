class BackupJobsController < ApplicationController

  # Make a BackupJob with the URL, and save it
  # so if it fails to validate we'll know about it.
  def create
    with_error_trap do
      b=BackupJob.create(:url=>params[:url])
      b.save!
      {:backup_job=>b.attributes}
    end
  end

  # Find and show a job. We also need to render the filename,
  # so te interface can make a link to it.
  def show
    with_error_trap do
      b=BackupJob.find(params[:id])
      fname=File.basename(b.filename)
      {:backup_job=>b.attributes, :download_url=>"/finished-jobs/#{fname}"}
    end
  end

  # Start running a job.
  def start
    with_error_trap do
      b=BackupJob.find(params[:id])

      # Catch a few plausible errors
      raise "This job is already running" if b.status=="running"
      raise "This job has failed" if b.status=="error"

      # We'll use Spawn to make sure this happens asynch
      spawn do
        b.run
      end

      # No response needed here, just the
      # :success=>true that with_error_trap adds.
      {}
    end
  end

  # Just show the template. There's not even any ERb in it.
  def index
    respond_to do |fmt|
      fmt.html
    end
  end

  private

  # This will yield, and if anything is raised,
  # render a JSON object with an error.
  # The interface is smart enough to display these
  # correctly.
  #
  # Pretty much every action uses this, which makes
  # them small and pithy.
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

require "config/environment.rb"
require 'action_controller/integration'

describe "BackupJobsController" do

  before :all do
    @me="http://rbandrews.livejournal.com"
    @app=ActionController::Integration::Session.new
  end

  it "should be able to create a BackupJob given a URL" do
    @app.post('/backup_jobs.json',{:url=>@me}).should==200
    json=ActiveSupport::JSON.decode(@app.response.body)
    json['success'].should==true
    json['backup_job']['id'].nil?.should==false
    json['backup_job']['url'].should==@me
    json['backup_job']['status'].should=='new'
  end

  it "should fail to make a BackupJob with no URL" do
    @app.post('/backup_jobs.json',{:url=>nil}).should==200
    json=ActiveSupport::JSON.decode(@app.response.body)
    json['success'].should==false
    json['error'].nil?.should==false
    puts json["error"]
  end

  it "should show one that I just made" do
    made=make_job(@me)
    id=made['id']

    @app.get("/backup_jobs/#{id}.json").should==200
    job=ActiveSupport::JSON.decode(@app.response.body)

    job['success'].should==true
    job['backup_job']['url'].should==made['url']
  end

  it "should fail to find a bad one" do
    @app.get("/backup_jobs/bad-id.json").should==200
    job=ActiveSupport::JSON.decode(@app.response.body)

    job['success'].should==false
    job['error'].nil?.should==false
  end

  it "should start a job" do
    `rm -f public/finished-jobs/*`
    id=make_job(@me)['id']

    @app.post("/backup_jobs/start/#{id}.json").should==200
    json=ActiveSupport::JSON.decode(@app.response.body)
    json['success'].should==true

    loop do
      b=BackupJob.find(id)
      if b.status=='running'
        File.exists?(b.filename).should==true
        break
      end
      sleep(1) # Wait a sec to make sure it's going.
    end
  end

  it "should finish a job correctly" do
    id=make_job(@me)['id']
    @app.post("/backup_jobs/start/#{id}.json").should==200

    n=0
    loop do
      n+=1
      status=job_status(id)['status']
      break if status!='new' and status!='running'
      sleep(1)

      # Wait five minutes, then bail
      raise "This job appears to be stuck" if n>300
    end

    job=job_status(id)
    job['status'].should=='finished'
    job['error'].nil?.should==true
  end

  ##################################################

  def make_job url
    @app.post('/backup_jobs.json',{:url=>url}).should==200
    json=ActiveSupport::JSON.decode(@app.response.body)
    json['backup_job']
  end

  def job_status id
    @app.get("/backup_jobs/#{id}.json").should==200
    ActiveSupport::JSON.decode(@app.response.body)['backup_job']
  end

end

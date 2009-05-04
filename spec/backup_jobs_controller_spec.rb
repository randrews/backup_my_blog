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
    @app.post('/backup_jobs.json',{:url=>@me}).should==200
    json=ActiveSupport::JSON.decode(@app.response.body)

    id=json['backup_job']['id']
    @app.get("/backup_jobs/#{id}.json").should==200
    job=ActiveSupport::JSON.decode(@app.response.body)

    job['success'].should==true
    job['backup_job']['url'].should==json['backup_job']['url']
  end

  it "should fail to find a bad one" do
    @app.get("/backup_jobs/bad-id.json").should==200
    job=ActiveSupport::JSON.decode(@app.response.body)

    job['success'].should==false
    job['error'].nil?.should==false
  end

  it "should start a job" do
    @app.post('/backup_jobs.json',{:url=>@me}).should==200
    json=ActiveSupport::JSON.decode(@app.response.body)
    json['backup_job']['status'].should=='new'

    id=json['backup_job']['id']
    @app.post("/backup_jobs/start/#{id}.json").should==200
    json=ActiveSupport::JSON.decode(@app.response.body)
    json['success'].should==true

    sleep(1) # Wait a sec to make sure it's going.
    b=BackupJob.find(id)
    File.exists?(b.filename).should==true
  end
end

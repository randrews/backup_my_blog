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
end

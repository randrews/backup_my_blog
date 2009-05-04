require "config/environment.rb"

describe "BackupJob" do
  before :all do
    @me="http://rbandrews.livejournal.com"
    @yegge="http://steve-yegge.blogspot.com/"
  end

  after :all do
    `rm -rf public/finished-jobs/*.txt`
  end

  it "should finish successfully with a good URL" do
    b=BackupJob.new(:url=>@me)
    b.run
    b.status.should=="finished"
    b.error.nil?.should==true
  end

  it "should go into error with a bad URL" do
    b=BackupJob.new(:url=>@me+"/kwyjibo")
    b.run
    b.status.should=="error"
    b.error.nil?.should==false # As long as there's an error there.    
  end

  it "should start in the 'new' state" do
    b=BackupJob.new(:url=>@me)
    b.status.should=="new"
    b.error.nil?.should==true
  end

  it "should populate total" do
    b=BackupJob.new(:url=>@me) # Using Yegge makes the specs take WAY too long.
    b.run
    b.total.should==b.finished
    b.total.should>0
  end

end

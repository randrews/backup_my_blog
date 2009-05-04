require "config/environment.rb"

describe "RssPull" do
  before :all do
    @me=RssPull.new("http://rbandrews.livejournal.com")
    @yegge=RssPull.new("http://steve-yegge.blogspot.com/")
  end

  it "should load a URL at all" do
    @me.doc.nil?.should==false
  end

  it "should find the correct RSS URL for my blog, and Steve Yegge's blog" do
    @me.rss_url.should=="http://rbandrews.livejournal.com/data/rss"
    @yegge.rss_url.should=="http://steve-yegge.blogspot.com/feeds/posts/default?alt=rss"
  end

  it "should find the correct ATOM URL for my blog, and Steve Yegge's blog" do
    @me.atom_url.should=="http://rbandrews.livejournal.com/data/atom"
    @yegge.atom_url.should=="http://steve-yegge.blogspot.com/feeds/posts/default"
  end

  it "should make an RSS reader successfully" do
    @me.rss.nil?.should==false
  end

  it "should make an ATOM reader successfully" do
    @me.rss(@me.atom_url).nil?.should==false
  end
end

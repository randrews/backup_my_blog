class RssPull
  attr_reader :doc

  def initialize url
    @url=url
    @doc=Hpricot(open(url))
    self
  end

  def atom_url
    type_rel_url "application/atom+xml"
  end

  def rss_url
    type_rel_url "application/rss+xml"
  end

  def rss first_preference=rss_url, second_preference=atom_url
    url= first_preference or second_preference
    raise "No RSS or ATOM feed found in this page's metadata" if url.nil?
    SimpleRSS.parse(open(url).read)
  end

  def each
    raise "Expected a block" unless block_given?
    rss.items.each do |item|
      yield item
    end
  end

  private

  def type_rel_url type
    els=doc.search("head/link[@rel='alternate'][@type='#{type}']")
    raise "No URLs of type #{type} found" if els.size==0
    els[0]['href']
  end 
end

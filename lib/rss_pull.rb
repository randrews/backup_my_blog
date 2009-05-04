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

  def to_s
    "<RssPull #{@url}>"
  end

  private

  def type_rel_url type
    els=doc.search("head/link[@rel='alternate'][@type='#{type}']")
    raise "No URLs of type #{type} found" if els.size==0
    els[0]['href']
  end 
end

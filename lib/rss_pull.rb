# This is a utility class to isolate Hpricot and SimpleRSS stuff.
# There are a bunch of specs for it in spec/rss_pull_spec.rb
class RssPull
  attr_reader :doc

  def initialize url
    @url=url
    @doc=Hpricot(open(url))
    self
  end

  # These give you the URL for the kind of feed, or raise an error.
  def atom_url
    type_rel_url "application/atom+xml"
  end

  def rss_url
    type_rel_url "application/rss+xml"
  end

  # This gives you a SimpleRss on either the RSS or ATOM URL, first one that's there, or raises an error
  # It memoizes the SimpleRSS, so it only costs you anything to call it the first time.
  def rss first_preference=:rss_url, second_preference=:atom_url
    return @rss if @rss

    url= send(first_preference) or send(second_preference) rescue raise("No RSS or ATOM feed found in this page's metadata")
    @rss=SimpleRSS.parse(open(url).read)
  end

  # Iterates over the items in the feed.
  def each
    raise "Expected a block" unless block_given?
    rss.items.each do |item|
      yield item
    end
  end

  # For gauging progress.
  def num_items
    rss.items.size
  end

  private

  # Return a url from @doc where the rel="alternate" and the type="whatever".
  # Or raise an error.
  def type_rel_url type
    els=doc.search("head/link[@rel='alternate'][@type='#{type}']")
    raise "No URLs of type #{type} found" if els.size==0
    uri=URI.parse els[0]['href']
    if uri.relative?
      URI.parse(@url).merge(uri).to_s
    else
      uri.to_s
    end
  end 
end

class BackupJob < ActiveRecord::Base
  validates_presence_of :url

  # Actually run the job. Called by Spawn.
  def run
    begin
      # make an rss_pull
      rss_pull=RssPull.new(url) rescue raise("This seems to be a bad URL. Did you include the http:// ?")

      # set total, so we can say "0 of 25"
      self.total=rss_pull.num_items

      # Now that everything's there to start doing items, we'll run.
      self.status='running' ; save

      # For each item, do it, then 
      # increment self.finished.
      rss_pull.each do |item|
        handle_item item
        self.finished+=1 ; save
      end

      # Clean up the filehandle.
      file_handle.close

      # And we're through.
      self.status='finished' ; save
    rescue
      file_handle.close rescue nil

      # If something went wrong, stuff it in self.error,
      # set the status, and we'll wait for the poller to
      # display it.
      self.error=$!.to_s
      self.status='error'
      save
    end
  end

  # The filename for this feed.
  # We're sticking everything in public/finished-jobs.
  # The filenames are a SHA1 hash of the URL of the job,
  # since URLs can have disallowed characters in them (like /) and SHA1 is all hex.
  def filename
    File.join(%w{public finished-jobs},Digest::SHA1.hexdigest(url)+".txt")
  end

  private

  # Called for each item, we print a banner,
  # then write it out, then write a couple newlines
  # to separate the next banner.
  def handle_item item
    separator item.link
    file_handle.write(open(item.link).read)
    file_handle.write("\n\n")
  end

  # Prints out a big banner-like thing to separate RSS items.
  def separator item_url
    file_handle.write("#"*80+"\n")
    file_handle.write("# #{item_url}\n")
    file_handle.write("#"*80+"\n\n")
  end

  # Makes the filehandle for us to write out RSS items as we read them
  def file_handle
    @file_handle ||= File.open(filename,'w')
  end

end

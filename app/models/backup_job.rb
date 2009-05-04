class BackupJob < ActiveRecord::Base

  def run
    begin
      self.status='running' ; save

      rss_pull=RssPull.new(url)

      self.total=rss_pull.num_items ; save

      rss_pull.each do |item|
        handle_item item
        self.finished+=1 ; save
      end

      file_handle.close

      self.status='finished' ; save
    rescue
      self.error=$!.to_s
      self.status='error'
      save
    end
  end

  private

  def handle_item item
    separator item.link
    file_handle.write(open(item.link).read)
    file_handle.write("\n\n")
  end

  def separator item_url
    file_handle.write("#"*80+"\n")
    file_handle.write("# #{item_url}\n")
    file_handle.write("#"*80+"\n\n")
  end

  def file_handle
    @file_handle ||= File.open(filename,'w')
  end

  def filename
    File.join(%w{public finished-jobs},Digest::SHA1.hexdigest(url)+".txt")
  end

end

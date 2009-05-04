class BackupJob < ActiveRecord::Base

  def run
    begin
      self.status='running' ; save

      rss_pull=RssPull.new(url)

      self.total=rss_pull.num_items ; save

      rss_pull.each do |item|
        logger.info "I should be saving #{item.link} right now"

        self.finished+=1 ; save
      end

      self.status='finished' ; save
    rescue
      self.error=$!.to_s
      self.status='error'
      save
    end
  end

end

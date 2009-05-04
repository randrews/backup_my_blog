class BackupJob < ActiveRecord::Base

  def run
    begin
      self.status='running' ; save

      RssPull.new(url).each do |item|
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

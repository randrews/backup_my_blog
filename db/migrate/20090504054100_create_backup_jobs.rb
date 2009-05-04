class CreateBackupJobs < ActiveRecord::Migration
  def self.up
    create_table :backup_jobs do |t|
      t.integer :total
      t.integer :finished, :default=>0
      t.string :path # Directory where we'll find all the blog postings, as we download them
      t.string :url, :required=>true # Base URL that we're backing up.
      t.string :status, :default=>'new' # Jobs have statuses, new -> running -> {finished, error}
      t.string :error # Where we'll store the error message if it failed.
      t.timestamps
    end
  end

  def self.down
    drop_table :backup_jobs
  end
end

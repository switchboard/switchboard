class AddDbFileIdToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :db_file_id, :integer
  end

  def self.down
    remove_column :attachments, :db_file_id
  end
end

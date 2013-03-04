class AddAttachmentCsvFileToLists < ActiveRecord::Migration
  def up
    change_table :lists do |t|
      t.attachment :csv_file
    end
  end

  def down
    drop_attached_file :lists, :csv_file
  end
end

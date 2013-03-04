class RemoveOldAttachmentFuTable < ActiveRecord::Migration
  def up
    drop_table :attachments
  end

  def down
    create_table "attachments", :force => true do |t|
      t.integer "list_id"
      t.string  "content_type"
      t.string  "filename"
      t.string  "thumbnail"
      t.integer "size"
      t.integer "width"
      t.integer "height"
      t.integer "db_file_id"
    end
  end
end

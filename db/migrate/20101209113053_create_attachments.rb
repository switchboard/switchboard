class CreateAttachments < ActiveRecord::Migration
  
  def self.up
    create_table :attachments do |t|
      t.column :list_id,  :integer
      t.column :content_type, :string
      t.column :filename, :string    
      t.column :thumbnail, :string 
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
    end
  end

  def self.down
    drop_table :attachments
  end
end


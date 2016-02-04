class CreateListSentCounts < ActiveRecord::Migration
  # Preventing broken migrations
  class ::List < ActiveRecord::Base
    has_many :sent_counts, as: :countable
  end
  class ::Organization < ActiveRecord::Base
    has_many :sent_counts, as: :countable
  end

  def up
    create_table :sent_counts do |t|
      t.references :countable, polymorphic: true
      t.date :date_ending
      t.integer :month_count
      t.integer :total_count

      t.timestamps
    end

  end

  def down
    drop_table :sent_counts
  end

end

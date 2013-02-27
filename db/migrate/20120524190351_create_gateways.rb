class CreateGateways < ActiveRecord::Migration
  def change
    create_table :gateways do |t|
      t.string :name
      t.float :cost_per_text

      t.timestamps
    end
  end
end

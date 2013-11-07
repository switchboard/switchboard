class AddDefaultLocaleToLists < ActiveRecord::Migration
  def change
    add_column :lists, :default_locale, :string, default: 'en', null: false
  end
end
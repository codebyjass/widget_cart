class CreateOffers < ActiveRecord::Migration[7.2]
  def change
    create_table :offers do |t|
      t.string :type
      t.string :name
      t.string :target_code
      t.decimal :percentage
      t.integer :min_qty
      t.boolean :active

      t.timestamps
    end
  end
end

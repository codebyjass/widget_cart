class CreateDeliveryRules < ActiveRecord::Migration[7.2]
  def change
    create_table :delivery_rules do |t|
      t.integer :threshold_cents
      t.integer :fee_cents

      t.timestamps
    end
  end
end

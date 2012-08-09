class CreateCharges < ActiveRecord::Migration
  def self.up
    create_table :charges do |t|
      t.integer :user_id
      t.decimal :amount, :precision => 6, :scale => 2
      t.string :item_name
      t.integer :item_id
      t.string :transaction_id
      t.string :transaction_status
      t.string :error_message
      t.integer :last_four
      t.string :vault_token
      t.string :subscription_id

      t.timestamps
    end
    
    add_index :charges, [:user_id, :item_name, :item_id], :name => "user_item_purchase_index"
  end

  def self.down
    drop_table :charges
  end
end

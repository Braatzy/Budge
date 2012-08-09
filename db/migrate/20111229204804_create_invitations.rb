class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :user_id
      t.integer :program_id
      t.string :token
      t.string :email
      t.integer :invited_user_id
      t.boolean :visited, :default => false
      t.boolean :signed_up, :default => false
      t.boolean :bought_program, :default => false
      t.decimal :dollars_credit, :precision => 5, :scale => 2

      t.timestamps
    end
    
    add_column :program_players, :testimonial, :text
  end

  def self.down
    drop_table :invitations
    remove_column :program_players, :testimonial
  end
end

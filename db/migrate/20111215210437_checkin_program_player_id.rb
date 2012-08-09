class CheckinProgramPlayerId < ActiveRecord::Migration
  def self.up
    add_column :checkins, :program_player_id, :integer
    
    Checkin.where('player_budge_id is not null AND program_player_id is null').each do |checkin|
      next unless checkin.player_budge.present?
      checkin.update_attributes(:program_player_id => checkin.player_budge.program_player_id)
    end
  end

  def self.down
    remove_column :checkins, :program_player_id
  end
end

class UserJoinedBeta < ActiveRecord::Migration
  def self.up
    add_column :users, :officially_started_at, :datetime
    add_column :users, :cohort_tag, :string
    
    User.where(:in_beta => true).each do |user|
      first_program = user.program_players.select{|pp|pp.program.present? and pp.program.featured?}.sort_by{|pp|pp.created_at}.first
      next unless first_program.present?
      user.update_attributes(:officially_started_at => first_program.created_at)
    end
  end

  def self.down
    remove_column :users, :officially_started
    remove_column :users, :cohort_tag
  end
end

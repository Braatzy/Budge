class UserMetrics < ActiveRecord::Migration
  def up
    add_column :users, :cohort_date, :date
    User.all.each do |user|
      # week the user signed up
      # budge start week is 2011-10-31 (buster's dog food email)
      user.update_attributes(:cohort_date => user.created_at.beginning_of_week)
     end

    create_table :metrics do |t|
      t.date :date
      t.string :status_key
      t.integer :number
      t.string :cohort

      t.timestamps
    end
    
    # backfill the acquisition and activation metrics for each date
    days=(Date.new(2011,11,1)..Date.today)
    days.each do |day|
      begin 
        Metric.acquisition(day)
        Metric.activation(day)
      rescue => e
        p "#{day}: backfilling metrics failed: #{e}"
      end
    end
    
    #get the retention metrics for today
    Metric.retention()
  end

  def down
    remove_column :users, :cohort_date, :date
    remove_table :metrics
  end
end

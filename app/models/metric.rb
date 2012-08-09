class Metric < ActiveRecord::Base
  def self.acquisition(date=Date.today)
    users=User.where("created_at <= ?",date).select('cohort_date')
    Metric.new(:status_key=>'users', :number=>users.size, :date=>date, :cohort=>'all').save()
    
    cohorts=users.group(:cohort_date)
    cohorts.size.each do |cohort_date,size|
      next if size==0
      Metric.new(:status_key=>'users', :number=>size, :date=>date, :cohort=>cohort_date).save()
    end
    
    programs=Program.where('total_players > ? AND featured=?',0,true)
    programs.each do |program|
      count=program.program_players.where("created_at <= ?",date).size
      next if count==0
      Metric.new(:status_key=>"users", :number=>count, :date=>date, :cohort=>"program-#{program.id}").save()
    end
    p "#{date}: saved acquisition metrics"
  end

  activated_states=['engaged', 'snoozing', 'scheduled', 'level limbo', 'off-wagon', 'long-lost']
  #not ['interested', 'no programs', 'no actions']
  def self.activation(date=Date.today)    
    users=User.where("created_at <= ?",date)
    counts_active=Hash.new 0
    
    users.find_each(:batch_size=>10){ |user| counts_active[user.cohort_date]+=1 if user.was_activated_by(date)}
    counts_active.each{ |cohort_date,count| Metric.new(:status_key=>'activated', :number=>count, :date=>date, :cohort=>cohort_date).save() }
    count_active_all=counts_active.values().sum()
    Metric.new(:status_key=>"activated", :number=>count_active_all, :date=>date, :cohort=>"all").save()
    p "#{date}: saved activation metrics"
  end
  
  def self.retention() #only for today - no backfil for now
    date=Date.today
    state_counts=Hash.new {}
    cohort_dates=User.select(:cohort_date).uniq
    cohort_dates.each{|d| state_counts[d.cohort_date]=Hash.new 0}
    state_counts_all=Hash.new 0

    User.select('cohort_date, status').each do |user|
      state_counts[user.cohort_date][user.status]+=1
    end

    state_counts.each do |cohort_date, state_count|
      state_count.each do |state,count|
        Metric.new(:status_key=>"#{state}", :number=>count, :date=>date, :cohort=>cohort_date).save()
        state_counts_all[state]+=count
      end
    end
    state_counts_all.each do |state,count|
      Metric.new(:status_key=>"#{state}", :number=>count, :date=>date, :cohort=>'all').save()
    end
    p "#{date}: saved retention metrics"
  end
  
end

# == Schema Information
#
# Table name: metrics
#
#  id         :integer(4)      not null, primary key
#  date       :date
#  status_key :string(255)
#  number     :integer(4)
#  cohort     :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#


# == Schema Information
#
# Table name: charts
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Chart < ActiveRecord::Base
  
  def self.t2s(t)
    t.strftime '%Y-%m-%d %H:%M'
  end
  
  def self.moving_average(timedata,period=10)
    def self.select_times(timedata,start_time,end_time)
      timedata.select{|t,val| start_time<=t && t<=end_time}
    end
    def self.moving_average_point(t,timedata,period=10,min_num_measurements=4)
      local_timedata=select_times(timedata,t-period.days,t)
      if local_timedata.length < min_num_measurements
        ma=nil
      else
        ma=local_timedata.map{|t,v| v}.sum/local_timedata.length
      end
      return ma
    end    
    moving_avg=[]
    timedata.each do |t,value|
      ma=moving_average_point(t,timedata,period)
      moving_avg.push([t,ma])
    end
    return moving_avg
  end
  def self.break_into_line_segments(true_weight)
    def self.line_append(lines,t,w)
      lines.last.push([t,w])
    end
    def self.line_start(lines,t,w)
      lines.push([[t,w]])
    end    
    lines=[]
    true_weight.each{ |t,w|
      if w.nil?
        next
      elsif lines.length==0
        line_start(lines,t,w)
      elsif (t-lines.last.last[0])/1.day < 7 #if new wiegh-in happens less than 7 days from the last
        line_append(lines,t,w)                 #add the weigh-in to the existing segment
      else                                  #otherwise, start a new line segment
        line_start(lines,t,w)
      end
    }
    return lines.map{ |ln| ln.map{|t,w| [t2s(t),w]} }
  end
  
  
  def self.get_current_weight_direction(raw,smoothed,diff_amount=1.0)
    todays_true = smoothed.nil? ? nil : smoothed.round.to_i
    if todays_true.nil?
      return nil,nil
    else
      diff=raw-smoothed #today's raw - today's true
      if diff>=diff_amount
        todays_direction='headed up'
      elsif diff<=-1*diff_amount
        todays_direction='headed down'
      else
        todays_direction='holding steady'
      end
    end
    return todays_true,todays_direction
  end
end
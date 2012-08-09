class Leader < ActiveRecord::Base
  belongs_to :program
  belongs_to :user
  
  DIRECTION_TOTAL_MAX = 0
  DIRECTION_FREQUENCY_MAX = 1
  DIRECTION_AVERAGE_MAX = 2
  DIRECTION_TOTAL_MIN = 3
  DIRECTION_FREQUENCY_MIN = 4
  DIRECTION_AVERAGE_MIN = 5
  DIRECTION = {DIRECTION_TOTAL_MAX => {:words => "Highest total", :type => :total, :direction => :max},
               DIRECTION_FREQUENCY_MAX => {:words => "Highest frequency", :type => :frequency, :direction => :max},
               DIRECTION_AVERAGE_MAX => {:words => "Highest average", :type => :average, :direction => :max},
               DIRECTION_TOTAL_MIN => {:words => "Lowest total", :type => :total, :direction => :min},
               DIRECTION_FREQUENCY_MIN => {:words => "Lowest frequency", :type => :frequency, :direction => :min},
               DIRECTION_AVERAGE_MIN => {:words => "Lowest average", :type => :average, :direction => :min}}

  def direction_words
    DIRECTION[self.program.leaderboard_trait_direction][:words]
  end
  def direction_type
    DIRECTION[self.program.leaderboard_trait_direction][:type]
  end
  def direct_token
    DIRECTION[self.program.leaderboard_trait_direction][:direction]  
  end
  def self.direction_token(direction)
    DIRECTION[direction][:direction]
  end
  
  def self.ordered_by_words(direction)
    DIRECTION[direction][:words]
  end
  
  # Update all leaders for this date
  def self.update_leaders(date = Time.now.utc.to_date)
  
    # Find all programs that have a leaderboard trait
    Program.all.each do |program|
      program_players = program.program_players.where('DATE(last_visited_at) >= ?', date-30.days)
      program_players.each do |program_player|
        program_player.update_leaderboard_score(date)
      end
    end
  end
  
  def score_hash
    hash = {:amount => self.score}
    if self.program.leaderboard_trait.present?
      trait = self.program.leaderboard_trait
      direction_type = self.direction_type
      if direction_type == :frequency
        hash[:post_text] = (self.score == 1 ? 'day' : 'days')
      else
        if trait.answer_type == ':boolean'
          hash[:post_text] = (self.score == 1 ? 'time' : 'times')
        elsif trait.answer_type == ':miles'
          hash[:post_text] = (self.score == 1 ? self.user.distance_pref : "#{self.user.distance_pref}s")
        elsif trait.answer_type == ':minutes'
          hash[:post_text] = (self.score == 1 ? 'min' : 'mins')
        elsif trait.answer_type == ':pounds'
          hash[:post_text] = (self.score == 1 ? self.user.weight_pref : "#{self.user.weight_pref}s")
        elsif trait.answer_type == ':quantity'
          if trait.noun.present?
            hash[:post_text] = (self.score == 1 ? trait.noun : trait.noun.pluralize)
          else
            hash[:post_text] = (self.score == 1 ? 'time' : 'times')          
          end
        elsif trait.answer_type == ':steps'
            hash[:post_text] = (self.score == 1 ? 'step' : 'steps')
        elsif trait.answer_type == ':text'
            hash[:post_text] = (self.score == 1 ? 'time' : 'times')
        elsif trait.answer_type == ':time'
            hash[:post_text] = (self.score == 1 ? "o'clock" : "o'clock")
        end
      end
    else
      hash[:post_text] = (self.score == 1 ? 'day' : 'days')
    end
    return hash
  end
  
  def self.create_histogram(values, nbins=30,interval=nil)
    return {:behavior=>[], :count=>[]} if values.empty? 
    bins = []
    if interval.nil?
      interval=((values.max-values.min)/nbins).floor
      interval=1 if interval<1
    end

    values.min.step(values.max, interval) { |n| bins << n }
    # p 'interval',interval.to_f
    # p bins.map{|b| b.to_i}
    # p values.map{|b| b.to_i}
    histogram = Hash.new 0

    # find the appropriate "bin" and create the histogram
    values.each do |val|
      bin = bins.find { |bin| val<=bin }
      bin=bins.last if bin.nil? 
      histogram[bin] += 1
    end
    keys=histogram.keys().sort()
    counts=keys.map{|k| histogram[k]}
    # p keys.map{|k| k.to_i}
    # p counts
    return {:behavior=>keys,:count=>counts}
  end
  
  def self.get_stdev(values)
    return nil if values.empty?
    sum=values.inject(0){|accum, i| accum + i }
    mean=sum / values.length.to_f
    sum_squared = values.inject(0){|accum, i| accum + (i - mean) ** 2 }
    variance=sum_squared / (values.length - 1).to_f
    return Math.sqrt(variance)
  end

end

# == Schema Information
#
# Table name: leaders
#
#  id                   :integer(4)      not null, primary key
#  program_id           :integer(4)
#  user_id              :integer(4)
#  date                 :date
#  score                :decimal(10, 3)
#  num_days             :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  total                :decimal(10, 3)
#  average              :decimal(10, 3)
#  program_status       :string(255)
#  last_played_days_ago :integer(4)
#


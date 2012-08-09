desc 'backfill the acquisition metrics for each date' 
task :backfill_acquistition => :environment do
  days=(Date.new(2011,11,1)..Date.today)
  days.each do |day|
    Metric.acquisition(day)
  end
end

desc 'backfill the activation metrics for each date'
task :backfill_activation => :environment do
  days=(Date.new(2011,11,1)..Date.today)
  days.each do |day|
    begin 
      Metric.activation(day)
    rescue
      p "#{day} failed"
    end
  end
end

desc 'get the retention metrics for today'
task :get_retention => :environment do
  Metric.retention()
end
task :get_acquisition=> :environment do
  Metric.acquisition()
end
task :get_activation => :environment do
  Metric.activation()
end

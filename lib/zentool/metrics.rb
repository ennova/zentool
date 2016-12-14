# Represents an aggregate of metrics from multiple tickets 
class Metrics
  attr_accessor :tickets, :tickets_by_age, :tickets_by_user_priority, :tickets_by_development_priority
  def initialize(tickets)
    @tickets = tickets
    # Hash with key as age, and the value as the number of tickets with that age
    @tickets_by_age = {} 
    @tickets_by_age.default_proc = proc { 0 }
    # Hash with key => user_priority, and the value => array of reply times from tickets with that priority
    @tickets_by_user_priority = Hash.new {|h,k| h[k]=[]}
    # Hash with key => development_priority, and the value => array of reply times from tickets with that priority
    @tickets_by_development_priority = Hash.new {|h,k| h[k]=[]}
    # Hash with key => user_priority, and the value => average reply time of that priority
    @avg_user_priority = {}
    @avg_user_priority.default_proc = proc { 0 }
    # Hash with key => development_priority, and the value => average reply time of that priority
    @avg_development_priority = {}
    @avg_development_priority.default_proc = proc { 0 }
    tickets.each do |ticket|
    	# Rounds the age of the ticket down to the nearest day
    	age = ticket.metrics['full_resolution_time_in_minutes'] / 1440
    	#Add 1 to value with key = age, create a new key if not exists
    	@tickets_by_age[age] += 1
    	user_priority = ticket.info['user_priority']
    	development_priority = ticket.info['development_priority']
    	#Add reply time to array with key = user_priority, create a new key if not exists
    	if user_priority == nil
    		user priority = 'None'
    	end
    	@tickets_by_user_priority[user_priority] << ticket.metrics['reply_time_in_minutes']
    	#Add reply time to array with key = development_priority, create a new key if not exists
    	unless development_priority == nil
    		development_priority = 'None'
    	end
    	@tickets_by_development_priority[development_priority] << ticket.metrics['reply_time_in_minutes']
    end
    puts @tickets_by_user_priority, @tickets_by_development_priority
    @tickets_by_user_priority.each do |key, value|
    	@avg_user_priority[key] = value.inject(:+).to_f / value.length
    	puts key, avg
    end
   @tickets_by_development_priority.each do |key, value|
   		puts "loop"
    	@avg_development_priority[key] = value.inject(:+).to_f / value.length
    	puts key, avg
    end
  end
end
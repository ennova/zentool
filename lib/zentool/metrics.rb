# Represents an aggregate of metrics from multiple tickets 
class Metrics

  MINUTES_IN_DAY = 1440
  attr_accessor :tickets, :tickets_by_age, :tickets_by_user_priority, :tickets_by_development_priority

  def initialize(tickets)

    @tickets = tickets
    # Hash with key as age, and the value as the number of tickets with that age
    @tickets_by_age = Hash.new(0)

    # Hash with key => user_priority, and the value => array of reply times from tickets with that priority
    @tickets_by_user_priority = Hash.new {|h,k| h[k] = []}

    # Hash with key => development_priority, and the value => array of reply times from tickets with that priority
    @tickets_by_development_priority = Hash.new {|h,k| h[k] = []}

    # Hash with key => user_priority, and the value => average reply time of that priority
    @avg_user_priority = Hash.new(0)

    # Hash with key => development_priority, and the value => average reply time of that priority
    @avg_development_priority = Hash.new(0)

    tickets.each do |ticket|
    	# Rounds the age of the ticket down to the nearest day
    	if ticket.metrics['full_resolution_time_in_minutes']
	    	age = ticket.metrics['full_resolution_time_in_minutes'] / MINUTES_IN_DAY
	    	#Add 1 to value with key = age, create a new key if not exists
	    	@tickets_by_age[age] += 1
	    end

    	user_priority = ticket.info['user_priority']
    	development_priority = ticket.info['development_priority']
    	reply_time = ticket.metrics['reply_time_in_minutes']

    	if user_priority == nil
    		user_priority = 'None'
    	end

    	if development_priority == nil
    		development_priority = 'None'
    	end

    	if reply_time
    		
    		#Add reply time to array with key = user_priority, create a new key if not exists
    		@tickets_by_user_priority[user_priority] << reply_time

    		#Add reply time to array with key = development_priority, create a new key if not exists
    		@tickets_by_development_priority[ticket.info['development_priority']] << ticket.metrics['reply_time_in_minutes']
    	end
    end
    @tickets_by_user_priority.each do |key, value|
    	avg = value.inject(:+).to_f / value.length
    	@avg_user_priority[key] = avg
    end
   @tickets_by_development_priority.each do |key, value|
   		avg = value.inject(:+).to_f / value.length
    	@avg_development_priority[key] = avg
    end
    # puts @tickets_by_user_priority, @avg_user_priority, @tickets_by_development_priority, @avg_development_priority, @tickets_by_age
  end
   
   def graph
  	puts "Days    Ticket-Count"
	@tickets_by_age.keys.sort.each do |age|
	   puts "%3d %5d %s\n" % [age, @tickets_by_age[age], "#" * @tickets_by_age[age]]
	end
	puts "Priority   Average-Reply-Time"
	@avg_development_priority.keys.sort.each do |development_priority|
	   puts "%s %5d %s\n" % [development_priority, @avg_development_priority[development_priority], "#" * (@avg_development_priority[development_priority] / 10000)]
	end
   end
end
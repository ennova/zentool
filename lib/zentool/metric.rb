# Represents an aggregate of metrics from multiple tickets 
class Metrics
	attr_accessor :tickets, :tickets_by_age, :tickets_by_user_priority, :tickets_by_development_priority
  def initialize(tickets)
    @tickets = tickets
    @tickets_by_age = Hash.new {|age, id|}
    @tickets_by_user_priority = Hash.new {|user_priority, [reply_times]|}
    @tickets_by_development_priority = Hash.new {|development_priority, [reply_times]|}
    @avg_user_priority = Hash.new{|user_priority, avg_reply_times|}
    @avg_development_priority = Hash.new{|development_priority, avg_reply_times|}
    tickets.each do |ticket|
    	age = floor(ticket.metrics['age'] / 1440)
    	@tickets_by_age.update[:age]
    	@tickets_by_user_priority[ticket['user_priority']] << ticket['reply_time_in_minutes']
    	@tickets_by_development_priority[ticket['user_priority']] << ticket['reply_time_in_minutes']
    @tickets_by_user_priority.each do |key, value|
    	count = 0
    	sum = 0
    	value.each do |time|
    		sum += time
    		count++
    	@avg_user_priority[key] << sum
    @tickets_by_development_priority.each do |key|
    	count = 0
    	sum = 0
    	value.each do |time|
    		sum += time
    		count++
    	@avg_development_priority[key] << sum

  end
end
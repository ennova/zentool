require_relative '../lib/zentool/metrics'

describe Metrics do
	before :each do
		create_metrics
	end
  	describe '#new' do
	  	it 'takes an array of tickets and returns a Metrics object' do
	    	@metrics.should be_an_instance_of Metrics
	  	end
	end
end

def create_metrics
	info1 = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'abc', 
		'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc', 'function' => 'abc', 
		'satisfaction_rating' => 'abc', 'created_at' => 'abc', 'updated_at' => 'abc'}

	info2 = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'abc', 
		'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc', 'function' => 'abc', 
		'satisfaction_rating' => 'abc', 'created_at' => 'abc', 'updated_at' => 'abc'}

	info3 = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'abc', 
		'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc', 'function' => 'abc', 
		'satisfaction_rating' => 'abc', 'created_at' => 'abc', 'updated_at' => 'abc'}

	metrics1 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1, 'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
	metrics2 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1, 'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
	metrics3 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1, 'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
	ticket1 = Ticket.new(info1, metrics1)
	ticket2 = Ticket.new(info2, metrics2)
	ticket3 = Ticket.new(info3, metrics3)
	tickets = [ticket1, ticket2, ticket3]
	@metrics = Metrics.new(tickets)
end

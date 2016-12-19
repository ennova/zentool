require_relative '../lib/zentool/metrics'
require_relative '../lib/zentool/ticket'

describe Metrics do

	before :all do
		create_metrics
	end

  	describe '#new' do
  		context 'empty ticket array provided' do
  			it 'returns an empty Metrics object' do
	    		expect(@empty_metrics).to be_an_instance_of Metrics
  			end
  		end
  		# context 'ticket array is not valid' do
  		# 	it 'return error message' do
  		# 	end
  		# end
  		context  'valid ticket array' do
	  		it 'returns a Metrics object' do
	    		expect(@metrics).to be_an_instance_of Metrics
	  		end

	  		it 'populated correctly' do
	  			expect(@metrics.tickets).to eql(@tickets)
	  		end

	  		it 'contains an array of tickets' do
	  			expect(@metrics.tickets).to be_an_instance_of Array
	  			expect(@metrics.tickets.map(&:class).uniq).to eq [Ticket]
	  		end
	  	end
	end

	# describe '.unsolved_age' do
	# 	context '???' do
	# 	end
	# end


	# describe '.graph' do
	# 	context ''
	# end

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
		empty_info = {}

		metrics1 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1441, 'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
		metrics2 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1441, 'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
		metrics3 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1441, 'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
		empty_metrics1 = {}

		ticket1 = Ticket.new(info1, metrics1)
		ticket2 = Ticket.new(info2, metrics2)
		ticket3 = Ticket.new(info3, metrics3)
		empty_ticket = Ticket.new(empty_info, empty_metrics1)

		@tickets = [ticket1, ticket2, ticket3]
		empty_tickets = [empty_ticket]

		@metrics = Metrics.new(@tickets)
		@empty_metrics = Metrics.new(empty_tickets)

	end
end
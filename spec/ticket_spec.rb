require_relative '../lib/zentool/ticket'

describe Ticket do

	before :all do
		create_tickets
	end

	describe '#new' do
  		context 'empty paramaters provided' do
  			it 'returns an empty Ticket object' do
  				expect(@empty_ticket).to be_an_instance_of Ticket
  			end
  		end
  		context 'one or more parameters are not valid' do
  			it 'return error message' do

  			end
  		end
  		context 'valid parameters' do
	  		it 'returns a Ticket object' do
	    		expect(@ticket).to be_an_instance_of Ticket
	  		end

	  		it 'populated correctly' do
	  			expect(@ticket.info).to eql(@info)
	  			expect(@ticket.metrics).to eql(@metrics)
	  		end

	  		it 'contains two hashes' do
	  			expect(@ticket.info).to be_an_instance_of Hash
	  			expect(@ticket.metrics).to be_an_instance_of Hash
	  		end
	  	end
	end

	def create_tickets
		@info = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'abc', 
			'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc', 'function' => 'abc', 
			'satisfaction_rating' => 'abc', 'created_at' => 'abc', 'updated_at' => 'abc'}
		empty_info = {}

		@info = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'abc', 
			'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc', 'function' => 'abc', 
			'satisfaction_rating' => 'abc', 'created_at' => 'abc', 'updated_at' => 'abc'}

		@metrics = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1441, 
			'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}
		empty_metrics = {}

		@ticket = Ticket.new(@info, @metrics)
		@empty_ticket = Ticket.new(empty_info, empty_metrics)
	end
end
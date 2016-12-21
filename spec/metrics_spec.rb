require 'spec_helper'
require_relative '../lib/zentool/metrics'
require_relative '../lib/zentool/ticket'

describe Metrics do

	before :each do
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
    #      expect(@invalid_metrics)
		# 	end
		# end
		context 'valid ticket array' do
  		it 'returns a Metrics object' do
    		expect(@metrics).to be_an_instance_of Metrics
  		end

  		it 'populated correctly' do
  			expect(@metrics.tickets).to eql(@tickets)
  		end

  		it 'contains an array of tickets' do
  			expect(@metrics.tickets).to be_an_instance_of Array
  			expect(@metrics.tickets.map(&:class).uniq).to eql [Ticket]
  		end
  	end
  end

	describe '.unsolved_age' do
		context 'valid ticket array' do
      it 'returns the number of unsolved tickets on a log scale' do
        expected_hash = {'0' => 0, '1' => 0, '2' => 0, '3' => 0, '4' => 0,
          '5' => 0, '6-10' => 0, '11-20' => 0, '21-50' => 0, '51-100' => 0, '101+' => 2}
        expect(@metrics.unsolved_age(@valid_log_scale)).to eql expected_hash
        expect(@metrics.unsolved_tickets_by_age_log_scale).to eql expected_hash
      end
		end
	end

  describe '.solved_age' do
    context 'valid ticket array' do
      it 'returns the number of unsolved tickets on a log scale' do
        expected_hash = {'0' => 0, '1' => 1, '2' => 0, '3' => 0, '4' => 0,
          '5' => 1, '6-10' => 0, '11-20' => 0, '21-50' => 0, '51-100' => 0, '101+' => 0}
        expect(@metrics.solved_age(@valid_log_scale)).to eql expected_hash
        expect(@metrics.solved_tickets_by_age_log_scale).to eql expected_hash
      end
    end
  end

	describe '.plot_as_log' do
		context 'valid log scale' do
        it 'returns the scale with the age plotted' do
          expected_hash = {'0' => 1, '1' => 1, '2' => 1, '3' => 1, '4' => 1,
            '5' => 1, '6-10' => 1, '11-20' => 1, '21-50' => 1, '51-100' => 1, '101+' => 1}
          log_scale = @valid_log_scale
          log_scale = @metrics.plot_as_log(log_scale, 0)
          log_scale = @metrics.plot_as_log(log_scale, 1)
          log_scale = @metrics.plot_as_log(log_scale, 2)
          log_scale = @metrics.plot_as_log(log_scale, 3)
          log_scale = @metrics.plot_as_log(log_scale, 4)
          log_scale = @metrics.plot_as_log(log_scale, 5)
          log_scale = @metrics.plot_as_log(log_scale, 8)
          log_scale = @metrics.plot_as_log(log_scale, 17)
          log_scale = @metrics.plot_as_log(log_scale, 33)
          log_scale = @metrics.plot_as_log(log_scale, 51)
          log_scale = @metrics.plot_as_log(log_scale, 126)
          expect(log_scale).to eql expected_hash
        end
      end
	end

  describe '.avg_priority' do
    context 'valid ticket array' do
      it 'returns the average reply time at each priority' do
        expected_hash = {'u1' => (500.0/60), 'u2' => (450.0/60)}
        expect(@metrics.avg_priority('user_priority')).to eql expected_hash
      end
    end
  end

	def create_metrics 

		info1 = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'u1',
			'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc',
      'function' => 'abc', 'satisfaction_rating' => 'abc', 'created_at' => '2014-04-04T03:04:11Z', 'updated_at' => 'abc'}

		info2 = {'id' => 2, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'u1',
			'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc',
      'function' => 'abc', 'satisfaction_rating' => 'abc', 'created_at' => '2014-04-30T04:27:24Z', 'updated_at' => 'abc'}

		info3 = {'id' => 3, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'u2',
			'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc',
      'function' => 'abc', 'satisfaction_rating' => 'abc', 'created_at' => '2014-06-16T16:24:49Z', 'updated_at' => 'abc'}

    info4 = {'id' => 4, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'u2',
      'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc',
      'function' => 'abc', 'satisfaction_rating' => 'abc', 'created_at' => '2014-05-06T06:55:13Z', 'updated_at' => 'abc'}

		empty_info = {}

		metrics1 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1441,
      'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 990, 'initially_assigned_at' => '2014-04-04T03:04:11Z'}
		metrics2 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => nil,
      'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 10, 'initially_assigned_at' => '2014-04-30T04:27:24Z'}
		metrics3 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => nil,
      'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 300, 'initially_assigned_at' => '2014-06-16T16:24:49Z'}
    metrics4 = {'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 7205,
      'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 600, 'initially_assigned_at' => '2014-05-06T06:55:13Z'}

		empty_metrics1 = {}

		ticket1 = Ticket.new(info1, metrics1)
		ticket2 = Ticket.new(info2, metrics2)
		ticket3 = Ticket.new(info3, metrics3)
    ticket4 = Ticket.new(info4, metrics4)

		empty_ticket = Ticket.new(empty_info, empty_metrics1)

		@tickets = [ticket1, ticket2, ticket3, ticket4]

		empty_tickets = [empty_ticket]

		@metrics = Metrics.new(@tickets)
		@empty_metrics = Metrics.new(empty_tickets)

    @valid_log_scale = {'0' => 0, '1' => 0, '2' => 0, '3' => 0, '4' => 0,
          '5' => 0, '6-10' => 0, '11-20' => 0, '21-50' => 0, '51-100' => 0, '101+' => 0}

    # invalid_info = [1, 2, 3]
    # invalid_metrics = [1, 2, 3]
    # invalid_ticket1 = Ticket.new(invalid_info, invalid_metrics)
    # invalid_ticket2 = Ticket.new(invalid_info, invalid_metrics)
    # invalid_tickets = [invalid_ticket1, invalid_ticket2]
    # @invalid_metrics = Metrics.new(invalid_tickets)

	end
end

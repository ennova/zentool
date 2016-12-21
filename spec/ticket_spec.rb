require 'spec_helper'
require_relative '../lib/zentool/ticket'

describe Ticket do

	before :all do
		create_tickets
	end

	describe '#new' do
		context 'empty paramaters provided' do
			it 'returns an empty Ticket object' do
				expect(@empty_ticket).to be_an_instance_of Ticket
				expect(@empty_ticket.metrics).to eql({})
				expect(@empty_ticket.info).to eql({})
			end
		end
		# context 'one or more parameters are not valid' do
		# 	it 'return error message' do
  #       expect { Ticket.new(@invalid_info, @invalid_metrics) }.to raise_error
		# 	end
		# end
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

  		it 'hashes have valid keys' do
  			@ticket.info.keys.each do |key|
  				expect(@valid_info.include?(key)).to eql true
  			end
  			@ticket.metrics.keys.each do |key|
  				expect(@valid_metrics.include?(key)).to eql true
        end
  		end
  	end
	end

	def create_tickets
		
		@valid_metrics = %w(id ticket_id url group_stations assignee_stations reopens replies assignee_updated_at
			requester_updated_at status_updated_at initially_assigned_at assigned_at solved_at latest_comment_added_at
			first_resolution_time_in_minutes reply_time_in_minutes full_resolution_time_in_minutes agent_wait_time_in_minutes
			requester_wait_time_in_minutes created_at updated_at)

		@valid_info = %w(id url external_id type subject raw_subject description priority status recipient requester_id
			submitter_id assignee_id organization_id group_id collaborator_ids forum_topic_id problem_id has_incidents
			due_at tags via custom_fields satisfaction_rating sharing_agreement_ids followup_ids ticket_form_id brand_id
			allow_channelback is_public created_at updated_at type user_priority development_priority company project
      platform function)

		@invalid_info = [1, 2, 3]
    @invalid_metrics = [1, 2, 3]

		empty_info = {}

		@info = {'id' => 1, 'type' => 'abc', 'subject' => 'abc', 'status' => 'abc', 'user_priority' => 'abc',
			'development_priority' => 'abc', 'company' => 'abc', 'project' => 'abc', 'platform' => 'abc', 'function' => 'abc',
			'satisfaction_rating' => 'abc', 'created_at' => 'abc', 'updated_at' => 'abc'}

		@metrics = {'initially_assigned_at' => 'abc', 'solved_at' => 'abc', 'full_resolution_time_in_minutes' => 1441,
			'requester_wait_time_in_minutes' => 1, 'reply_time_in_minutes' => 1}

		empty_metrics = {}

		@ticket = Ticket.new(@info, @metrics)
		@empty_ticket = Ticket.new(empty_info, empty_metrics)
	end
end

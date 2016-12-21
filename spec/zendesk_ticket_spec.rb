require 'spec_helper'
require_relative '../lib/zentool/zendesk_ticket'
# require 'webmock'
# require_relative '../lib/zentool/zendesk_ticket'

# Webmock.disable_net_connect!(:allow_localhost => true)

describe ZendeskTicket do
	before :all do
		create_zendesk_tickets
	end

  describe '#new' do
    context 'username, password, domain provided' do
      it 'initialises authentication and URIs' do
        expect(@zen_ticket.username).to eql 'user'
        expect(@zen_ticket.password).to eql 'password'
        expect(@zen_ticket.domain).to eql 'domain'
        expect(@zen_ticket.start_time).to eql 1451570400
        expect(@zen_ticket.root_uri).to eql 'https://domain.zendesk.com/api/v2/'
        expect(@zen_ticket.tickets_uri).to eql ('https://domain.zendesk.com/' +
          'api/v2/incremental/tickets.json?start_time=1451570400')
      end
    end
  end

  # describe '.download_tickets'

  # end

  describe '.basic_auth' do
    context 'username and password provided' do
      it 'creates correct hash' do
        expected_hash = {:basic_auth=>{:username=>"user", :password=>"password"}}
        expect(@zen_ticket.basic_auth).to eql expected_hash
      end
    end
  end

  def create_zendesk_tickets
    @zen_ticket = ZendeskTicket.new('user', 'password', 'domain')
  end
end

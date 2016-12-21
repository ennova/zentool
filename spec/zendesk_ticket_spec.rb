require 'spec_helper'
require_relative '../lib/zentool/zendesk_ticket'

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

  # describe '.download_tickets' do
  #   context 'successful get' do
  #     it 'correct response' do
  #       #Actual request
  #       req = Net::HTTP::Post.new('/')
  #       req['Content-Length'] = 3
  #       Net::HTTP.start('https://envisionapp.zendesk.com/', 80) {|http|
  #           http.request(req, 'abc')
  #       } 

  #         expect(request(:post, 'https://envisionapp.zendesk.com/').
  #           with(:body => "abc", :headers => { 'Content-Length' => 3 })).to have_been_made.once

  #         expect(request(:get, "www.something.com")).to_not have_been_made
  #     end
  #   end
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

    # stub_request(:any, 'https://envisionapp.zendesk.com/').
    # with(:headers => { 'Content-Length' => 3 }).to_return(:body => 'abc')

  end
end

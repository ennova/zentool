# require 'spec_helper'

# feature 'External request' do
#   it 'queries Zendesk domain' do
#     uri = URI('https://envisionapp.zendesk.com/' +
#           'api/v2/incremental/tickets.json?start_time=1451570400')

#     response = Net::HTTP.get(uri)

#     expect(response).to be_an_instance_of(String)
#   end
# end
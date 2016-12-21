require 'simplecov'
# require 'webmock/rspec'
require_relative 'metrics_spec.rb'
require_relative 'ticket_spec.rb'
require_relative 'zendesk_ticket_spec.rb'

# include WebMock

# WebMock.disable_net_connect!(:allow_localhost => true)
SimpleCov.start


#!/usr/bin/env ruby

require 'azure_mgmt_resources'
require 'azure_mgmt_cognitive_services'
require 'dotenv'
require 'haikunator'

Dotenv.load(File.join(__dir__, './.env'))

GROUP_NAME = 'azure-sample-group'
WEST_US = 'westus'
ACCOUNT_NAME = 'rubysdkcsaccount'

# This script expects that the following environment vars are set:
#
# AZURE_TENANT_ID: with your Azure Active Directory tenant id or domain
# AZURE_CLIENT_ID: with your Azure Active Directory Application Client ID
# AZURE_CLIENT_SECRET: with your Azure Active Directory Application Secret
# AZURE_SUBSCRIPTION_ID: with your Azure Subscription Id
#
def run_example
  #
  # Create the Resource Manager Client with an Application (service principal) token provider
  #
  subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] || '11111111-1111-1111-1111-111111111111' # your Azure Subscription Id
  provider = MsRestAzure::ApplicationTokenProvider.new(
      ENV['AZURE_TENANT_ID'],
      ENV['AZURE_CLIENT_ID'],
      ENV['AZURE_CLIENT_SECRET'])
  credentials = MsRest::TokenCredentials.new(provider)
  cs_client = Azure::ARM::CognitiveServices::CognitiveServicesManagementClient.new(credentials)
  cs_client.long_running_operation_retry_timeout = ENV.fetch('RETRY_TIMEOUT', 30).to_i
  resource_client = Azure::ARM::Resources::ResourceManagementClient.new(credentials)
  resource_client.subscription_id = cs_client.subscription_id = subscription_id
  resource_client.providers.register("Microsoft.CognitiveServices")
  resource_client.long_running_operation_retry_timeout = ENV.fetch('RETRY_TIMEOUT', 30).to_i

  #
  # Create a resource group
  #
  resource_group_params = Azure::ARM::Resources::Models::ResourceGroup.new.tap do |rg|
    rg.location = WEST_US
  end

  resource_group_params.class.class

  puts 'Create Resource Group'
  print_item resource_client.resource_groups.create_or_update(GROUP_NAME, resource_group_params)

  #
  # Create a Cognitive Services account
  #
   puts 'Create a Cognitive Services account'
  cs_acc_params = Azure::ARM::CognitiveServices::Models::CognitiveServicesAccountCreateParameters.new
  sku = Azure::ARM::CognitiveServices::Models::Sku.new
  sku.name = Azure::ARM::CognitiveServices::Models::SkuName::F0
  cs_acc_params.sku = sku
  cs_acc_params.kind = Azure::ARM::CognitiveServices::Models::Kind::TextAnalytics
  cs_acc_params.location = 'westus'
  cs_acc_params.properties = {:prop1 => 'prop1'}
  cs_account = cs_client.cognitive_services_accounts.create(GROUP_NAME, ACCOUNT_NAME, cs_acc_params)

  print_item cs_account

  puts 'Press any key to continue and delete the sample resources'
  gets

  # #
  # # Delete a Cognitive Services account
  # #
  puts 'Deleting the Cognitive Services account'
  cs_client.cognitive_services_accounts.delete(GROUP_NAME, ACCOUNT_NAME)

  # #
  # Delete the Resource Group
  # #
  puts 'Deleting the resource group'
  resource_client.resource_groups.delete(GROUP_NAME)
  puts "\nDeleted: #{GROUP_NAME}"

end

def print_item(group)
  puts "\tName: #{group.name}"
  puts "\tId: #{group.id}"
  puts "\tLocation: #{group.location}"
  puts "\tTags: #{group.tags}"
end

if $0 == __FILE__
  run_example
end



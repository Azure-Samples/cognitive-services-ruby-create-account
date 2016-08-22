---
services: cognitive-services
platforms: ruby
author: veronicagg
---

# Manage Azure Cognitive Services with Ruby

This sample demonstrates how to manage your Azure cognitive services account using a ruby client.

**On this page**

- [Run this sample](#run)
- [What does example.rb do?](#sample)
    - [Create a cognitive services account](#create)
    - [Delete a cognitive services account](#delete)

<a id="run"></a>
1. If you don't already have it, [install Ruby and the Ruby DevKit](https://www.ruby-lang.org/en/documentation/installation/).

1. If you don't have bundler, install it.

    ```
    gem install bundler
    ```

1. Clone the repository.

    ```
    git clone https://github.com/Azure-Samples/cognitive-services-ruby-create-account.git
    ```

1. Install the dependencies using bundle.

    ```
    cd cognitive-services-ruby-create-account
    bundle install
    ```

1. Create an Azure service principal either through
    [Azure CLI](https://azure.microsoft.com/documentation/articles/resource-group-authenticate-service-principal-cli/),
    [PowerShell](https://azure.microsoft.com/documentation/articles/resource-group-authenticate-service-principal/)
    or [the portal](https://azure.microsoft.com/documentation/articles/resource-group-create-service-principal-portal/).

1. Set the following environment variables using the information from the service principle that you created.

    ```
    export AZURE_TENANT_ID={your tenant id}
    export AZURE_CLIENT_ID={your client id}
    export AZURE_CLIENT_SECRET={your client secret}
    export AZURE_SUBSCRIPTION_ID={your subscription id}
    ```

    > [AZURE.NOTE] On Windows, use `set` instead of `export`.

1. Run the sample.

    ```
    bundle exec ruby example.rb
    ```

<a id="sample"></a>
## What does example.rb do?

This sample starts by setting up a ResourceManagementClient object using your subscription and credentials.

```ruby
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
```

The sample then sets up a resource group.

```ruby
resource_group_params = Azure::ARM::Resources::Models::ResourceGroup.new.tap do |rg|
  rg.location = WEST_US
end

resource_group_params.class.class

resource_client.resource_groups.create_or_update(GROUP_NAME, resource_group_params)
```


<a id="create"></a>
### Create a cognitive services account

```ruby
cs_acc_params = Azure::ARM::CognitiveServices::Models::CognitiveServicesAccountCreateParameters.new
sku = Azure::ARM::CognitiveServices::Models::Sku.new
sku.name = Azure::ARM::CognitiveServices::Models::SkuName::F0
cs_acc_params.sku = sku
cs_acc_params.kind = Azure::ARM::CognitiveServices::Models::Kind::TextAnalytics
cs_acc_params.location = 'westus'
cs_acc_params.properties = {:prop1 => 'prop1'}
cs_account = cs_client.cognitive_services_accounts.create(GROUP_NAME, ACCOUNT_NAME, cs_acc_params)
```

<a id="delete"></a>
### Delete a cognitive services account

```ruby
cs_client.cognitive_services_accounts.delete(GROUP_NAME, ACCOUNT_NAME)
```

## More information
Please refer to [Azure SDK for Ruby](https://github.com/Azure/azure-sdk-ruby) for more information.

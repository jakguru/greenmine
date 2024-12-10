require "graphql/client"
require "graphql/client/http"

module Monday
  HTTP = GraphQL::Client::HTTP.new("https://api.monday.com/v2") do
    def headers(context)
      {
        "Authorization" => context[:api_key],
        "Content-Type" => "application/json"
      }
    end
  end

  Schema = GraphQL::Client.load_schema(File.join(File.dirname(__FILE__), "..", "..", "db", "graphql", "monday_schema.json"))
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  module Queries
    ListBoards = Client.parse <<-GRAPHQL
      query ($ids: [ID!]) {
        boards (ids: $ids) {
          id
          name
          description
          item_terminology
          state
          type
          url
          columns {
            id
            title
            type
            settings_str
            description
          }
        }
      }
    GRAPHQL

    ListUsers = Client.parse <<-GRAPHQL
      query {
        users {
          id
          name
          email
          photo_original
          title
        }
      }
    GRAPHQL

    ListWebhooks = Client.parse <<-GRAPHQL
      query($board_id: ID!) {
        webhooks (board_id: $board_id) {
          id
          board_id
          event
          config
        }
      }
    GRAPHQL

    CreateWebhook = Client.parse <<-GRAPHQL
      mutation($board_id: ID!, $url: String!, $event: WebhookEventType!, $config: JSON) {
        create_webhook (board_id: $board_id, url: $url, event: $event, config: $config) {
          id
          board_id
        }
      }
    GRAPHQL

    DeleteWebhook = Client.parse <<-GRAPHQL
      mutation($webhook_id: ID!) {
        delete_webhook (id: $webhook_id) {
          id
          board_id
        }
      }
    GRAPHQL
  end
end

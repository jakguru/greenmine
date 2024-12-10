class InstallMondayWebhooksJob
  include Sidekiq::Job

  def perform(monday_instance_id, monday_board_id)
    monday_instance = MondayInstance.find(monday_instance_id)
    if monday_instance.nil?
      Rails.logger.error("Monday Instance ID: #{monday_instance_id} not found")
      return
    end
    monday_board = MondayBoard.find_by(id: monday_board_id)
    if monday_board.nil?
      Rails.logger.error("Monday Board: #{monday_board_id} not found")
      return
    end
    webhook_url_protocol = Setting.send(:protocol)
    webhook_url_host = Setting.send(:host_name)
    monday_webhook_url = "#{webhook_url_protocol}://#{webhook_url_host}/webhooks/monday?mid=#{monday_instance_id}&mbid=#{monday_board_id}"
    Rails.logger.info("Installing Monday Webhook #{monday_webhook_url} for Monday Board ID: #{monday_board.monday_board_id} on Monday Instance ID: #{monday_instance_id}")
    # Enumerate the expected / required webhook events
    expected_webhook_events = {
      change_column_value: {
        url: monday_webhook_url,
        event: "change_column_value"
      },
      change_name: {
        url: monday_webhook_url,
        event: "change_name"
      },
      create_item: {
        url: monday_webhook_url,
        event: "create_item"
      },
      item_archived: {
        url: monday_webhook_url,
        event: "item_archived"
      },
      item_deleted: {
        url: monday_webhook_url,
        event: "item_deleted"
      },
      item_moved_to_any_group: {
        url: monday_webhook_url,
        event: "item_moved_to_any_group"
      },
      item_restored: {
        url: monday_webhook_url,
        event: "item_restored"
      },
      create_subitem: {
        url: monday_webhook_url,
        event: "create_subitem"
      },
      change_subitem_name: {
        url: monday_webhook_url,
        event: "change_subitem_name"
      },
      move_subitem: {
        url: monday_webhook_url,
        event: "move_subitem"
      },
      subitem_archived: {
        url: monday_webhook_url,
        event: "subitem_archived"
      },
      subitem_deleted: {
        url: monday_webhook_url,
        event: "subitem_deleted"
      },
      create_column: {
        url: monday_webhook_url,
        event: "create_column"
      },
      create_update: {
        url: monday_webhook_url,
        event: "create_update"
      },
      edit_update: {
        url: monday_webhook_url,
        event: "edit_update"
      },
      delete_update: {
        url: monday_webhook_url,
        event: "delete_update"
      },
      create_subitem_update: {
        url: monday_webhook_url,
        event: "create_subitem_update"
      }
    }
    expected_webhook_events.each do |event, webhook|
      Rails.logger.info("Adding Monday Webhook #{webhook[:event]} for Monday Board ID: #{monday_board.monday_board_id} on Monday Instance ID: #{monday_instance_id}")
      add_results = Monday::Client.query(Monday::Queries::CreateWebhook, variables: {board_id: monday_board.monday_board_id, url: webhook[:url], event: webhook[:event]}, context: {api_key: monday_instance.api_token})
      Rails.logger.info("Add Monday Webhook Results for #{webhook[:event]}: #{add_results.to_json}")
    end
  end
end

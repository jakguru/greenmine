class ProcessMondayWebhookJob
  include Sidekiq::Job

  def perform(json_encoded_params, json_encoded_headers)
    params = JSON.parse(json_encoded_params, {
      symbolize_names: true
    })
    headers = JSON.parse(json_encoded_headers, {
      symbolize_names: true
    })
    Rails.logger.info("Processing Monday Webhook: #{params.inspect} with headers: #{headers.inspect}")
    monday_instance = MondayInstance.find_by(params[:mid])
    if monday_instance.nil?
      Rails.logger.error("MondayInstance with id #{params[:mid]} not found")
      return
    end
    monday_board = MondayBoard.find_by(id: params[:mbid])
    if monday_board.nil?
      Rails.logger.error("MondayBoard with id #{params[:mbid]} not found under MondayInstance with id #{params[:mid]}")
      nil
    elsif monday_board[:monday_id] != monday_instance.id
      Rails.logger.error("MondayBoard with id #{params[:mbid]} not found under MondayInstance with id #{params[:mid]}")
    end
    monday_board.do_process_webhook(params, headers)
  end
end

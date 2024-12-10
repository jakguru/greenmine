class RefreshMondayBoardMetaJob
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
    boards_results = Monday::Client.query(Monday::Queries::ListBoards, variables: {ids: [monday_board.monday_board_id]}, context: {api_key: monday_instance.api_token})
    if boards_results.data.boards.nil? || boards_results.data.boards.empty?
      Rails.logger.error("Monday Board: #{monday_board.monday_board_id} not found")
      return
    end
    board = boards_results.data.boards.first
    monday_board.board_meta_data = board.to_h
    board.columns.each do |column|
      monday_board.board_field_mapping[column.id] ||= ""
    end
    monday_board.save!
    ActionCable.server.broadcast("rtu_board_monday_board", {monday_instance_id: monday_instance_id, monday_board_id: monday_board_id})
  end
end

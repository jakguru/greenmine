class FetchMondayBoardsJob
  include Sidekiq::Job

  def perform(id)
    monday = MondayInstance.find(id)
    page = 1
    limit = 100
    results = Monday::Client.query(Monday::Queries::ListBoards, context: {api_key: monday.api_token}, variables: {limit: limit, page: page})
    returned_board_ids = []
    while results.data.boards.length > 0
      results.data.boards.each do |board|
        if board.type == "board"
          returned_board_ids << board.id
          monday_board_instance = MondayBoard.find_by(monday_id: monday.id, monday_board_id: board.id)
          if monday_board_instance.nil?
            monday_board_instance = MondayBoard.new(
              monday_id: monday.id,
              project_id: 0,
              monday_board_id: board.id,
              board_meta_data: board.to_h,
              board_field_mapping: {}
            )
          end
          monday_board_instance.board_meta_data = board.to_h
          board.columns.each do |column|
            monday_board_instance.board_field_mapping[column.id] ||= ""
          end
          monday_board_instance.save!
        end
      end
      page += 1
      results = Monday::Client.query(Monday::Queries::ListBoards, context: {api_key: monday.api_token}, variables: {limit: limit, page: page})
    end
    MondayBoard.where(monday_id: monday.id).where.not(monday_board_id: returned_board_ids).destroy_all
    ActionCable.server.broadcast("rtu_monday_instance_boards", {monday_instance_id: monday.id})
  end
end

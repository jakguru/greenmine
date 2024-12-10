class InstallMondayFieldConfigurationsForAllBoardsJob
  include Sidekiq::Job

  def perform
    boards = MondayBoard.where.not(project_id: 0)
    boards.each do |board|
      InstallMondayFieldConfigurationsJob.perform_async(board.monday_instance.id, board.id)
    end
  end
end

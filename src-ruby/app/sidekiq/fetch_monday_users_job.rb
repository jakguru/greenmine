class FetchMondayUsersJob
  include Sidekiq::Job

  def perform(id)
    monday = MondayInstance.find(id)
    results = Monday::Client.query(Monday::Queries::ListUsers, context: {api_key: monday.api_token})
    returned_user_ids = []
    results.data.users.each do |user|
      returned_user_ids << user.id
      monday_user_instance = MondayUser.find_by(monday_id: monday.id, user_id: user.id)
      if monday_user_instance.nil?
        monday_user_instance = MondayUser.new(
          monday_id: monday.id,
          user_id: user.id,
          user_meta_data: user.to_h
        )
      end
      monday_user_instance.user_meta_data = user.to_h
      monday_user_instance.save!
    end
    MondayUser.where(monday_id: monday.id).where.not(user_id: returned_user_ids).destroy_all
    ActionCable.server.broadcast("rtu_monday_instance_users", {monday_instance_id: monday.id})
  end
end

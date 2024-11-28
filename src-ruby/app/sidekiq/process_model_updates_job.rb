class ProcessModelUpdatesJob
  include Sidekiq::Job

  def perform(klass, id, action, model = nil)
    # TODO: This is the foundational place to process model updates
    # From here we will be able to send updates to external services,
    # and also to the frontend via ActionCable
    hash = {klass: klass, id: id, action: action, model: model}
    Rails.logger.info "Processing model update: #{hash}"
  end
end

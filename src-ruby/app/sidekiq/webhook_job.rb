class WebhookJob
  include Sidekiq::Job

  def perform(*args)
    # do something
  end
end

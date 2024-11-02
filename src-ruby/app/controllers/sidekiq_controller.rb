# frozen_string_literal: true

require "sidekiq/api"
class SidekiqController < ApplicationController
  unloadable
  include FridayHelper

  def stats
    if !can_access_sidekiq?
      return render_403
    end
    stats = Sidekiq::Stats.new
    history = Sidekiq::Stats::History.new(7)
    queues = Sidekiq::Queue.all
    queue_stats = queues.map do |queue|
      {
        name: queue.name,
        size: queue.size,
        latency: queue.latency
      }
    end
    if friday_request?
      render json: {
        stats: {
          dead_size: stats.dead_size,
          default_queue_latency: stats.default_queue_latency,
          failed: stats.failed,
          processed: stats.processed,
          processes_size: stats.processes_size,
          retry_size: stats.retry_size,
          scheduled_size: stats.scheduled_size,
          enqueued: stats.enqueued
        },
        history: {
          processed: history.processed,
          failed: history.failed
        },
        processes: Sidekiq::ProcessSet.new,
        queues: queue_stats
      }
    else
      render partial: "admin/sidekiq"
    end
  end

  private

  def can_access_sidekiq?
    ENV["REDIS_URL"] && !(defined?(Rails::Console) || File.split($0).last == "rake") && User.current.admin?
  end
end

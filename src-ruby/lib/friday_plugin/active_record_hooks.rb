require "active_support/concern"

module FridayPlugin
  module ActiveRecordHooks
    extend ActiveSupport::Concern

    included do
      after_create :friday_after_create
      after_update :friday_after_update
      after_save :friday_after_save
      after_destroy :friday_after_destroy
    end

    private

    def friday_after_create
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "created", to_json)
    end

    def friday_after_update
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "updated", to_json)
    end

    def friday_after_save
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "saved", to_json)
    end

    def friday_after_destroy
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "destroyed")
    end
  end
end

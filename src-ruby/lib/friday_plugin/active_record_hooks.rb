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
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "created", to_json, nil)
    end

    def friday_after_update
      previous_values = previous_attributes
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "updated", to_json, previous_values.to_json)
    end

    def friday_after_save
      previous_values = previous_attributes
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "saved", to_json, previous_values.to_json)
    end

    def friday_after_destroy
      previous_values = attributes_before_type_cast
      ProcessModelUpdatesJob.perform_async(self.class.name, id, "destroyed", nil, previous_values.to_json)
    end

    def previous_attributes
      saved_changes.transform_values(&:first)
    end
  end
end

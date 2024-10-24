# frozen_string_literal: true

class IssueImpact < Enumeration
  has_many :issues, foreign_key: "impact_id"

  after_destroy { |impact| impact.class.compute_position_names }
  after_save do |impact|
    if (impact.saved_change_to_position? && impact.position) ||
        impact.saved_change_to_active? || impact.saved_change_to_is_default?
      impact.class.compute_position_names
    end
  end

  OptionName = :enumeration_issue_priorities

  def option_name
    OptionName
  end

  def objects_count
    issues.count
  end

  def transfer_relations(to)
    issues.update_all(impact_id: to.id)
  end

  def css_classes
    "impact-#{id} impact-#{position_name}"
  end

  # Clears position_name for all priorities
  # Called from migration 20121026003537_populate_enumerations_position_name
  def self.clear_position_names
    update_all position_name: nil
  end

  def self.default_or_middle
    default || begin
      priorities = active
      priorities[(priorities.size - 1) / 2]
    end
  end

  def high?
    position > self.class.default_or_middle.position
  end

  def low?
    position < self.class.default_or_middle.position
  end

  # Updates position_name for active priorities
  def self.compute_position_names
    priorities = active
    if priorities.any?
      default_position = default_or_middle.position
      priorities.each_with_index do |impact, index|
        name =
          if impact.position == default_position
            "default"
          elsif impact.position < default_position
            (index == 0) ? "lowest" : "low#{index + 1}"
          else
            (index == (priorities.size - 1)) ? "highest" : "high#{priorities.size - index}"
          end

        where(id: impact.id).update_all({position_name: name})
      end
    end
  end
end

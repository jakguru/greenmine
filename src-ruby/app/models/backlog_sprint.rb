class BacklogSprint < Sprint
  def id
    nil
  end

  def name
    l(:label_backlog)
  end

  def start_date
    # since the beginning of the decade
    Date.new(2010, 1, 1)
  end

  def end_date
    # until the end of the century
    Date.new(2100, 12, 31)
  end

  def state
    l(:state_open)
  end

  def issues
    Issue.where.not(id: IssueSprint.select(:issue_id))
  end

  def total_estimated_work
    issues.sum { |issue| issue.estimated_hours.to_f }
  end

  def total_time_logged
    issues.sum { |issue| issue.time_entries.sum { |entry| entry.hours.to_f } }
  end

  def to_hash
    {
      id: id,
      name: name,
      start_date: start_date,
      end_date: end_date,
      state: state,
      total_estimated_work: total_estimated_work,
      total_time_logged: total_time_logged
    }
  end
end

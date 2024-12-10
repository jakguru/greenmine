class InstallMondayFieldConfigurationsJob
  include Sidekiq::Job

  def perform(monday_instance_id, monday_board_id)
    monday_instance = MondayInstance.find(monday_instance_id)
    if monday_instance.nil?
      Rails.logger.error("Monday Instance ID: #{monday_instance_id} not found")
      return
    end
    monday_board = MondayBoard.find_by(id: monday_board_id)
    if monday_board.nil?
      Rails.logger.error("Monday Board: #{monday_board_id} not found")
      nil
    end
    boards_results = Monday::Client.query(Monday::Queries::ListBoards, variables: {ids: [monday_board.monday_board_id]}, context: {api_key: monday_instance.api_token})
    if boards_results.data.boards.nil? || boards_results.data.boards.empty?
      Rails.logger.error("Monday Board: #{monday_board.monday_board_id} not found")
      return
    end
    board = boards_results.data.boards.first
    board.columns.each do |column|
      mapped_to = monday_board.board_field_mapping[column.id]
      unless mapped_to.nil?
        case mapped_to
        when "url"
          case column.type
          when "link"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "id"
          case column.type
          when "numbers"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "project"
          case column.type
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "tracker"
          case column.type
          when "dropdown"
            configure_dropdown_column(monday_board.monday_board_id, column, mapped_to)
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "status"
          case column.type
          when "dropdown"
            configure_dropdown_column(monday_board.monday_board_id, column, mapped_to)
          when "text"
            # do nothing
          when "status"
            configure_status_column(monday_board.monday_board_id, column, mapped_to)
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "urgency"
          case column.type
          when "dropdown"
            configure_dropdown_column(monday_board.monday_board_id, column, mapped_to)
          when "text"
            # do nothing
          when "status"
            configure_status_column(monday_board.monday_board_id, column, mapped_to)
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "impact"
          case column.type
          when "dropdown"
            configure_dropdown_column(monday_board.monday_board_id, column, mapped_to)
          when "text"
            # do nothing
          when "status"
            configure_status_column(monday_board.monday_board_id, column, mapped_to)
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "calculated_priority"
          case column.type
          when "text"
            # do nothing
          when "numbers"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "author"
          case column.type
          when "people"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "assigned_to"
          case column.type
          when "people"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "category"
          case column.type
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "fixed_version"
          case column.type
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "parent"
          case column.type
          when "link"
            # do nothing
          when "text"
            # do nothing
          when "numbers"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "subject"
          case column.type
          when "name"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "description"
          case column.type
          when "long_text"
            # do nothing
          when "doc"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "start_date"
          case column.type
          when "date"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "due_date"
          case column.type
          when "date"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "done_ratio"
          case column.type
          when "link"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "estimated_hours"
          case column.type
          when "numbers"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "total_estimated_hours"
          case column.type
          when "numbers"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "spent_hours"
          case column.type
          when "numbers"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "total_spent_hours"
          case column.type
          when "numbers"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "created_on"
          case column.type
          when "date"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "updated_on"
          case column.type
          when "date"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "closed_on"
          case column.type
          when "date"
            # do nothing
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "attachments"
          case column.type
          when "file"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        when "sprints"
          case column.type
          when "dropdown"
            configure_dropdown_column(monday_board.monday_board_id, column, mapped_to)
          when "text"
            # do nothing
          else
            Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid type #{column.type} for mapping: #{mapped_to}")
          end
        else
          Rails.logger.error("Monday Board: #{monday_board.monday_board_id} column: #{column.id} has an invalid mapping: #{mapped_to}")
        end
      end
    end
  end

  def configure_dropdown_column(monday_board_id, column, mapped_to)
    opts = get_options_for_mapped_field(mapped_to)
    Rails.logger.info(opts)
  end

  def configure_status_column(monday_board_id, column, mapped_to)
    opts = get_options_for_mapped_field(mapped_to)
    Rails.logger.info(opts)
  end

  def get_options_for_mapped_field(mapped_to)
    done_colors = []
    labels = {}
    labels_positions_v2 = {}
    labels_colors = {}
    opts = case mapped_to
    when "tracker"
      Tracker.all.map do |tracker|
        {
          label: tracker.name,
          label_position: tracker.position,
          label_color: tracker.color,
          is_done: false
        }
      end
    when "status"
      IssueStatus.all.map do |status|
        {
          label: status.name,
          label_position: status.position,
          label_color: status.background_color,
          is_done: status.is_closed
        }
      end
    when "urgency"
      highest_priority_position = IssuePriority.maximum(:position)
      lowest_priority_position = IssuePriority.minimum(:position)
      IssuePriority.all.map do |urgency|
        {
          label: urgency.name,
          label_position: urgency.position,
          label_color: calculate_color_for_priority(lowest_priority_position, highest_priority_position, urgency.position),
          is_done: false
        }
      end
    when "impact"
      highest_priority_position = IssueImpact.maximum(:position)
      lowest_priority_position = IssueImpact.minimum(:position)
      IssueImpact.all.map do |impact|
        {
          label: impact.name,
          label_position: impact.position,
          label_color: calculate_color_for_priority(lowest_priority_position, highest_priority_position, impact.position),
          is_done: false
        }
      end
    else
      []
    end
    opts.each_with_index do |opt, index|
      labels[index.to_s.to_sym] = opt[:label]
      labels_positions_v2[index.to_s.to_sym] = opt[:label_position]
      labels_colors[index.to_s.to_sym] = {
        color: opt[:label_color],
        border: opt[:label_color],
        var_name: "friday-#{mapped_to}-#{opt[:label].downcase.gsub(/\s+/, "-")}"
      }
      if opt[:is_done]
        done_colors << index
      end
    end
    {
      done_colors: done_colors,
      labels: labels,
      labels_positions_v2: labels_positions_v2,
      labels_colors: labels_colors
    }
  end

  def hex_to_rgb(hex)
    bigint = Integer(hex[1..], 16)
    {
      r: (bigint >> 16) & 255,
      g: (bigint >> 8) & 255,
      b: bigint & 255
    }
  end

  def rgb_to_hex(r, g, b)
    "#" + [r, g, b].map { |x| x.to_s(16).rjust(2, "0") }.join
  end

  def interpolate_color(low_color, high_color, factor)
    low_rgb = hex_to_rgb(low_color)
    high_rgb = hex_to_rgb(high_color)
    r = (low_rgb[:r] + factor * (high_rgb[:r] - low_rgb[:r])).round
    g = (low_rgb[:g] + factor * (high_rgb[:g] - low_rgb[:g])).round
    b = (low_rgb[:b] + factor * (high_rgb[:b] - low_rgb[:b])).round
    rgb_to_hex(r, g, b)
  end

  def calculate_color_for_priority(lowest_priority_position, highest_priority_position, current_priority_position, low_color_hex = "#F44336", high_color_hex = "#607D8B")
    return high_color_hex if lowest_priority_position == highest_priority_position
    factor = (current_priority_position - lowest_priority_position).to_f / (highest_priority_position - lowest_priority_position).to_f
    interpolate_color(low_color_hex, high_color_hex, factor)
  end
end

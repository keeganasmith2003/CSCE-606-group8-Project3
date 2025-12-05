module TicketsHelper
  def render_activity_log(version)
    user = User.find_by(id: version.whodunnit)
    user_name = user ? user.display_name : "System"

    return "Ticket Created by #{user_name}".html_safe if version.event == "create"
    changes = version.changeset || {}

    return "Updated by #{user_name}" if changes.empty?

    parts = []

    if changes.key?("status")
      new_status = changes["status"][1]
      parts << "Status changed to <strong>#{new_status.titleize}</strong>"
    end

    if changes.key?("priority")
      new_priority = changes["priority"][1]
      parts << "Priority set to <strong>#{new_priority.titleize}</strong>"
    end

    if changes.key?("assignee_id")
      new_id = changes["assignee_id"][1]
      if new_id
        agent = User.find_by(id: new_id)
        name = agent ? agent.display_name : "Unknown Agent"
        parts << "Assigned to <strong>#{name}</strong>"
      else
        parts << "<strong>Unassigned</strong>"
      end
    end

    if changes.key?("team_id")
      new_id = changes["team_id"][1]
      if new_id
        team = Team.find_by(id: new_id)
        name = team ? team.name : "Unknown Team"
        parts << "Escalated to <strong>#{name}</strong>"
      else
        parts << "Removed from Team"
      end
    end

    if changes.key?("closed_at")
      if changes["closed_at"][1].present?
        parts << "Marked as <strong>Resolved</strong>"
      else
        parts << "Reopened"
      end
    end

    if parts.any?
      "#{parts.join(' and ')} by #{user_name}".html_safe
    else
      changed_fields = changes.keys.map(&:humanize).join(", ")
      "Updated #{changed_fields} by #{user_name}".html_safe
    end
  end
end

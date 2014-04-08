module IepcreportsHelper
  include ActionView::Helpers::UrlHelper

  def sort_activity_events(events)
    events_by_group = events.group_by(&:event_group)
    sorted_events = []
    events.sort {|x, y| y.event_datetime <=> x.event_datetime}.each do |event|
      if group_events = events_by_group.delete(event.event_group)
        group_events.sort {|x, y| y.event_datetime <=> x.event_datetime}.each_with_index do |e, i|
          sorted_events << [e, i > 0]
        end
      end
    end
    sorted_events
  end

  def format_report_activity_title(text)
    h(truncate_single_line(text.partition(':')[2], :length => 140))
  end

  def print_issue_report(issue)
    trackers = {
        4 => 'AP',
        5 => 'AI',
        6 => 'A',
        2 => 'T',
        7 => 'E'
    }

    '<li class="issue">' +
      '<input type="checkbox">' +
      '<span class="done_ratio">' + issue.done_ratio.to_s + '%' + '</span>' +
      '<span class="link">[' + link_to(issue.id.to_s + '-' + trackers[issue.tracker_id], issue.event_url) + ']</span>' +
      '<strong>' + issue.start_date.to_s + '</strong>' +
      link_to(format_report_activity_title(issue.event_title), issue.event_url) +
      '<div class="description">' + issue.description + '</div>' +
    '</li>'
  end

  def print_issues_report(issues, date_from, date_to)
    print = String.new

    print += '<ul class="expanded">'
    issues.each do |issue|
      if (!issue.start_date.nil?) && ((issue.done_ratio < 100 && issue.start_date <= date_from) || (issue.start_date <= date_to and issue.start_date >= date_from))
        print += print_issue_report issue
        if issue.children.any?
          print += print_issues_report issue.children, date_from, date_to
        end
      end
    end
    print += '</ul>'
  end

end

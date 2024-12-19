module ApplicationHelper
  def cancel_redirect_path
    referer = request.referer || root_path
    referer.gsub(%r{/comments/new$}, '') # Removes '/comments/new' from the referer URL
  end

  def flash_class(level)
    case level.to_sym
    when :notice then 'blue'
    when :alert then 'red'
    when :success then 'green'
    else 'gray'
    end
  end

  def greeting_message
    current_hour = Time.zone.now.hour

    case current_hour
    when 0..11
      "Good morning"
    when 12..17
      "Good afternoon"
    else
      "Good evening"
    end
  end
end

module ApplicationHelper
  def cancel_redirect_path
    referer = request.referer || root_path
    referer.gsub(/\/comments\/new$/, '') # Removes '/comments/new' from the referer URL
  end
end

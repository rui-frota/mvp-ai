module PromptRequestsHelper
  def status_badge_class(status)
    case status
    when 'completed'
      'bg-success'
    when 'processing'
      'bg-warning'
    when 'pending'
      'bg-secondary'
    when 'failed'
      'bg-danger'
    else
      'bg-light text-dark'
    end
  end
end

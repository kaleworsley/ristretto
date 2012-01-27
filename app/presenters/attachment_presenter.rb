class AttachmentPresenter < BasePresenter
  presents :attachment
  #delegate :description, :date, :started_time, :finished_time, :chargeable, :to => :timeslice

  def link
    h.link_to attachment, attachment
  end
  
  def mime_type
    attachment.file_content_type
  end
  
  def user
    if attachment.user.present?
      link_to attachment.user, attachment.user
    else
      "<em>Unknown</em>"
    end
  end

end

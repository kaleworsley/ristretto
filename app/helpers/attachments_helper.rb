module AttachmentsHelper
  def mime_icon(attachment)
    case (attachment.file_content_type)
      when 'text/plain', 'text/html'
        image = 'text.png'
      when 'application/pdf'
        image = 'pdf.png'
      when 'application/x-tar', 'application/zip', 'application/x-compressed-tar', 'application/x-gtar'
        image = 'archive.png'
      when 'application/vnd.oasis.opendocument.presentation'
        image = 'presentation.png'
      when 'application/vnd.ms-powerpoint'
        image = 'powerpoint.png'
      when 'application/vnd.oasis.opendocument.spreadsheet';
        image = 'spreadsheet.png'
      when 'application/vnd.ms-excel'
        image = 'excel.png'
      when 'application/vnd.oasis.opendocument.text';
        image = 'document.png'
      when 'application/msword'
        image = 'word.png'
      when 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg', 'image/tiff', 'image/x-photoshop'
        image = 'image.png'
      when 'audio/mpeg'
        image = 'audio.png'
      when 'audio/ogg'
        image = 'audio_ogg.png'
      else
        image = 'default.png'
    end
    image_tag 'mime_icons/' + image, {:title => image.split('.')[0].humanize, :alt => image.split('.')[0].humanize }
  end
end

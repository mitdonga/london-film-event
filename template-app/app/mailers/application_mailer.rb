class ApplicationMailer < ActionMailer::Base
  default from: "builder.bx_dev@engineer.ai"
  layout 'mailer'

  private

  def attach_logos
    attachments.inline['logo.png'] = File.read(Rails.root.join("public", "logo.png"))
    attachments.inline['linkedicon.png'] = File.read(Rails.root.join("public", "linkedicon.png"))
    attachments.inline['instagramicon.png'] = File.read(Rails.root.join("public", "instagramicon.png"))
  end

  def remove_water_mark(email_body)
    water_mark_html = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" title="Froala Editor">Froala Editor</a></p>'
    return email_body.gsub(water_mark_html, '')
  end
end

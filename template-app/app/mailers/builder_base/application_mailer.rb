module BuilderBase
  class ApplicationMailer < ::ApplicationMailer
    default from: "builder.bx_dev@engineer.ai"
    layout 'mailer'
  end
end

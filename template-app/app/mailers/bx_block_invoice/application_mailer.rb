module BxBlockInvoice
  class ApplicationMailer < BuilderBase::ApplicationMailer
    default from: "builder.bx_dev@engineer.ai"
    layout "mailer"
  end
end

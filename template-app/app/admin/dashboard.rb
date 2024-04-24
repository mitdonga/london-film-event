module Dashboard
  class Load
    @@loaded_from_gem = false
    def self.is_loaded_from_gem
      @@loaded_from_gem
    end

    def self.loaded
    end

    # Check if this file is loaded from gem directory or not
    # The gem directory looks like
    # /template-app/.gems/gems/bx_block_custom_user_subs-0.0.7/app/admin/subscription.rb
    # if it has block's name in it then it's a gem
    @@loaded_from_gem = Load.method('loaded').source_location.first.include?('bx_block_')
  end
end

unless Dashboard::Load.is_loaded_from_gem
  ActiveAdmin.register_page "Dashboard" do
    menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

    content title: proc { I18n.t("active_admin.dashboard") } do

      panel "Server Information" do
        begin
          config = Rails.application.config
          mailer_config = config.action_mailer
          smtp_settings = mailer_config.smtp_settings
          host = smtp_settings[:address]
          port = smtp_settings[:port]
          smtp_server = Net::SMTP.new(host, port); smtp_server.start; @smtp_server_running = smtp_server.started?
        rescue Exception => e
          error = e
          message = e.message
          @smtp_server_error = message.capitalize
          @smtp_server_running = false
        end

        table_for [
          ["SMTP Status", @smtp_server_running ? "✅ (Running)" : "❌ (Down)"], 
          ["SMTP Error", @smtp_server_error],
          ["Backend URL", Rails.application.config.base_url],
          ["Frontend URL", Rails.application.config.frontend_host]
        ] do
          column "Service Name" do |e|
            e[0]
          end
          column "Status" do |e|
            e[1]
          end
        end
      end
    end 
  end
end

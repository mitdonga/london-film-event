# Be sure to restart your server when you modify this file.

# ActiveSupport::Reloader.to_prepare do
#   ApplicationController.renderer.defaults.merge!(
#     http_host: 'example.org',
#     https: false
#   )
# end
invoices_directory = Rails.root.join('public', 'invoices')
FileUtils.mkdir_p(invoices_directory) unless File.directory?(invoices_directory)

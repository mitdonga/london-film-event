require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.feature "Admin Users", type: :feature do
  before do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save

    visit new_admin_user_session_path
        
    fill_in 'admin_user[email]', with: @admin.email
    fill_in 'admin_user[password]', with: @admin.password
    click_button 'commit'
  end

  scenario "View the list of LF Admins" do
    visit admin_lf_admins_path

    expect(page).to have_content("LF Admins")
  end

  scenario "Dashboard" do
    visit admin_root_path

    expect(page).to have_content("SMTP Status")
    expect(page).to have_content("SMTP Error")
    expect(page).to have_content("Server Information")
    expect(page).to have_content("❌ (Down)")
  end

  scenario "Admin Dashboard" do
    visit admin_dashboard_path

    expect(page).to have_content("SMTP Status")
    expect(page).to have_content("SMTP Error")
    expect(page).to have_content("Server Information")
    expect(page).to have_content("❌ (Down)")
  end

  scenario "Create a new LF Admin" do
    visit new_admin_lf_admin_path

    fill_in "admin_user[email]", with: "newadmin@example.com"
    fill_in "admin_user[password]", with: "password"
    fill_in "admin_user[password_confirmation]", with: "password"

    click_button "commit"

    expect(page).to have_content("LF Admin Details")
    expect(page).to have_content("newadmin@example.com")
  end

  scenario "Edit LF Admin" do
    visit admin_lf_admins_path

    click_link "Edit", match: :first

    expect(page).to have_content("Edit LF Admin")
  end

end

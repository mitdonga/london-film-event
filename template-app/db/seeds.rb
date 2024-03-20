# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admins = ["admin@yopmail.com", "builder@yopmail.com", "londonfilmevents@yopmail.com"]
admins.each do |email|
    unless AdminUser.find_by(email: email)
        AdminUser.create(email: email, password: "password", password_confirmation: "password")
    end
end

unless AdminUser.find_by_email("niranjangowda010@yopmail.com")
    AdminUser.create!(email: "niranjangowda010@yopmail.com", password: "Rajesh@123", password_confirmation: "Rajesh@123")
end

BxBlockRolesPermissions::Role.find_or_create_by(id: 1, name: "Client Admin")
BxBlockRolesPermissions::Role.find_or_create_by(id: 2, name: "Client User")
ActiveRecord::Base.connection.execute('DELETE FROM categories_sub_categories')

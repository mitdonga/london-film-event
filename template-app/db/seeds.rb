# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless AdminUser.find_by_email("admin@ai.com")
    AdminUser.create!(email: "admin@ai.com", password: "123456", password_confirmation: "123456")
end

BxBlockRolesPermissions::Role.find_or_create_by(id: 1, name: "Client Admin")
BxBlockRolesPermissions::Role.find_or_create_by(id: 2, name: "Client User")
ActiveRecord::Base.connection.execute('DELETE FROM categories_sub_categories')

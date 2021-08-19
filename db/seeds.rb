# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# メインのサンプルユーザーを1人作成する
User.create!(name:  "User1",
             email: "user1@example.com",
             password:              "aaaaaa",
             password_confirmation: "aaaaaa")

User.create!(name:  "User2",
             email: "user2@example.com",
             password:              "aaaaaa",
             password_confirmation: "aaaaaa")
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     Moviegenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database..."
Message.destroy_all
Chat.destroy_all
Favorite.destroy_all
Device.destroy_all
Artist.destroy_all
User.destroy_all

# puts "Creating users..."
# user1 = User.create!(email: "alice@example.com", password: "password")
# user2 = User.create!(email: "bob@example.com", password: "password")

# puts "Creating artists..."
# artist1 = Artist.create!(
#   name: "Moog Music",
#   located: "Asheville, NC",
#   genre: "Electronic",
#   picture_url: "https://example.com/moog.jpg"
# )
# artist2 = Artist.create!(
#   name: "Roland",
#   located: "Hamamatsu, Japan",
#   genre: "Synth/Digital",
#   picture_url: "https://example.com/roland.jpg"
# )

# puts "Creating devices..."
# # Note: Devices belong to an Artist
# dev1 = Device.create!(
#   name: "Matriarch",
#   description: "Patchable 4-Note Paraphonic Analog Synthesizer",
#   price: 2000,
#   artist: artist1
# )
# dev2 = Device.create!(
#   name: "TR-808",
#   description: "Classic Rhythm Composer",
#   price: 4000,
#   artist: artist2
# )

# puts "Creating favorites..."
# # Note: Favorites link a User and a Device
# Favorite.create!(user: user1, device: dev1)
# Favorite.create!(user: user1, device: dev2)
# Favorite.create!(user: user2, device: dev2)

# puts "Creating chats and messages..."
# # Note: User -> Chat -> Message
# chat1 = Chat.create!(question: "How do I sync MIDI?", user: user1)
# Message.create!(content: "You can use a 5-pin DIN cable.", role: "assistant", chat: chat1)
# Message.create!(content: "Thanks!", role: "user", chat: chat1)

puts "Finished!"

puts "Cleaning database..."
Message.destroy_all
Favorite.destroy_all
Chat.destroy_all
Device.destroy_all
Artist.destroy_all
User.destroy_all

puts "Creating users..."

user1 = User.create!(email: "alice@example.com", password: "password")
user2 = User.create!(email: "bob@example.com", password: "password")

puts "Creating artists..."

artist1 = Artist.create!(
  name: "Daft Punk",
  located: "Paris, France",
  genre: "Electronic",
  picture_url: "https://example.com/daft-punk.jpg"
)

puts "Creating devices..."

device1 = Device.create!(
  name: "Synthesizer Pro 3000",
  description: "A high-end analog synth used by electronic legends.",
  price: 1500,
  picture_url: "https://example.com/synth.jpg",
  artist: artist1
)

puts "Creating favorites..."

Favorite.create!(user: user1, device: device1)

puts "Creating chats and messages..."

chat1 = Chat.create!(question: "How do I use this synth?", user: user1)
Message.create!(content: "You turn the knobs!", role: "assistant", chat: chat1)
Message.create!(content: "Which knobs specifically?", role: "user", chat: chat1)

puts "Finished! Created #{User.count} users and #{Device.count} devices."

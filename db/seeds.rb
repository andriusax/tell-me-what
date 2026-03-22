puts "Cleaning database..."
Message.destroy_all
Favorite.destroy_all
Chat.destroy_all
Device.destroy_all
Artist.destroy_all
User.destroy_all

puts "Creating users..."

user1 = User.create!(email: "alice@example.com", password: "password")


puts "Creating chats and messages..."

chat1 = Chat.create!(question: "How do I use this synth?", user: user1)
Message.create!(content: "How do I use this synth?", role: "user", chat: chat1)
Message.create!(content: "You turn the knobs!", role: "assistant", chat: chat1)
Message.create!(content: "Which knobs specifically?", role: "user", chat: chat1)

puts "Finished! Created #{User.count} users and #{Chat.count} Chats."

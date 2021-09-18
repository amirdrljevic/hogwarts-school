# Create a Dumbledore user:
albus = User.new(
  name:  "Albus Dumbledore",
  email: "dumbledore@great.com",
  date_of_birth: "1899-09-19",
  bio:           "I am the Great Dumbledore!",
  has_muggle_relatives: "1",
  house:                 "Gryffindor",
  password:              "avada kedavra",
  password_confirmation: "avada kedavra",
  activated:true,
  activated_at: Time.zone.now,
  admin: true
)
albus.skip_this_for_dumbledore = true
albus.save(validate: false)

# Create a main sample user.
User.create!(name:  "Amir Drljevic",
  email: "amirdrljevic@gmail.com",
  date_of_birth: "1999-09-19",
  bio:           Faker::Movies::HarryPotter.quote,
  has_muggle_relatives: "1",
  house:                 ["Gryffindor", "Hufflepuff", "Slytherin", "Ravenclaw"].sample,
  password:              "Mostar123+",
  password_confirmation: "Mostar123+",
  activated:true,
  activated_at: Time.zone.now,
  admin: true)

# Generate a bunch of additional users.
99.times do |n|
name  = Faker::Movies::HarryPotter.character
email = "example-#{n+1}@railstutorial.org"
date_of_birth = "1999-09-19"
bio =           Faker::Movies::HarryPotter.quote
has_muggle_relatives = "1"
house =                 ["Gryffindor", "Hufflepuff", "Slytherin", "Ravenclaw"].sample
password = "Mostar123+"
User.create!(name:  name,
            email: email,
            date_of_birth: date_of_birth,
            bio: bio,
            has_muggle_relatives: has_muggle_relatives,
            house: house,
            password:              password,
            password_confirmation: password,
            activated: true,
            activated_at: Time.zone.now)
end

#Generate spells for a subset of users.
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Movies::HarryPotter.spell
  users.each { |user| user.spells.create!(content: content) }
end

# Create following relationships.
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
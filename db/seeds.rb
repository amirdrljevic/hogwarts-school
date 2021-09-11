# Create a main sample user.
User.create!(name:  "Example User",
  email: "example@railstutorial.org",
  date_of_birth: "1999-09-19",
  bio:           Faker::Movies::HarryPotter.quote,
  has_muggle_relatives: "1",
  house:                 ["Gryffindor", "Hufflepuff", "Slytherin", "Ravenclaw"].sample,
  password:              "Mostar123+",
  password_confirmation: "Mostar123+",
  activated:true,
  activated_at: Time.zone.now)

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
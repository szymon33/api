# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(username: 'guest', password: '123')
user = User.create(username: 'gates', password: '123', role: 'user')
admin = User.create(username: 'jobs', password: '123', role: 'admin')

user_post = Post.create!(
  title: 'Stop Using These 16 Terms to Describe Yourself',
  content: "Do you describe yourself differently -- on your website, promotional materials, or especially on social media -- than you do in person? Do you use cheesy clichés and overblown superlatives and breathless adjectives? Do you write things about yourself you would never have the nerve to actually say?",
  user_id: user.id
)

admin_post = Post.create!(
  title: "12 Reasons Why I Won’t Add You To My LinkedIn Connections",
  content: 'Please allow me to disagree with what your subconscious might be telling you after reading the title of my article. I am neither arrogant nor egotistical.',
  user_id: admin.id
)

user_post.comments.build(
  content: "Content is this and that and don't forget to say it's great!",
  user_id: admin.id
)
user_post.save!

admin_post.comments.build(
  content: "Europe's fastest growing online auction house, featuring a wide range of special objects. Have a look at our auctions and place your bids!",
  user_id: user.id
)
admin_post.save!

user_post.like

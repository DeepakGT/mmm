puts "seed started..."
if User.root.none?
  User.new(email: 'root@yopmail.com', password: '123456', name: "root_user", role: "root", status: "active", parent_id: nil, mobile: "+919632587412", country: "IN", time_zone: "Kolkata", wallet_number: "15sdfd56f4d56fds", read_agreement: true).save!(validate: false)
end
puts "seed completed successfully"
puts "Thank You!"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
# Create admin user from environment variables or defaults
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

admin = AdminUser.find_or_initialize_by(email: admin_email)
if admin.new_record?
  admin.password = admin_password
  admin.password_confirmation = admin_password
  admin.save!
  puts "Created admin user: #{admin_email}"
  puts "API Token: #{admin.api_token}"
else
  puts "Admin user already exists: #{admin_email}"
end

# Create some sample thoughts in development
if Rails.env.development?
  sample_thoughts = [
    { content: "Just shipped a new feature! The feeling never gets old.", tags: [ "dev", "shipping" ] },
    { content: "Reading about distributed systems today. Fascinating stuff.", tags: [ "learning", "tech" ] },
    { content: "Coffee and code. The perfect morning.", tags: [ "coffee", "morning" ] },
    { content: "Simplicity is the ultimate sophistication.", tags: [ "design", "philosophy" ] },
    { content: "Remember: done is better than perfect.", tags: [ "productivity", "advice" ] }
  ]

  sample_thoughts.each do |attrs|
    Thought.find_or_create_by!(content: attrs[:content]) do |thought|
      thought.tags = attrs[:tags]
    end
  end

  puts "Created #{sample_thoughts.count} sample thoughts"
end

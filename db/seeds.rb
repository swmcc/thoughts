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

# Create sample thoughts in development
if Rails.env.development?
  # Clear existing thoughts for fresh seed
  Thought.destroy_all

  sample_thoughts = [
    # Recent (within last hour)
    { content: "Just deployed a new feature. Feels good!", tags: %w[dev shipping], ago: 5.minutes },
    { content: "Coffee break. Best part of the morning.", tags: %w[coffee life], ago: 15.minutes },
    { content: "Debugging is like being a detective in a crime movie where you're also the murderer.", tags: %w[dev humor], ago: 32.minutes },

    # Today
    { content: "Reading about distributed systems. Fascinating stuff.", tags: %w[learning tech], ago: 2.hours },
    { content: "Simplicity is the ultimate sophistication.", tags: %w[design philosophy], ago: 4.hours },
    { content: "Remember: done is better than perfect.", tags: %w[productivity advice], ago: 6.hours },
    { content: "Hot take: tabs > spaces. Fight me.", tags: %w[dev opinions], ago: 8.hours },
    { content: "Finally fixed that bug that's been haunting me for days.", tags: %w[dev victory], ago: 10.hours },

    # Yesterday
    { content: "The best code is no code at all.", tags: %w[dev philosophy], ago: 1.day },
    { content: "Pair programming session went great today.", tags: %w[dev teamwork], ago: 1.day + 2.hours },
    { content: "Learning Rust. My brain hurts but in a good way.", tags: %w[rust learning], ago: 1.day + 5.hours },
    { content: "Code reviews are acts of kindness.", tags: %w[dev culture], ago: 1.day + 8.hours },

    # This week
    { content: "Refactored 500 lines into 50. Chef's kiss.", tags: %w[dev refactoring], ago: 2.days },
    { content: "Documentation is a love letter to your future self.", tags: %w[dev docs], ago: 2.days + 3.hours },
    { content: "Wrote my first test today. Should've done it sooner.", tags: %w[testing dev], ago: 3.days },
    { content: "GraphQL or REST? Why not both?", tags: %w[api dev], ago: 3.days + 6.hours },
    { content: "The rubber duck debugging method actually works.", tags: %w[dev debugging], ago: 4.days },
    { content: "Kubernetes is just spicy Docker.", tags: %w[devops humor], ago: 4.days + 4.hours },
    { content: "Wrote a one-liner that I'll never understand again.", tags: %w[dev regex], ago: 5.days },
    { content: "Meeting that could've been an email. Classic.", tags: %w[work life], ago: 5.days + 7.hours },
    { content: "Finally understand monads. I think.", tags: %w[functional programming], ago: 6.days },
    { content: "SSH keys are just fancy passwords.", tags: %w[security dev], ago: 6.days + 5.hours },

    # Last week
    { content: "Vim or Emacs? I choose VS Code and run.", tags: %w[editors humor], ago: 8.days },
    { content: "Legacy code is just code without tests.", tags: %w[testing dev], ago: 9.days },
    { content: "The cloud is just someone else's computer.", tags: %w[cloud humor], ago: 10.days },
    { content: "Premature optimization is the root of all evil.", tags: %w[dev wisdom], ago: 11.days },
    { content: "Git rebase vs merge: the eternal debate.", tags: %w[git dev], ago: 12.days },
    { content: "TypeScript: JavaScript that went to finishing school.", tags: %w[typescript javascript], ago: 13.days },

    # Two weeks ago
    { content: "Microservices: because one problem wasn't enough.", tags: %w[architecture humor], ago: 14.days },
    { content: "Stack Overflow saved my life today. Again.", tags: %w[dev gratitude], ago: 15.days },
    { content: "Writing clean code is an act of empathy.", tags: %w[dev philosophy], ago: 16.days },
    { content: "The best error message is no error at all.", tags: %w[ux dev], ago: 17.days },
    { content: "Agile is a mindset, not a meeting schedule.", tags: %w[agile work], ago: 18.days },
    { content: "Every senior dev was once a junior who didn't give up.", tags: %w[career advice], ago: 19.days },

    # Three weeks ago
    { content: "Code smell: when your instincts say something's wrong.", tags: %w[dev quality], ago: 20.days },
    { content: "The only constant in tech is change.", tags: %w[tech philosophy], ago: 21.days },
    { content: "Imposter syndrome hits different at 2am debugging.", tags: %w[dev mental_health], ago: 22.days },
    { content: "Good APIs are like good jokes: they need no explanation.", tags: %w[api design], ago: 23.days },
    { content: "Technical debt is just procrastination with interest.", tags: %w[dev wisdom], ago: 24.days },
    { content: "The best feature is the one users actually need.", tags: %w[product dev], ago: 25.days },

    # A month ago
    { content: "Learned a new language this month. Brain expanded.", tags: %w[learning growth], ago: 30.days },
    { content: "Open source: standing on the shoulders of giants.", tags: %w[opensource community], ago: 31.days },
    { content: "The terminal is my happy place.", tags: %w[cli dev], ago: 32.days },
    { content: "Automated tests are like insurance: boring until you need them.", tags: %w[testing wisdom], ago: 33.days },
    { content: "A good commit message is worth a thousand comments.", tags: %w[git dev], ago: 34.days },
    { content: "Naming things is hard. Really hard.", tags: %w[dev truth], ago: 35.days },

    # 5-6 weeks ago
    { content: "The best debugging tool is a good night's sleep.", tags: %w[health dev], ago: 38.days },
    { content: "Code is poetry. Sometimes bad poetry, but poetry.", tags: %w[dev creative], ago: 40.days },
    { content: "Every bug is a learning opportunity in disguise.", tags: %w[dev mindset], ago: 42.days },
    { content: "The best time to write tests was yesterday.", tags: %w[testing advice], ago: 44.days },

    # Two months ago
    { content: "Functional programming changed how I think.", tags: %w[functional learning], ago: 50.days },
    { content: "Comments lie. Code doesn't.", tags: %w[dev wisdom], ago: 52.days },
    { content: "The fastest code is code that doesn't run.", tags: %w[performance optimization], ago: 55.days },
    { content: "Good software is software that ships.", tags: %w[shipping advice], ago: 58.days },
    { content: "Abstractions are great until they leak.", tags: %w[architecture dev], ago: 60.days },

    # Three months ago
    { content: "Started this coding journey years ago. Still learning.", tags: %w[career reflection], ago: 75.days },
    { content: "The best documentation is code that explains itself.", tags: %w[docs dev], ago: 80.days },
    { content: "Debugging: removing bugs you put there yourself.", tags: %w[debugging humor], ago: 85.days },
    { content: "A language that doesn't affect how you think isn't worth learning.", tags: %w[programming wisdom], ago: 90.days },

    # Older
    { content: "Hello, World! My first thought.", tags: %w[meta beginning], ago: 120.days }
  ]

  # Generate more random thoughts to reach 100
  topics = [
    { content: "Just pushed to production on a Friday. Living dangerously.", tags: %w[dev yolo] },
    { content: "Reading RFC docs like bedtime stories.", tags: %w[dev learning] },
    { content: "The compiler is my frenemy.", tags: %w[dev programming] },
    { content: "Making progress, one commit at a time.", tags: %w[dev progress] },
    { content: "Late night coding session. No regrets.", tags: %w[dev nightowl] },
    { content: "That moment when your code works first try.", tags: %w[dev miracle] },
    { content: "Refactoring is self-care for codebases.", tags: %w[dev refactoring] },
    { content: "The joy of deleting code.", tags: %w[dev satisfaction] },
    { content: "Built something cool today.", tags: %w[dev building] },
    { content: "Learning in public. Scary but worth it.", tags: %w[learning community] },
    { content: "Took a break. Came back with the solution.", tags: %w[dev breaks] },
    { content: "Types are just documentation that doesn't lie.", tags: %w[typescript types] },
    { content: "The art of asking good questions.", tags: %w[learning growth] },
    { content: "Every expert was once a beginner.", tags: %w[motivation learning] },
    { content: "Ship it, then iterate.", tags: %w[shipping advice] },
    { content: "Code reviews teach more than tutorials.", tags: %w[dev learning] },
    { content: "The best tool is the one you know.", tags: %w[dev tools] },
    { content: "Consistency beats perfection.", tags: %w[productivity wisdom] },
    { content: "Small steps, big progress.", tags: %w[growth mindset] },
    { content: "Today's hack is tomorrow's tech debt.", tags: %w[dev warning] },
    { content: "Reading other people's code is humbling.", tags: %w[dev learning] },
    { content: "The bug was in the last place I looked. Obviously.", tags: %w[debugging humor] },
    { content: "Solved it! Time for a victory lap.", tags: %w[dev celebration] },
    { content: "New framework, who dis?", tags: %w[javascript frameworks] },
    { content: "Back to basics today.", tags: %w[fundamentals learning] },
    { content: "Automation is the gift that keeps on giving.", tags: %w[devops automation] },
    { content: "The quiet satisfaction of green tests.", tags: %w[testing satisfaction] },
    { content: "Mentoring is teaching and learning at once.", tags: %w[mentoring growth] },
    { content: "Sometimes the answer is to start over.", tags: %w[dev wisdom] },
    { content: "Wrote something I'm proud of today.", tags: %w[dev pride] },
    { content: "The internet is amazing.", tags: %w[tech gratitude] },
    { content: "Keeping it simple.", tags: %w[design simplicity] },
    { content: "Another day, another PR.", tags: %w[dev routine] },
    { content: "Found a gem of a library today.", tags: %w[dev discovery] },
    { content: "The power of a good abstraction.", tags: %w[architecture design] },
    { content: "Fixing one bug, finding three more.", tags: %w[debugging reality] }
  ]

  # Add more thoughts with varied dates to reach 100
  remaining = 100 - sample_thoughts.length
  remaining.times do |i|
    topic = topics[i % topics.length]
    days_ago = rand(1..180)
    hours_ago = rand(0..23)
    sample_thoughts << {
      content: topic[:content],
      tags: topic[:tags],
      ago: days_ago.days + hours_ago.hours
    }
  end

  # Create thoughts with backdated timestamps
  sample_thoughts.each do |attrs|
    thought = Thought.create!(
      content: attrs[:content],
      tags: attrs[:tags],
      view_count: rand(0..50)
    )
    # Update created_at directly in database to bypass Rails
    thought.update_columns(created_at: attrs[:ago].ago, updated_at: attrs[:ago].ago)
  end

  puts "Created #{Thought.count} sample thoughts"
end

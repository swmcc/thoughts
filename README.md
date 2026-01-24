# Thoughts

A modern Twitter/X-style "Thoughts" app with 140-character posts, tags, timestamps, and view tracking. Features a beautiful public timeline, secure admin interface, and full JSON API for iOS app integration.

## Features

- 140-character thoughts with tags
- Modern, responsive timeline UI with dark mode
- Tag-based filtering
- View count tracking
- Secure admin interface with session-based auth
- Full JSON API with token authentication
- iOS app ready

## Tech Stack

- Ruby 3.4.4
- Rails 8.1
- PostgreSQL (with array columns for tags)
- Tailwind CSS 4
- Stimulus.js
- RSpec + FactoryBot + Capybara

## Getting Started

### Prerequisites

- Ruby 3.4.4
- PostgreSQL
- Node.js (for asset compilation)

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd thoughts

# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate db:seed

# Start the development server
bin/dev
```

### Environment Variables

```bash
ADMIN_EMAIL=admin@example.com      # Default admin email
ADMIN_PASSWORD=your-password       # Default admin password
```

## Usage

### Public Timeline

Visit `http://localhost:3000` to view the public timeline.

- Click on tags to filter thoughts
- Click on individual thoughts for full view
- Toggle dark mode with the sun/moon icon

### Admin Interface

Visit `http://localhost:3000/admin` to access the admin interface.

- Create, edit, and delete thoughts
- View statistics (view counts)
- Copy your API token for iOS app

### JSON API

#### Public Endpoints (no auth required)

```bash
# List all thoughts
GET /api/thoughts
GET /api/thoughts?tag=rails&page=1&per_page=20

# Get single thought
GET /api/thoughts/:id

# Get all tags
GET /api/tags
```

#### Authenticated Endpoints (Bearer token required)

```bash
# Create thought
POST /api/thoughts
Authorization: Bearer YOUR_API_TOKEN
Content-Type: application/json

{
  "thought": {
    "content": "Hello world!",
    "tags": ["greeting"]
  }
}

# Update thought
PATCH /api/thoughts/:id
Authorization: Bearer YOUR_API_TOKEN

# Delete thought
DELETE /api/thoughts/:id
Authorization: Bearer YOUR_API_TOKEN
```

## Testing

```bash
# Run all tests
bin/rspec

# Run specific test types
bin/rspec spec/models
bin/rspec spec/requests
bin/rspec spec/system
```

## Project Structure

```
app/
  controllers/
    thoughts_controller.rb      # Public timeline
    api/
      base_controller.rb        # API authentication
      thoughts_controller.rb    # JSON API
      tags_controller.rb        # Tags endpoint
    admin/
      base_controller.rb        # Admin authentication
      thoughts_controller.rb    # Admin CRUD
      sessions_controller.rb    # Login/logout
  javascript/
    controllers/
      character_counter_controller.js  # 140 char counter
      tag_input_controller.js          # Tag chips input
      theme_controller.js              # Dark mode toggle
  models/
    thought.rb                  # 140 char limit, tags array
    admin_user.rb               # has_secure_password, api_token
  views/
    layouts/
      application.html.erb      # Public layout
      admin.html.erb            # Admin layout
    thoughts/                   # Public views
    admin/thoughts/             # Admin views
    shared/
      _thought_card.html.erb    # Reusable thought card
```

## License

MIT

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
# List all top-level thoughts (excludes replies)
GET /api/thoughts
GET /api/thoughts?tag=rails&page=1&per_page=20

# Get single thought with replies
GET /api/thoughts/:id

# Get complete thread (root thought with all nested replies)
GET /api/thoughts/:id/thread

# Get all tags
GET /api/tags
```

#### Authenticated Endpoints (Bearer token required)

```bash
# Create thought (optionally as a reply)
POST /api/thoughts
Authorization: Bearer YOUR_API_TOKEN
Content-Type: application/json

{
  "thought": {
    "content": "Hello world!",
    "tags": ["greeting"],
    "parent_id": "abc123XYZ456"  # Optional: public_id of parent thought
  }
}

# Response (201 Created)
{
  "thought": {
    "id": "xyz789ABC123",
    "content": "Hello world!",
    "tags": ["greeting"],
    "source": "web",
    "created_at": "2024-01-15T10:30:00Z",
    "parent_id": null,              # null if top-level, parent's public_id if reply
    "reply_count": 0,
    "replies": []                   # Only populated on GET /api/thoughts/:id
  }
}

# Error: unknown parent (422 Unprocessable Content)
{
  "errors": {
    "parent_id": ["does not exist"]
  }
}

# Update thought
PATCH /api/thoughts/:id
Authorization: Bearer YOUR_API_TOKEN

# Delete thought
DELETE /api/thoughts/:id
Authorization: Bearer YOUR_API_TOKEN
```

#### Response Fields

- `id`: Public ID of the thought (used in URLs)
- `content`: 140-character thought text
- `tags`: Array of tags
- `source`: Origin of post (`web`, `cli`, or `iphone`)
- `created_at`: ISO 8601 timestamp
- `parent_id`: Public ID of parent thought (null for top-level thoughts)
- `reply_count`: Number of direct replies
- `replies`: Nested array of reply thoughts (only included on `GET /api/thoughts/:id` and `GET /api/thoughts/:id/thread`, oldest first)

### Command Line Interface

Post thoughts directly from your terminal using the included CLI script.

#### Installation

```bash
# Symlink to your PATH
ln -s /path/to/thoughts/bin/thought /usr/local/bin/thought

# Initialize configuration
thought --init
```

#### Configuration

The CLI stores config in `~/.config/thoughts/config`:

```bash
THOUGHTS_API_URL=https://your-domain.com/api/thoughts
THOUGHTS_API_TOKEN=your-api-token
```

#### Usage

```bash
# Post a thought
thought "Hello world"

# Post with tags
thought -t coding "Working on a new feature"
thought -t work,meeting "Standup done"

# Reply to a thought (use parent's public_id)
thought -r abc123XYZ456 "Replying to that"
thought --reply=abc123XYZ456 -t coding "Tagged reply"

# Pipe input
echo "Quick note" | thought -t idea
echo "Piped reply" | thought -r abc123XYZ456
```

#### Commands

| Command | Description |
|---------|-------------|
| `thought "content"` | Post a thought |
| `thought -t tag "content"` | Post with tags |
| `thought -r id "content"` | Post as reply to a thought |
| `thought --init` | Setup configuration |
| `thought --config` | Show current config |
| `thought --help` | Show help |

#### Threaded Replies

Use the `-r` or `--reply` flag to respond to an existing thought:

```bash
# Reply to a thought
thought -r abc123XYZ456 "Great point!"

# Chain replies using the returned ID
thought -r abc123XYZ456 "First reply"
thought -r xyz789ABC123 "Reply to the reply"
```

The CLI will display the parent's public_id when posting a reply, allowing you to chain further replies from the terminal.

See [doc/cli.md](doc/cli.md) for full documentation.

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

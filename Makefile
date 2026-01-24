APP_NAME=thoughts
RAILS_ENV ?= development

GREEN := $(shell tput -Txterm setaf 2)
RESET := $(shell tput -Txterm sgr0)

.DEFAULT_GOAL := help

# -----------------------------
# 🧩 Local Development
# -----------------------------

local.run: ## Run the Rails app (with bin/dev)
	@echo "$(GREEN)==> Running $(APP_NAME) in $(RAILS_ENV)...$(RESET)"
	bin/dev

local.setup: ## Install gems, setup db and tailwind, seed
	@echo "$(GREEN)==> Setting up $(APP_NAME)...$(RESET)"
	bundle install
	bin/rails db:create
	bin/rails db:migrate
	bin/rails db:seed
	bin/dev

local.install: ## Just install dependencies
	bundle install

local.db.create: ## Create the database
	bin/rails db:create

local.db.drop: ## Drop the database
	bin/rails db:drop

local.db.migrate: ## Run database migrations
	bin/rails db:migrate

local.db.seed: ## Seed the database
	bin/rails db:seed

local.db.reset: ## Reset the database (drop, create, migrate, seed)
	bin/rails db:reset

console: ## Start Rails console
	bin/rails console

# -----------------------------
# 🧪 Testing
# -----------------------------

local.test: ## Run all RSpec tests
	bin/rspec

local.test.models: ## Run model specs
	bin/rspec spec/models

local.test.requests: ## Run request specs
	bin/rspec spec/requests

local.test.system: ## Run system specs (browser tests)
	bin/rspec spec/system

local.test.fast: ## Run tests excluding system specs
	bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"

# -----------------------------
# 🔍 Linting & Security
# -----------------------------

lint: ## Run RuboCop linting
	bundle exec rubocop

lint.fix: ## Auto-fix RuboCop issues
	bundle exec rubocop -A

local.brakeman: ## Run Brakeman static security analysis
	bin/brakeman --exit-on-warn --no-pager

local.rubocop: ## Run RuboCop with auto-fix
	rubocop -A

# -----------------------------
# 🎨 Assets
# -----------------------------

local.assets.build: ## Build Tailwind CSS
	bin/rails tailwindcss:build

local.assets.watch: ## Watch and rebuild Tailwind CSS
	bin/rails tailwindcss:watch

# -----------------------------
# 🧰 Meta
# -----------------------------

help: ## Show all available make targets
	@echo "$(GREEN)Available targets:$(RESET)"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

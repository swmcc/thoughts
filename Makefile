APP_NAME=thoughts
RAILS_ENV ?= development

GREEN := $(shell tput -Txterm setaf 2)
RESET := $(shell tput -Txterm sgr0)

# Use bash with RVM loaded
SHELL := /bin/bash
RVM := source ~/.rvm/scripts/rvm && rvm use 3.4.4 &&

.DEFAULT_GOAL := help

# -----------------------------
# 🧩 Local Development
# -----------------------------

local.run: ## Run the Rails app (with bin/dev)
	@echo "$(GREEN)==> Running $(APP_NAME) in $(RAILS_ENV)...$(RESET)"
	$(RVM) bin/dev

local.setup: ## Install gems, setup db and tailwind, seed
	@echo "$(GREEN)==> Setting up $(APP_NAME)...$(RESET)"
	$(RVM) bundle install
	$(RVM) bin/rails db:create
	$(RVM) bin/rails db:migrate
	$(RVM) bin/rails db:seed
	@echo "$(GREEN)==> Setup complete! Run 'make local.run' to start the server.$(RESET)"

local.install: ## Just install dependencies
	$(RVM) bundle install

local.db.create: ## Create the database
	$(RVM) bin/rails db:create

local.db.drop: ## Drop the database
	$(RVM) bin/rails db:drop

local.db.migrate: ## Run database migrations
	$(RVM) bin/rails db:migrate

local.db.seed: ## Seed the database
	$(RVM) bin/rails db:seed

local.db.reset: ## Reset the database (drop, create, migrate, seed)
	$(RVM) bin/rails db:reset

console: ## Start Rails console
	$(RVM) bin/rails console

# -----------------------------
# 🧪 Testing
# -----------------------------

local.test: ## Run all RSpec tests
	$(RVM) bin/rspec

local.test.models: ## Run model specs
	$(RVM) bin/rspec spec/models

local.test.requests: ## Run request specs
	$(RVM) bin/rspec spec/requests

local.test.system: ## Run system specs (browser tests)
	$(RVM) bin/rspec spec/system

local.test.fast: ## Run tests excluding system specs
	$(RVM) bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"

# -----------------------------
# 🔍 Linting & Security
# -----------------------------

lint: ## Run RuboCop linting
	$(RVM) bundle exec rubocop

lint.fix: ## Auto-fix RuboCop issues
	$(RVM) bundle exec rubocop -A

local.brakeman: ## Run Brakeman static security analysis
	$(RVM) bin/brakeman --exit-on-warn --no-pager

local.rubocop: ## Run RuboCop with auto-fix
	$(RVM) rubocop -A

# -----------------------------
# 🎨 Assets
# -----------------------------

local.assets.build: ## Build Tailwind CSS
	$(RVM) bin/rails tailwindcss:build

local.assets.watch: ## Watch and rebuild Tailwind CSS
	$(RVM) bin/rails tailwindcss:watch

# -----------------------------
# 🧰 Meta
# -----------------------------

help: ## Show all available make targets
	@echo "$(GREEN)Available targets:$(RESET)"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# Minidost: Construction Task Management Platform

## Project Overview

Minidost is a comprehensive web application designed specifically for the construction industry, providing a robust platform for contractors and subcontractors to manage tasks, communicate, and collaborate efficiently.

## Key Features

### 1. User Management System
- **Dual Role Architecture**: 
  - Contractors can post tasks, review applications, and manage subcontractors
  - Subcontractors can browse, apply for, and manage assigned tasks
- **Detailed User Profiles**:
  - Company information
  - Professional skills and specializations
  - Contact details
  - Verification and authentication mechanisms

### 2. Task Management
- **Task Creation and Tracking**:
  - Detailed task descriptions
  - Location-based task assignments
  - Status tracking (pending, in progress, completed)
  - Skill-based task matching
- **Task Application Process**:
  - Subcontractors can apply for tasks
  - Contractors can review and approve/reject applications
  - Comprehensive application review system

### 3. Communication Tools
- **Integrated Messaging System**:
  - Real-time chat between contractors and subcontractors
  - Task-specific communication channels
- **Notification System**:
  - Real-time web socket notifications
  - Updates on task status changes
  - Application reviews
  - New messages
  - System alerts

### 4. Geolocation and Mapping
- **Address Autocomplete**
- **Task Location Visualization**
- **Proximity-based task discovery**

### 5. Multilingual Support
- Internationalization (i18n) support
- Currently supports English and French languages
- Localized content for different regions

### 6. Security and Authentication
- Secure user authentication
- Role-based access control
- Password reset functionality
- Secure communication channels

## Technical Architecture

- **Backend**: Ruby on Rails
- **Frontend**: HTML, CSS, JavaScript
- **Database**: PostgreSQL
- **Real-time Communication**: Action Cable (WebSockets)
- **Authentication**: Devise gem
- **Internationalization**: Rails I18n

## Development Philosophy

Minidost is built with a focus on:
- User-friendly interface
- Seamless communication
- Efficient task management
- Robust security
- Scalability and performance

## Prerequisites

### System Requirements
- Ruby version: 3.0.0 or higher
- Rails version: 7.1
- PostgreSQL 12.0 or higher
- Node.js 14.0 or higher
- Yarn package manager

### Required Gems and Extensions

#### Core Gems
```ruby
# Authentication
gem 'devise', '~> 4.9.2'  # User authentication and authorization

# Authorization
gem 'pundit', '~> 2.3.0'  # Role-based access control

# Task and User Management
gem 'friendly_id', '~> 5.5.0'  # Slug generation for user and task URLs
gem 'acts_as_list', '~> 1.1.0'  # Ordering tasks and applications

# Geolocation and Mapping
gem 'geocoder', '~> 1.8.1'  # Address and location services
gem 'geokit-rails', '~> 2.3.2'  # Geolocation utilities

# Internationalization
gem 'rails-i18n', '~> 7.0.7'  # Localization support
gem 'devise-i18n', '~> 1.11.0'  # Devise translations

# Communication and Notifications
gem 'noticed', '~> 1.6.3'  # Notification system
gem 'mailgun-ruby', '~> 1.2.5'  # Email services

# Performance and Background Jobs
gem 'sidekiq', '~> 7.1.2'  # Background job processing
gem 'redis', '~> 4.8.1'  # Caching and job queues

# API and Serialization
gem 'active_model_serializers', '~> 0.10.13'  # JSON serialization
gem 'jbuilder', '~> 2.11.5'  # JSON generation

# Frontend
gem 'importmap-rails', '~> 1.2.1'  # JavaScript import maps
gem 'turbo-rails', '~> 1.4.0'  # Turbo drive for faster page loads
gem 'stimulus-rails', '~> 1.2.1'  # Stimulus.js for frontend interactivity

# Security
gem 'rack-attack', '~> 6.6.1'  # Request throttling and blocking
gem 'brakeman', '~> 6.0.0'  # Security vulnerability scanner
```

#### Development and Testing Gems
```ruby
group :development, :test do
  gem 'rspec-rails', '~> 6.0.3'  # Testing framework
  gem 'factory_bot_rails', '~> 6.2.0'  # Test data generation
  gem 'faker', '~> 3.2.0'  # Fake data generation
  gem 'rubocop', '~> 1.50.2'  # Code style enforcement
  gem 'bullet', '~> 7.0.7'  # N+1 query detection
  gem 'annotate', '~> 3.2.0'  # Database schema annotations
end
```

## Project Setup and Installation

### 1. Clone the Repository
```bash
# HTTPS
git clone https://github.com/yourusername/minidost.git

# SSH (recommended)
git clone git@github.com:yourusername/minidost.git

# Change to project directory
cd minidost
```

### 2. Install Dependencies
```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
yarn install

# Install system dependencies (Ubuntu/Debian example)
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib libpq-dev
```

### 3. Configure Database
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed initial data
rails db:seed
```

### 4. Set Up Environment Variables
Create a `.env` file in the project root and add:
```
DATABASE_USERNAME=your_postgres_username
DATABASE_PASSWORD=your_postgres_password
MAILGUN_API_KEY=your_mailgun_api_key
GEOCODING_API_KEY=your_geocoding_service_key
```

### 5. Start the Development Server
```bash
# Start Rails server
rails server

# In a separate terminal, start Sidekiq for background jobs
bundle exec sidekiq

# Optional: Start webpack dev server for hot reloading
./bin/dev
```

## Troubleshooting

- Ensure all gems are compatible with your Ruby and Rails versions
- Check PostgreSQL service is running
- Verify Node.js and Yarn are correctly installed
- Run `bundle update` if you encounter gem compatibility issues

## Recommended Development Tools

- Visual Studio Code with Ruby and Rails extensions
- Postman for API testing
- Redis Desktop Manager
- PostgreSQL management tool (e.g., Postico, pgAdmin)

## Contributing

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

Licensed under the MIT License. See LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact our support team.

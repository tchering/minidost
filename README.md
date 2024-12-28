# Minidost

Minidost is a project management and subcontractor collaboration platform designed to streamline the process of managing construction tasks, contracts, and communications between contractors and subcontractors.

## Features

* **User Management**: Supports contractor and subcontractor roles with detailed profiles.
* **Task Management**: Create, update, and manage tasks with specific details for different types of work.
* **Contract Management**: Generate, sign, and manage contracts between contractors and subcontractors.
* **Communication**: Integrated messaging system for seamless communication.
* **Notifications**: Real-time notifications for task updates and messages.
* **Geolocation**: Map integration to visualize task locations and user addresses.

## Getting Started

### Prerequisites

* Ruby version: 3.0.0
* Rails version: 7.1
* PostgreSQL

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/minidost.git
   cd minidost
   ```

2. Install dependencies:
   ```sh
   bundle install
   yarn install
   ```

3. Set up the database:
   ```sh
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start the server:
   ```sh
   rails server
   ```

### Configuration

* Ensure you have the necessary environment variables set up for database and API keys.

### Running Tests

* To run the test suite:
  ```sh
  rails test
  ```

### Deployment

* Follow standard Rails deployment practices for your chosen platform (e.g., Heroku, AWS).

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License.

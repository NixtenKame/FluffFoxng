# frozen_string_literal: true

# Load the Rails application.
require_relative "application"

# What is this for? Is this part of production environment? I used .env.production and I wonder if I was supposed to use .env.local for production XD
Dotenv.load(Rails.root + ".env.local")

# Initialize the Rails application.
Rails.application.initialize!

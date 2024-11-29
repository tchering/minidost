# frozen_string_literal: true

Geocoder.configure(
  # timeout: 5,          # Set the timeout for geocoding requests to 5 seconds
  # lookup: :nominatim,  # Use the Nominatim service for geocoding
  units: :km # Set the units for distance calculations to kilometers
  # language: :fr        # Set the language for the geocoding results to French
)

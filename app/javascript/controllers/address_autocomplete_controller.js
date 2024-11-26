// app/javascript/controllers/address_autocomplete_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["street", "city", "areaCode", "results"];
  static values = {
    apiKey: String,
  };

  connect() {
    // Create results container
    this.resultsTarget.style.display = "none";
    console.log("Autocomplete controller connected");
  }

  // Search as user types in street field
  async search() {
    const query = this.streetTarget.value;
    if (query.length < 3) {
      this.resultsTarget.style.display = "none";
      return;
    }

    const response = await fetch(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${query}.json?` +
        `access_token=${this.apiKeyValue}&` +
        `country=FR&` + // Restrict to France
        `types=address&` + // Return only addresses
        `language=fr`
    );

    const data = await response.json();
    this.showResults(data.features);
  }

  showResults(features) {
    this.resultsTarget.innerHTML = "";
    this.resultsTarget.style.display = features.length ? "block" : "none";

    features.forEach((feature) => {
      const div = document.createElement("div");
      div.classList.add("p-2", "hover:bg-gray-100", "cursor-pointer");
      div.textContent = feature.place_name;
      div.addEventListener("click", () => this.selectAddress(feature));
      this.resultsTarget.appendChild(div);
    });
  }

  selectAddress(feature) {
    // Extract address components
    const parts = feature.context || [];
    const postcode = parts.find((p) => p.id.includes("postcode"));
    const city = parts.find((p) => p.id.includes("place"));

    // Populate form fields
    this.streetTarget.value = feature.text || "";
    this.cityTarget.value = city?.text || "";
    this.areaCodeTarget.value = postcode?.text || "";

    this.resultsTarget.style.display = "none";
  }
}

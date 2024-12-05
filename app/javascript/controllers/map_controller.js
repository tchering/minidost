// Stimulus Controller base class import गर्नुहोस्
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // HTML data attributes (_map.html.erb बाट) बाट प्राप्त हुने values define गर्नुहोस्
  static values = {
    markers: Array, // Rails बाट data-map-markers-value द्वारा markers data प्राप्त हुन्छ
    apiKey: String, // Mapbox API key data-map-api-key-value द्वारा प्राप्त हुन्छ
  };

  // Controller element मा connect हुँदा automatically call हुने method
  connect() {
    try {
      // application.html.erb बाट CDN द्वारा Mapbox GL JS load भएको छ कि छैन जाँच गर्नुहोस्
      if (!window.mapboxgl) {
        console.error("Mapbox GL JS not loaded");
        return;
      }

      // Rails credentials बाट प्राप्त apiKey value बाट Mapbox access token सेट गर्नुहोस्
      window.mapboxgl.accessToken = this.apiKeyValue;

      // नयाँ Mapbox map instance initialize गर्नुहोस्
      this.map = new window.mapboxgl.Map({
        container: this.element, // यो controller attach भएको div element प्रयोग हुन्छ | _map.html.erb बाट प्राप्त हुने
        style: "mapbox://styles/mapbox/light-v10", // Mapbox style URL
        // France देखाउने गरी map को initial bounds सेट गर्नुहोस्
        bounds: [-5.1406, 41.3337, 9.5593, 51.0891],
        fitBoundsOptions: {
          padding: 50, // Bounds वरिपरि padding थप्छ
        },
        // Map को panning France मा restrict गर्नुहोस्
        maxBounds: [
          [-5.1406, 41.3337], // Southwest coordinates
          [9.5593, 51.0891], // Northeast coordinates
        ],
        minZoom: 5, // धेरै टाढा zoom out गर्न रोक्छ
        maxZoom: 12, // धेरै नजिक zoom in गर्न रोक्छ
      });

      // जब map load हुन्छ
      this.map.on("load", () => {
        // French departments को GeoJSON layer add गर्नुहोस्
        this.#addDepartmentsLayer();
        // Rails controller बाट प्राप्त markers map मा add गर्नुहोस्
        this.#addMarkersToMap();
      });
    } catch (error) {
      console.error("Error initializing map:", error);
    }
  }

  // Map मा French departments add गर्ने private method
  #addDepartmentsLayer() {
    // Departments को GeoJSON source add गर्नुहोस्
    this.map.addSource("departments", {
      type: "geojson",
      // बाहिरी स्रोतबाट GeoJSON data load गर्नुहोस्
      data: "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson",
    });

    // Departments को fill layer add गर्नुहोस्
    this.map.addLayer({
      id: "department-fills",
      type: "fill",
      source: "departments", // माथि define गरिएको source प्रयोग हुन्छ
      paint: {
        "fill-color": "#627BC1",
        "fill-opacity": 0.1,
      },
    });

    // Departments को border layer add गर्नुहोस्
    this.map.addLayer({
      id: "department-borders",
      type: "line",
      source: "departments", // उही source प्रयोग हुन्छ
      paint: {
        "line-color": "#627BC1",
        "line-width": 1,
      },
    });
  }

  // Map मा markers add गर्ने private method
  #addMarkersToMap() {
    // यदि कुनै markers data प्राप्त भएन भने return गर्नुहोस्
    if (!this.markersValue) return;

    // Rails controller बाट प्राप्त markers मा iterate गर्नुहोस्
    this.markersValue.forEach((marker) => {
      // Custom marker element बनाउनुहोस्
      const customMarker = document.createElement("div");
      customMarker.className = `custom-marker ${marker.status}`;
      customMarker.style.backgroundImage = `url('${marker.image_url}')`;
      customMarker.style.width = "30px";
      customMarker.style.height = "30px";
      customMarker.style.backgroundSize = "cover";
      customMarker.style.borderRadius = "50%";
      customMarker.style.border = "2px solid #fff";
      customMarker.style.boxShadow = "0 0 10px rgba(0,0,0,0.2)";

      // Add status-specific styling
      switch(marker.status) {
        case 'active':
          customMarker.style.borderColor = '#28a745';
          break;
        case 'in progress':
          customMarker.style.borderColor = '#ffc107';
          break;
        case 'completed':
          customMarker.style.borderColor = '#17a2b8';
          break;
        default:
          customMarker.style.borderColor = '#6c757d';
      }

      // Mapbox marker create गर्नुहोस् र popup add गर्नुहोस्
      new window.mapboxgl.Marker(customMarker)
        .setLngLat([marker.lng, marker.lat]) // Geocoded coordinates बाट marker position सेट गर्नुहोस्
        .setPopup(new window.mapboxgl.Popup().setHTML(marker.info_window_html)) // _user_popup.html.erb बाट HTML popup add गर्नुहोस्
        .addTo(this.map);
    });
  }
}

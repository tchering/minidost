
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    console.log("Search controller connected");
  }

  search(event) {
    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      // Use standard form submit to ensure connection
      event.target.form.requestSubmit();
    }, 300);
  }
}

// Prevents rapid-fire form submissions while user is typing
// Waits 300ms after last keystroke before submitting
// clearTimeout cancels previous pending submission

//! How it works:
// User types "h" → starts 300ms timer
// User types "he" → cancels first timer, starts new 300ms timer
// User types "hel" → cancels second timer, starts new 300ms timer
// User stops typing → after 300ms, form submits with "hel"
//! Benefits:
// Automatic search without pressing Enter
// Reduces server load (prevents submission on every keystroke)
// Smoother user experience
// Works with Turbo frames for partial page updates
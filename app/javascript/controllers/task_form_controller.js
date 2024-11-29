// app/javascript/controllers/task_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["taskableFields", "activitySelect"];

  connect() {
    if (this.activitySelectTarget.value) {
      this.updateTaskableFields();
    }
  }

  updateTaskableFields() {
    const selectedActivity = this.activitySelectTarget.value; // Gets the *Task format directly
    if (selectedActivity) {
      fetch(`/tasks/load_taskable_fields?taskable_type=${selectedActivity}`)
        .then((response) => response.text())
        .then((html) => {
          this.taskableFieldsTarget.innerHTML = html;
        });
    } else {
      //When no activity is selected, clear fields
      this.taskableFieldsTarget.innerHTML = ""; // Clear fields if no selection
    }
  }
}

// Flow Example:
// User selects "Peintre" from dropdown
// Stimulus detects change, sends "PeintreTask" to controller
// Controller:
// Creates new Task with PeintreTask type
// Renders peintre-specific form fields
// Stimulus updates page with new form fields
// User fills out PeintreTask-specific fields
// Form submits with both Task and PeintreTask attributes
// This creates a dynamic form that changes based on the selected activity type.

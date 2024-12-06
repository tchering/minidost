// app/javascript/controllers/task_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["taskableFields", "activitySelect"]

  connect() {
    console.log("TaskForm controller connected")
    // Load fields if activity is pre-selected
    if (this.activitySelectTarget.value) {
      this.updateTaskableFields()
    }
  }

  updateTaskableFields() {
    const selectedActivity = this.activitySelectTarget.value
    if (!selectedActivity) {
      this.taskableFieldsTarget.innerHTML = ""
      return
    }

    fetch(`/tasks/load_taskable_fields?taskable_type=${selectedActivity}`)
      .then(response => {
        if (!response.ok) throw new Error("Network response was not ok")
        return response.text()
      })
      .then(html => {
        this.taskableFieldsTarget.innerHTML = html
      })
      .catch(error => {
        console.error("Error loading taskable fields:", error)
      })
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

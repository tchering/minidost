// Initialize dropdowns function
document.addEventListener('DOMContentLoaded', function() {
  // Initialize all dropdowns
  var dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]')
  dropdownElementList.forEach(function(dropdownToggleEl) {
    new bootstrap.Dropdown(dropdownToggleEl, {
      autoClose: 'outside'
    })
  })
})

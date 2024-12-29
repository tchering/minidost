document.addEventListener('turbo:load', function() {
  // Initialize Bootstrap dropdowns
  var dropdownElementList = [].slice.call(document.querySelectorAll('[data-bs-toggle="dropdown"]'))
  var dropdownList = dropdownElementList.map(function (dropdownToggleEl) {
    return new bootstrap.Dropdown(dropdownToggleEl, {
      autoClose: true
    })
  })
});

// Clean up dropdowns before caching
document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
    menu.classList.remove('show');
  });
});

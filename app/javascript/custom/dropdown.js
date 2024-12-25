document.addEventListener('turbo:load', function() {
  // Initialize all dropdowns
  const dropdowns = document.querySelectorAll('[data-bs-toggle="dropdown"]');
  dropdowns.forEach(dropdown => {
    dropdown.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      // Close all other dropdowns
      dropdowns.forEach(d => {
        if (d !== dropdown) {
          d.nextElementSibling.classList.remove('show');
          d.setAttribute('aria-expanded', 'false');
        }
      });

      const dropdownMenu = this.nextElementSibling;
      dropdownMenu.classList.toggle('show');
      this.setAttribute('aria-expanded', dropdownMenu.classList.contains('show'));
    });
  });

  // Close dropdown when clicking outside
  document.addEventListener('click', function(e) {
    if (!e.target.matches('[data-bs-toggle="dropdown"]')) {
      dropdowns.forEach(dropdown => {
        const menu = dropdown.nextElementSibling;
        if (menu && menu.classList.contains('show') && !menu.contains(e.target)) {
          menu.classList.remove('show');
          dropdown.setAttribute('aria-expanded', 'false');
        }
      });
    }
  });
});

// Handle Turbo navigation
document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
    menu.classList.remove('show');
  });
});

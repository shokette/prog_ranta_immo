// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
// import "map"
// import "chart"

$(document).ready(function () {
    console.log('Select2 is ready!');
    $('.select2').select2({
        language: 'fr',
        width: '100%',
        placeholder: 'Rechercher...',
        allowClear: true
    });
});
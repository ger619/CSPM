// Configure your import map in config/import.rb. Read more: https://github.com/rails/importmap-rails

import '@hotwired/turbo-rails';
import 'controllers';
import 'trix';
import '@rails/actiontext';
//= require rails-ujs
//= require turbolinks
//= require_tree .


document.addEventListener('turbo:load', () => {
  let addDocumentButton = document.querySelector('#add-document');
  let documentsContainer = document.querySelector('#documents-container');

  if (addDocumentButton) {
    addDocumentButton.addEventListener('click', function (e) {
      e.preventDefault();
      let newDocumentField = document.querySelector('.document-field').cloneNode(true);
      newDocumentField.querySelector('input').value = ''; // Clear the input fields
      documentsContainer.appendChild(newDocumentField);
    });
  }
});

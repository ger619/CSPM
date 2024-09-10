// Configure your import map in config/import.rb. Read more: https://github.com/rails/importmap-rails

import '@hotwired/turbo-rails';
import 'controllers';
import 'trix';
import '@rails/actiontext';
//= require rails-ujs
//= require turbolinks
//= require_tree .


document.addEventListener('DOMContentLoaded', () => {
  const richTextArea = document.querySelector('[data-rich-text-area]');
  const maxLength = 799; // Set your desired character limit

  if (richTextArea) {
    const updateCharacterCount = () => {
      let text = richTextArea.innerText;
      if (text.length > maxLength) {
        text = text.substring(0, maxLength);
        richTextArea.innerText = text;
      }
      document.getElementById('character_count').innerText = `${text.length}/${maxLength}`;
    };

    richTextArea.addEventListener('input', updateCharacterCount);
  }
});


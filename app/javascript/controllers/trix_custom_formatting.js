document.addEventListener('trix-initialize', (event) => {
  const toolbar = event.target.toolbarElement.querySelector('.trix-button-group--text-tools');

  const buttons = [
    { name: 'text-red', label: '🔴' },
    { name: 'text-blue', label: '🔵' },
    { name: 'text-green', label: '🟢' },
    { name: 'text-yellow', label: '🟡' },
    { name: 'text-underline', label: 'U̲' },
    { name: 'text-highlight', label: '🖍️' },
    { name: 'text-large', label: '🔠' },
    { name: 'text-small', label: '🔡' },
  ];

  buttons.forEach(({ name, label }) => {
    toolbar.insertAdjacentHTML('beforeend', `
      <button type="button" class="trix-button" data-trix-attribute="${name}" title="${name}">${label}</button>
    `);
  });
});

document.addEventListener('trix-initialize', () => {
  const exclusiveColors = ['text-red', 'text-blue', 'text-green', 'text-yellow'];

  exclusiveColors.forEach((color) => {
    // eslint-disable-next-line no-undef
    Trix.config.textAttributes[color] = {
      style: { color: color.split('-')[1] },
      inheritable: true,
      parser(element) {
        return element.style.color === color.split('-')[1];
      },
      remover(element) {
        exclusiveColors.forEach((c) => element.removeAttribute(c));
      },
    };
  });

  // eslint-disable-next-line no-undef
  Trix.config.textAttributes['text-underline'] = {
    style: { textDecoration: 'underline' },
    inheritable: true,
  };

  // eslint-disable-next-line no-undef
  Trix.config.textAttributes['text-highlight'] = {
    style: { backgroundColor: 'yellow' },
    inheritable: true,
  };

  // eslint-disable-next-line no-undef
  Trix.config.textAttributes['text-large'] = {
    style: { fontSize: '1.5em' },
    inheritable: true,
  };

  // eslint-disable-next-line no-undef
  Trix.config.textAttributes['text-small'] = {
    style: { fontSize: '0.75em' },
    inheritable: true,
  };
});

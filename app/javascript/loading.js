// app/javascript/loading.js
document.addEventListener('turbo:load', () => {
  const loadingLogo = document.createElement('img');
  loadingLogo.src = '../assets/logo.png';
  loadingLogo.id = 'loading-logo';

  const loadingBackground = document.createElement('div');
  loadingBackground.id = 'loading-background';

  document.body.appendChild(loadingBackground);
  document.body.appendChild(loadingLogo);

  setTimeout(() => {
    loadingLogo.remove();
    loadingBackground.remove();
  }, 3000);
});
// app/javascript/loading.js
document.addEventListener('turbo:load', () => {
  const excludedPaths = ['/users/sign_in', '/users/sign_up', '/users/password/new', '/users/password/edit', '/users/confirmation/new', '/users/confirmation', '/users/invitation/accept', '/users/invitation/new', '/users/invitation/edit', '/users/invitation/remove', '/users/invitation/resend', '/users/invitation/confirmation', '/users/unlock/new', '/users/unlock', '/users/sign_out'];
  // eslint-disable-next-line max-len
  if (excludedPaths.includes(window.location.pathname) || performance.navigation.type === performance.navigation.TYPE_RELOAD) {
    return;
  }

  const loadingLogo = document.createElement('img');
  loadingLogo.src = '/assets/logo.png';
  loadingLogo.id = 'loading-logo';

  const loadingBackground = document.createElement('div');
  loadingBackground.id = 'loading-background';

  document.body.appendChild(loadingBackground);
  document.body.appendChild(loadingLogo);

  setTimeout(() => {
    loadingLogo.remove();
    loadingBackground.remove();
  }, 5000);
});
// app/javascript/loading.js
document.addEventListener('turbo:load', () => {
  const excludedPaths = ['/users/sign_in', '/users/sign_up', '/users/password/new', '/users/password/edit', '/users/confirmation/new', '/users/confirmation', '/users/invitation/accept', '/users/invitation/new', '/users/invitation/edit', '/users/invitation/remove', '/users/invitation/resend', '/users/invitation/confirmation', '/users/unlock/new', '/users/unlock', '/users/sign_out'];
  if (excludedPaths.includes(window.location.pathname)) {
    return;
  }

  const loadingLogo = document.createElement('img');
  loadingLogo.src = '<%= asset_path("logo.png") %>';
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
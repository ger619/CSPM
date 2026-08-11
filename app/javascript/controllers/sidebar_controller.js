import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['sidebar', 'overlay', 'reports', 'reportChevron'];

  connect() {
    this.handleResize = this.handleResize.bind(this);
    this.restoreState();
    window.addEventListener('resize', this.handleResize);
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize);
  }

  // ============================================================
  // MOBILE
  // ============================================================

  open() {
    this.sidebarTarget.classList.remove('-translate-x-full');
    this.overlayTarget.classList.remove('hidden');
    document.body.classList.add('overflow-hidden');
  }

  close() {
    this.sidebarTarget.classList.add('-translate-x-full');
    this.overlayTarget.classList.add('hidden');
    document.body.classList.remove('overflow-hidden');
  }

  // ============================================================
  // DESKTOP COLLAPSE
  // ============================================================

  toggle() {
    const collapsed = localStorage.getItem('greatercare.sidebar.collapsed') === 'true';
    const newState = !collapsed;

    localStorage.setItem('greatercare.sidebar.collapsed', String(newState));
    this.applyDesktopState(newState);
  }

  applyDesktopState(collapsed) {
    const spacer = document.getElementById('sidebar');

    if (window.innerWidth < 1024) {
      if (spacer) {
        spacer.classList.remove('w-[280px]', 'w-[80px]');
        spacer.classList.add('w-0');
      }
      return;
    }

    const expandedWidth = 'w-[280px]';
    const collapsedWidth = 'w-[80px]';
    const nextWidth = collapsed ? collapsedWidth : expandedWidth;
    const prevWidth = collapsed ? expandedWidth : collapsedWidth;

    this.sidebarTarget.classList.remove(prevWidth);
    this.sidebarTarget.classList.add(nextWidth);

    if (spacer) {
      spacer.classList.remove(prevWidth, 'w-0');
      spacer.classList.add(nextWidth);
    }
  }

  // ============================================================
  // REPORTS
  // ============================================================

  toggleReports() {
    this.reportsTarget.classList.toggle('hidden');
    this.reportChevronTarget.classList.toggle('rotate-180');
  }

  // ============================================================
  // RESTORE STATE
  // ============================================================

  restoreState() {
    const collapsed = localStorage.getItem('greatercare.sidebar.collapsed') === 'true';
    this.applyDesktopState(collapsed);
  }

  // ============================================================
  // RESPONSIVE
  // ============================================================

  handleResize() {
    this.close();

    if (window.innerWidth >= 1024) {
      this.restoreState();
    } else {
      this.applyDesktopState(false);
    }
  }
}
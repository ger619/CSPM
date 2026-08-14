import { Controller } from '@hotwired/stimulus';

// Mounted on #sidebar in the app layout (NOT inside the partial), so
// `this.element` is the actual flex spacer that reserves layout space
// next to #mainContent. Handles: mobile slide-in/out, desktop icon-rail
// collapse (persisted, resize-aware), and the "Data Center" accordion.
export default class extends Controller {
  static targets = ['sidebar', 'overlay', 'reports', 'reportChevron', 'collapseIcon']

  connect() {
    this.handleResize = this.handleResize.bind(this);
    this.handleKeydown = this.handleKeydown.bind(this);
    window.addEventListener('resize', this.handleResize);
    document.addEventListener('keydown', this.handleKeydown);
    this.restoreState();
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize);
    document.removeEventListener('keydown', this.handleKeydown);
  }

  // ============================================================
  // MOBILE — the <aside> slides in as an overlay drawer
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

  handleKeydown(event) {
    if (event.key === 'Escape') this.close();
  }

  // ============================================================
  // DESKTOP COLLAPSE
  // ============================================================

  toggle() {
    const collapsed = localStorage.getItem('greatercare.sidebar.collapsed') === 'true';
    const next = !collapsed;
    localStorage.setItem('greatercare.sidebar.collapsed', String(next));
    this.applyDesktopState(next);
  }

  // Single source of truth for collapse visuals:
  // - sets data-state on the <aside>, which every `group-data-[state=collapsed]/side:`
  //   utility in the partial keys off (labels, badges, icon centering, logo swap...)
  // - resizes this.element (the #sidebar spacer div) so #mainContent reflows
  // - mirrors the width into --sidebar-width, for anything that prefers a
  //   CSS var over relying on the flex spacer
  applyDesktopState(collapsed) {
    this.sidebarTarget.dataset.state = collapsed ? 'collapsed' : 'expanded';

    if (this.hasCollapseIconTarget) {
      this.collapseIconTarget.classList.toggle('rotate-180', collapsed);
    }

    if (window.innerWidth < 1024) {
      // Mobile: the sidebar overlays content — never reserve horizontal space.
      this.element.style.width = '0px';
      document.documentElement.style.setProperty('--sidebar-width', '0px');
      return;
    }

    const width = collapsed ? '84px' : '280px';
    this.element.style.width = width;
    document.documentElement.style.setProperty('--sidebar-width', width);

    if (collapsed) this.closeReports();
  }

  // ============================================================
  // REPORTS ACCORDION
  // ============================================================

  toggleReports() {
    // Auto-expand the rail first so the panel has room to render legibly.
    const collapsed = localStorage.getItem('greatercare.sidebar.collapsed') === 'true';
    if (collapsed) {
      localStorage.setItem('greatercare.sidebar.collapsed', 'false');
      this.applyDesktopState(false);
    }
    this.reportsTarget.classList.toggle('hidden');
    if (this.hasReportChevronTarget) {
      this.reportChevronTarget.classList.toggle('rotate-180');
    }
  }

  closeReports() {
    this.reportsTarget.classList.add('hidden');
    if (this.hasReportChevronTarget) {
      this.reportChevronTarget.classList.remove('rotate-180');
    }
  }

  // ============================================================
  // RESTORE + RESPONSIVE
  // ============================================================

  restoreState() {
    const collapsed = localStorage.getItem('greatercare.sidebar.collapsed') === 'true';
    this.applyDesktopState(collapsed);
  }

  handleResize() {
    this.close(); // always reset the mobile drawer on breakpoint change
    if (window.innerWidth >= 1024) {
      this.restoreState();
    } else {
      this.element.style.width = '0px';
      document.documentElement.style.setProperty('--sidebar-width', '0px');
    }
  }
}
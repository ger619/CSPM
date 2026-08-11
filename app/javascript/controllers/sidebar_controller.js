import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sidebar",
    "overlay",
    "reports",
    "reportChevron"
  ]

  connect() {
    this.restoreState()

    this.handleResize = this.handleResize.bind(this)

    window.addEventListener(
      "resize",
      this.handleResize
    )
  }

  disconnect() {
    window.removeEventListener(
      "resize",
      this.handleResize
    )
  }


  // ============================================================
  // MOBILE
  // ============================================================

  open() {
    this.sidebarTarget.classList.remove(
      "-translate-x-full"
    )

    this.overlayTarget.classList.remove(
      "hidden"
    )

    document.body.classList.add(
      "overflow-hidden"
    )
  }


  close() {
    this.sidebarTarget.classList.add(
      "-translate-x-full"
    )

    this.overlayTarget.classList.add(
      "hidden"
    )

    document.body.classList.remove(
      "overflow-hidden"
    )
  }


  // ============================================================
  // DESKTOP COLLAPSE
  // ============================================================

  toggle() {
    const collapsed =
      localStorage.getItem(
        "greatercare.sidebar.collapsed"
      ) === "true"

    const newState = !collapsed

    localStorage.setItem(
      "greatercare.sidebar.collapsed",
      newState
    )

    this.applyDesktopState(newState)
  }


  applyDesktopState(collapsed) {
    if (window.innerWidth < 1024) {
      return
    }

    if (collapsed) {
      this.sidebarTarget.classList.remove(
        "w-[280px]"
      )

      this.sidebarTarget.classList.add(
        "w-[80px]"
      )
    } else {
      this.sidebarTarget.classList.remove(
        "w-[80px]"
      )

      this.sidebarTarget.classList.add(
        "w-[280px]"
      )
    }
  }


  // ============================================================
  // REPORTS
  // ============================================================

  toggleReports() {
    this.reportsTarget.classList.toggle(
      "hidden"
    )

    this.reportChevronTarget.classList.toggle(
      "rotate-180"
    )
  }


  // ============================================================
  // RESTORE STATE
  // ============================================================

  restoreState() {
    const collapsed =
      localStorage.getItem(
        "greatercare.sidebar.collapsed"
      ) === "true"

    this.applyDesktopState(
      collapsed
    )
  }


  // ============================================================
  // RESPONSIVE
  // ============================================================

  handleResize() {
    if (window.innerWidth >= 1024) {
      this.close()
      this.restoreState()
    }
  }

  applyDesktopState(collapsed) {
    const spacer = document.getElementById("sidebar")

    if (window.innerWidth < 1024) {
      if (spacer) {
        spacer.classList.remove("w-[280px]", "w-[80px]")
        spacer.classList.add("w-0")
      }
      return
    }

    if (collapsed) {
      this.sidebarTarget.classList.remove("w-[280px]")
      this.sidebarTarget.classList.add("w-[80px]")
      if (spacer) {
        spacer.classList.remove("w-[280px]", "w-0")
        spacer.classList.add("w-[80px]")
      }
    } else {
      this.sidebarTarget.classList.remove("w-[80px]")
      this.sidebarTarget.classList.add("w-[280px]")
      if (spacer) {
        spacer.classList.remove("w-[80px]", "w-0")
        spacer.classList.add("w-[280px]")
      }
    }
  }
}
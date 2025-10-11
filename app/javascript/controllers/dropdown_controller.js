import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle"]
  static values = { filterName: String }

  connect() {
    this.updateActiveState()
  }

  toggle(event) {
    event.stopPropagation()
    const isExpanded = this.toggleTarget.getAttribute("aria-expanded") === "true"
    this.toggleTarget.setAttribute("aria-expanded", !isExpanded)
    this.menuTarget.classList.toggle("hidden")
  }

  maybeClose(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.toggleTarget.setAttribute("aria-expanded", false)
  }

  updateActiveState() {
    const searchParams = new URLSearchParams(window.location.search)

    // Check if any value exists for this filter (even just one is enough)
    const hasActive = searchParams.has(this.filterNameValue)

    this.toggleTarget.classList.toggle("active", hasActive)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.showPanel(0)
  }

  select(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showPanel(index)
  }

  showPanel(index) {
    this.tabTargets.forEach((el, i) => {
      if (i === index) {
        el.classList.add("border-primary", "text-blue-600")
        el.classList.remove("text-gray-500", "border-transparent")
      } else {
        el.classList.remove("border-primary", "text-blue-600")
        el.classList.add("text-gray-500", "border-transparent")
      }
    })

    this.panelTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== index)
    })
  }
}

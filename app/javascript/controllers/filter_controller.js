// app/javascript/controllers/filter_controller.js
import { Controller } from "@hotwired/stimulus"
import { turboFetch } from "utils/turbo_fetch"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    filterName: String,
  }

  submit() {
    const url = new URL(window.location.href)

    this.inputTargets.forEach(input => {
      if (input.name === this.filterNameValue) {
        url.searchParams.delete(input.name)
      }
    })

    this.inputTargets
      .filter(input => input.checked)
      .forEach(input => {
        url.searchParams.append(input.name, input.value)
      })

      window.history.pushState({}, "", url)

      turboFetch(url.toString());
  }

  clearAll() {
    this.inputTargets.forEach(input => {
      input.checked = false
    })

    const url = new URL(window.location.href)
    url.searchParams.delete(this.filterNameValue)

    window.history.pushState({}, "", url)

    turboFetch(url.toString());
  }
}

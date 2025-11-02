// app/javascript/controllers/filter_controller.js
import { Controller } from "@hotwired/stimulus"
import { turboFetch } from "utils/turbo_fetch"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    filterName: String,
    advance: { type: Boolean, default: true }
  }

  submit() {
    const url = this.url();

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
      if (this.advanceValue) {
        window.history.pushState({}, "", url)
        turboFetch(url.toString());
      } else {
        fetch(url.toString(), { headers: { "Accept": "text/vnd.turbo-stream.html" } })
          .then(response => response.text())
          .then(html => Turbo.renderStreamMessage(html));
      }
  }

  clearAll() {
    this.inputTargets.forEach(input => {
      input.checked = false
    })

    const url = this.url()
    url.searchParams.delete(this.filterNameValue)

    if (this.advanceValue) {
      window.history.pushState({}, "", url)
      turboFetch(url.toString());
    } else {
      fetch(url.toString(), { headers: { "Accept": "text/vnd.turbo-stream.html" } })
        .then(response => response.text())
        .then(html => Turbo.renderStreamMessage(html));
    }
  }

  url() {
    if (this.advanceValue) {
      return new URL(window.location.href)
    } else {
      return new URL(document.querySelector("turbo-frame#modal").src)
    }
  }

  turboFrameElement() {
    return this.element.closest('turbo-frame')
  }
}

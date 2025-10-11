import { Controller } from "@hotwired/stimulus"
import { useDebounce } from 'stimulus-use'

export default class extends Controller {
  static targets = ["input"]
  static values = {
    advance: { type: Boolean, default: true },
  }
  static debounces = [{
    name: "handleKeyup",
    wait: 800
  }]

  connect() {
    this.handleKeyup = this.handleKeyup.bind(this)
    this.clearForm = this.clearForm.bind(this)
  
    useDebounce(this)
  
    this.inputTarget.focus()
    this.moveCursorToEnd()
    this.element.addEventListener("keyup", this.handleKeyup)
    this.inputTarget.addEventListener("change", this.clearForm)
  }

  handleKeyup(event) {
    event.preventDefault();
    this.submitSearch(event.target.value);
  }

  moveCursorToEnd() {
    const inputLength = this.inputTarget.value.length;
    this.inputTarget.setSelectionRange(inputLength, inputLength);
  }

  clearForm() {
    if (this.inputTarget.value === "") {
      this.submitSearch();
    }
  }

  submitSearch(value) {
    const url = this.searchUrl();
    url.searchParams.set(`q[${this.inputTarget.name}]`, value || "")
    url.searchParams.delete("page")

    if (this.advanceValue) {
      window.history.pushState({}, "", url)
    }

    fetch(url.toString(), {
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

  searchUrl() {
    if (!this.advanceValue) {
      return new URL(document.querySelector("turbo-frame#modal").src)
    } else {
      return new URL(window.location.href)
    }
  }
}

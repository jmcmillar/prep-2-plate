import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  static values = { url: String }

  connect() {
    document.addEventListener("click", (event) => {
      if (!this.element.contains(event.target)) {
        this.sourceTarget.classList.add("hidden")
      }
    });
  }

  setFrameSource() {
    this.sourceTarget.classList.remove("hidden")
    this.sourceTarget.src = this.urlValue
  }

  closeFrameSource() {
    this.sourceTarget.classList.add("hidden")
  }

  toggleFrameSource() {
    if (this.sourceTarget.classList.contains("hidden")) {
      this.sourceTarget.classList.remove("hidden")
      this.sourceTarget.src = this.urlValue
    } else {
      this.sourceTarget.classList.add("hidden")
    }
  }
}


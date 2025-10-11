import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["openButton", "closeButton", "navbar"]
  static values = { open: Boolean }

  toggleOpen() {
    this.openValue = !this.openValue
    return this.setMenuOpen();
  }

  setMenuOpen() {
    if (!this.hasNavbarTarget) {
      return;
    }
    this.navbarTarget.classList.toggle("hidden");
    this.closeButtonTarget.classList.toggle("!hidden");
    return this.openButtonTarget.classList.toggle("!hidden");
  }
}

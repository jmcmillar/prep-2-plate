import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  connect() {
    setTimeout(() => {
      this.closeAlert();
    }, 3000);
  }

  closeAlert() {
    return this.element.remove();
  }
}

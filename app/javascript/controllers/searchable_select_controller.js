import Choices from "choices.js"
// import * as Choices from "choices.js"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    new Choices(this.element)
  }
}

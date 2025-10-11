import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "input"]

  toggle(event) {
    const checkbox = event.target
    const name = this.inputTarget.value.trim()
    const listId = document.querySelector("#shopping_list_id")?.value

    if (!checkbox.checked || !listId || name === "") return

    fetch(`/shopping_lists/${listId}/items`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ name: name })
    })
    .then(resp => {
      if (!resp.ok) throw new Error("Failed to save")
      return resp.json()
    })
    .then(() => {
      checkbox.disabled = true
      this.inputTarget.disabled = true
      this.labelTarget.classList.add("line-through", "text-gray-400")
    })
    .catch(err => {
      console.error(err)
      checkbox.checked = false
    })
  }

  edit() {
    this.labelTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
  }
}

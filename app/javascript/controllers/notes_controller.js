import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "input", "display"]

  connect() {
    console.log("Notes controller connected")
  }

  edit(event) {
    const index = event.currentTarget.dataset.notesDay
    const wrapper = this.wrapperTargets.find(w => w.dataset.notesTarget === "wrapper" && w.querySelector(`[name='notes[${index}]']`))

    if (!wrapper) return

    const input = wrapper.querySelector("textarea")
    const display = wrapper.querySelector("[data-notes-target='display']")

    input.classList.remove("hidden")
    display.classList.add("hidden")
    input.focus()

    input.addEventListener("blur", () => this.save(input, display))
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        input.blur()
      }
    })
  }

  async save(input, display) {
    const dayIndex = input.name.match(/\[(\d+)\]/)[1]
    const noteValue = input.value.trim()

    // Optimistic UI update
    display.textContent = noteValue || "No planning notes yet..."
    input.classList.add("hidden")
    display.classList.remove("hidden")

    // Send PATCH or POST request to persist the note
    await fetch("/meal_planners/notes", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        day: parseInt(dayIndex),
        note: noteValue
      })
    })
  }
}

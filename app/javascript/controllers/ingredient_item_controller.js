import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "input", "newItemInput"]
  static values = {
    removeDelay: { type: Number, default: 3000 } // 3 seconds default
  }

  toggle(event) {
    const checkbox = event.target
    const name = this.inputTarget.value.trim()

    if (!checkbox.checked || name === "") return

    this.addToShoppingList(name)
      .then(() => {
        checkbox.disabled = true
        this.inputTarget.disabled = true
        this.labelTarget.classList.add("line-through", "text-gray-400")
        
        this.showFlashNotice(`"${name}" added to shopping list`)
        
        setTimeout(() => {
          this.removeItem()
        }, this.removeDelayValue)
      })
      .catch(err => {
        console.error(err)
        checkbox.checked = false
        this.showFlashNotice("Failed to add item to shopping list", "error")
      })
  }

  addItem(event) {
    event.preventDefault()
    
    if (!this.hasNewItemInputTarget) return
    
    const itemName = this.newItemInputTarget.value.trim()
    if (!itemName) return

    this.addToShoppingList(itemName)
      .then(() => {
        this.showFlashNotice(`"${itemName}" added to shopping list`)
        this.newItemInputTarget.value = ""
        this.newItemInputTarget.focus()
      })
      .catch(err => {
        console.error(err)
        this.showFlashNotice("Failed to add item to shopping list", "error")
      })
  }

  addToShoppingList(itemName) {
    const listId = document.querySelector("#shopping_list_id")?.value

    if (!listId) {
      return Promise.reject(new Error("No shopping list selected"))
    }

    return fetch(`/shopping_lists/${listId}/items`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ name: itemName })
    })
    .then(resp => {
      if (!resp.ok) throw new Error("Failed to save")
      return resp.json()
    })
  }

  edit(event) {
    event.preventDefault()
    this.labelTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  saveEdit(event) {
    if (event.type === "keydown" && event.key !== "Enter") return
    
    event.preventDefault()
    const newValue = this.inputTarget.value.trim()
    
    if (newValue) {
      this.labelTarget.textContent = newValue
    } else {
      this.inputTarget.value = this.labelTarget.textContent
    }
    
    this.inputTarget.classList.add("hidden")
    this.labelTarget.classList.remove("hidden")
  }

  cancelEdit(event) {
    event.preventDefault()
    this.inputTarget.value = this.labelTarget.textContent
    this.inputTarget.classList.add("hidden")
    this.labelTarget.classList.remove("hidden")
  }

  remove(event) {
    event.preventDefault()
    const name = this.labelTarget.textContent.trim()
    
    if (confirm(`Remove "${name}" from the list?`)) {
      this.showFlashNotice(`"${name}" removed`)
      this.removeItem()
    }
  }

  showFlashNotice(message, type = "success") {
    // Create flash element
    const flash = document.createElement("div")
    const bgColor = type === "success" ? "bg-primary" : "bg-secondary"
    
    flash.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 9999;
      padding: 12px 16px;
      border-radius: 8px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      color: white;
      font-weight: 500;
      opacity: 0;
      transition: opacity 0.3s ease-in-out;
    `
    
    flash.className = bgColor
    flash.textContent = message
    
    document.body.appendChild(flash)
    
    // Trigger animation after append
    requestAnimationFrame(() => {
      flash.style.opacity = "1"
    })
    
    // Fade out and remove after 3 seconds
    setTimeout(() => {
      flash.style.opacity = "0"
      setTimeout(() => {
        flash.remove()
      }, 300)
    }, 3000)
  }

  removeItem() {
    // Add fade out animation
    this.element.style.transition = "opacity 0.3s ease-out"
    this.element.style.opacity = "0"
    
    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

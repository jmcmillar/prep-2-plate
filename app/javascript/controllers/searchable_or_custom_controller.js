import Choices from "choices.js"
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="searchable-or-custom"
export default class extends Controller {
  static targets = ["select", "customInput", "toggleButton"]
  static values = {
    useCustom: { type: Boolean, default: false }
  }

  connect() {
    this.updateVisibility()
    
    // Only initialize Choices.js if using select mode
    if (!this.useCustomValue) {
      this.initializeChoices()
    }
    
    // Add form submit handler to clean up values
    this.element.closest('form')?.addEventListener('submit', this.handleSubmit.bind(this))
  }

  disconnect() {
    if (this.choices) {
      this.choices.destroy()
      this.choices = null
    }
  }

  toggle(event) {
    event.preventDefault()
    this.useCustomValue = !this.useCustomValue
    this.updateVisibility()
  }

  handleSubmit(event) {
    // Clear the value of whichever field is hidden/disabled
    if (this.useCustomValue) {
      // Using custom input, clear the select
      this.selectTarget.value = ''
    } else {
      // Using select, clear the custom input
      this.customInputTarget.value = ''
    }
  }

  updateVisibility() {
    if (this.useCustomValue) {
      // Show custom input, hide select
      this.selectTarget.classList.add('hidden')
      this.customInputTarget.classList.remove('hidden')
      this.toggleButtonTarget.textContent = 'Search Existing'
      
      // Destroy Choices.js if it exists
      if (this.choices) {
        this.choices.destroy()
        this.choices = null
      }
      
      // Clear the select value
      this.selectTarget.value = ''
      this.selectTarget.disabled = true
      this.customInputTarget.disabled = false
    } else {
      // Show select, hide custom input
      this.selectTarget.classList.remove('hidden')
      this.customInputTarget.classList.add('hidden')
      this.toggleButtonTarget.textContent = 'Add New'
      
      // Initialize Choices.js
      this.initializeChoices()
      
      // Clear the custom input
      this.customInputTarget.value = ''
      this.customInputTarget.disabled = true
      this.selectTarget.disabled = false
    }
  }

  initializeChoices() {
    if (!this.choices && !this.selectTarget.classList.contains('hidden')) {
      this.choices = new Choices(this.selectTarget, {
        searchEnabled: true,
        removeItemButton: false,
        allowHTML: false,
        searchResultLimit: 50,
        shouldSort: true,
        placeholder: true,
        placeholderValue: 'Search for an ingredient...'
      })
    }
  }
}

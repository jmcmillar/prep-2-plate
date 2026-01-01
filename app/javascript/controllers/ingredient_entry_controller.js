import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ingredient-entry"
export default class extends Controller {
  static targets = [
    "packagingContainer",
    "preparationContainer",
    "packagingField",
    "preparationField",
    "ingredientInfo",
    "selectField",
    "notesContainer"
  ]

  static values = {
    mode: { type: String, default: "select" } // "select" or "custom"
  }

  connect() {
    this.updateVisibility()

    // Listen for mode changes from searchable-or-custom controller
    this.element.addEventListener(
      'searchable-or-custom:modeChanged',
      this.handleModeChange.bind(this)
    )

    // If there's already a selected ingredient on page load, show its info
    if (this.hasSelectFieldTarget && this.selectFieldTarget.value && this.modeValue === 'select') {
      this.ingredientSelected({ target: this.selectFieldTarget })
    }
  }

  disconnect() {
    this.element.removeEventListener(
      'searchable-or-custom:modeChanged',
      this.handleModeChange.bind(this)
    )
  }

  handleModeChange(event) {
    this.modeValue = event.detail.mode
    this.updateVisibility()
  }

  ingredientSelected(event) {
    if (this.modeValue !== 'select') return

    const select = event.target
    const selectedOption = select.options[select.selectedIndex]

    if (!selectedOption || !selectedOption.value) {
      this.clearIngredientInfo()
      return
    }

    // Try to get data from the option element's dataset
    const packagingForm = selectedOption.dataset.packagingForm || selectedOption.getAttribute('data-packaging-form')
    const preparationStyle = selectedOption.dataset.preparationStyle || selectedOption.getAttribute('data-preparation-style')

    this.displayIngredientInfo(packagingForm, preparationStyle)
  }

  updateVisibility() {
    if (this.modeValue === 'custom') {
      // Creating new ingredient - show packaging/prep fields
      this.showPackagingPreparation()
      this.hideIngredientInfo()
      this.expandNotesField()
    } else {
      // Selecting existing - hide packaging/prep fields
      this.hidePackagingPreparation()
      this.clearPackagingPreparation()
      this.collapseNotesField()

      // Show info if ingredient already selected
      if (this.hasSelectFieldTarget && this.selectFieldTarget.value) {
        this.ingredientSelected({ target: this.selectFieldTarget })
      }
    }
  }

  showPackagingPreparation() {
    if (this.hasPackagingContainerTarget) {
      this.packagingContainerTarget.classList.remove('hidden')
    }
    if (this.hasPreparationContainerTarget) {
      this.preparationContainerTarget.classList.remove('hidden')
    }
  }

  hidePackagingPreparation() {
    if (this.hasPackagingContainerTarget) {
      this.packagingContainerTarget.classList.add('hidden')
    }
    if (this.hasPreparationContainerTarget) {
      this.preparationContainerTarget.classList.add('hidden')
    }
  }

  clearPackagingPreparation() {
    if (this.hasPackagingFieldTarget) {
      this.packagingFieldTarget.value = ''
    }
    if (this.hasPreparationFieldTarget) {
      this.preparationFieldTarget.value = ''
    }
  }

  displayIngredientInfo(packagingForm, preparationStyle) {
    if (!this.hasIngredientInfoTarget) return

    const parts = []

    if (packagingForm && packagingForm !== '') {
      parts.push(this.humanize(packagingForm))
    }

    if (preparationStyle && preparationStyle !== '') {
      parts.push(this.humanize(preparationStyle))
    }

    if (parts.length > 0) {
      this.ingredientInfoTarget.innerHTML = `
        <span class="inline-flex items-center gap-2">
          <i class="fas fa-info-circle text-gray-400"></i>
          <span>${parts.join(', ')}</span>
        </span>
      `
      this.ingredientInfoTarget.classList.remove('hidden')
    } else {
      this.clearIngredientInfo()
    }
  }

  clearIngredientInfo() {
    if (this.hasIngredientInfoTarget) {
      this.ingredientInfoTarget.innerHTML = ''
      this.ingredientInfoTarget.classList.add('hidden')
    }
  }

  hideIngredientInfo() {
    this.clearIngredientInfo()
  }

  expandNotesField() {
    // When showing packaging/prep, notes should use remaining space
    if (this.hasNotesContainerTarget) {
      this.notesContainerTarget.classList.remove('lg:col-span-12')
      this.notesContainerTarget.classList.add('lg:col-span-6')
    }
  }

  collapseNotesField() {
    // When hiding packaging/prep, notes can span full width
    if (this.hasNotesContainerTarget) {
      this.notesContainerTarget.classList.remove('lg:col-span-6')
      this.notesContainerTarget.classList.add('lg:col-span-12')
    }
  }

  humanize(str) {
    if (!str) return ''
    return str
      .split('_')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ')
  }
}

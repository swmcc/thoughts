import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tagList", "suggestions"]

  connect() {
    this.existingTags = []
    this.loadExistingTags()
  }

  async loadExistingTags() {
    try {
      const response = await fetch("/api/tags")
      if (response.ok) {
        const data = await response.json()
        this.existingTags = data.tags || []
      }
    } catch (error) {
      console.error("Failed to load existing tags:", error)
    }
  }

  handleKeydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.addTag()
    } else if (event.key === "Escape") {
      this.hideSuggestions()
    }
  }

  addTag() {
    const tagValue = this.inputTarget.value.trim().toLowerCase()
    if (!tagValue) return

    // Check if tag already exists
    const existingTags = this.getCurrentTags()
    if (existingTags.includes(tagValue)) {
      this.inputTarget.value = ""
      this.hideSuggestions()
      return
    }

    // Create tag element
    const tagElement = this.createTagElement(tagValue)
    this.tagListTarget.appendChild(tagElement)

    // Clear input
    this.inputTarget.value = ""
    this.hideSuggestions()
  }

  createTagElement(tagValue) {
    const span = document.createElement("span")
    span.className = "inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800"

    span.innerHTML = `
      ${this.escapeHtml(tagValue)}
      <button type="button" data-action="tag-input#removeTag" data-tag="${this.escapeHtml(tagValue)}" class="hover:text-blue-600">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </button>
      <input type="hidden" name="thought[tags][]" value="${this.escapeHtml(tagValue)}">
    `

    return span
  }

  removeTag(event) {
    const button = event.currentTarget
    const tagElement = button.closest("span")
    if (tagElement) {
      tagElement.remove()
    }
  }

  showSuggestions() {
    const inputValue = this.inputTarget.value.trim().toLowerCase()
    if (!inputValue) {
      this.hideSuggestions()
      return
    }

    const currentTags = this.getCurrentTags()
    const matchingTags = this.existingTags.filter(tag =>
      tag.toLowerCase().includes(inputValue) && !currentTags.includes(tag.toLowerCase())
    ).slice(0, 5)

    if (matchingTags.length === 0) {
      this.hideSuggestions()
      return
    }

    this.suggestionsTarget.innerHTML = matchingTags.map(tag => `
      <button type="button"
              class="w-full px-4 py-2 text-left text-sm hover:bg-blue-50 focus:bg-blue-50 focus:outline-none"
              data-action="click->tag-input#selectSuggestion"
              data-tag="${this.escapeHtml(tag)}">
        ${this.escapeHtml(tag)}
      </button>
    `).join("")

    this.suggestionsTarget.classList.remove("hidden")
  }

  selectSuggestion(event) {
    const tag = event.currentTarget.dataset.tag
    this.inputTarget.value = tag
    this.addTag()
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
  }

  getCurrentTags() {
    const hiddenInputs = this.tagListTarget.querySelectorAll('input[name="thought[tags][]"]')
    return Array.from(hiddenInputs).map(input => input.value.toLowerCase())
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}

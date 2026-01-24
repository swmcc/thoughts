import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.maxLength = parseInt(this.countTarget.dataset.max) || 140
    this.count()
  }

  count() {
    const currentLength = this.inputTarget.value.length
    const remaining = this.maxLength - currentLength

    this.countTarget.textContent = remaining

    if (remaining < 0) {
      this.countTarget.classList.remove("text-gray-500", "text-yellow-600")
      this.countTarget.classList.add("text-red-600", "font-bold")
    } else if (remaining <= 20) {
      this.countTarget.classList.remove("text-gray-500", "text-red-600", "font-bold")
      this.countTarget.classList.add("text-yellow-600")
    } else {
      this.countTarget.classList.remove("text-yellow-600", "text-red-600", "font-bold")
      this.countTarget.classList.add("text-gray-500")
    }
  }
}

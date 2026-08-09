import { Controller } from "@hotwired/stimulus"

// Removes a link preview's image block when the remote og:image fails to
// load — dead hotlinks otherwise render as broken picture boxes. The card
// gracefully collapses to its text-only variant.
export default class extends Controller {
  static targets = [ "image" ]

  imageTargetConnected(img) {
    if (img.complete && img.naturalWidth === 0) {
      this.remove(img)
    } else {
      img.addEventListener("error", () => this.remove(img), { once: true })
    }
  }

  remove(img) {
    img.closest("[data-link-preview-image-box]")?.remove()
  }
}

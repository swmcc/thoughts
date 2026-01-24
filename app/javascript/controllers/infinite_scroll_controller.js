import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination", "loading"]
  static values = { url: String }

  connect() {
    this.loading = false
    this.createObserver()
  }

  createObserver() {
    const options = {
      root: null,
      rootMargin: "200px",
      threshold: 0
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loading) {
          this.loadMore()
        }
      })
    }, options)

    if (this.hasPaginationTarget) {
      this.observer.observe(this.paginationTarget)
    }
  }

  async loadMore() {
    const nextPageLink = this.paginationTarget.querySelector("a")
    if (!nextPageLink) return

    this.loading = true
    this.showLoading()

    try {
      const response = await fetch(nextPageLink.href, {
        headers: {
          Accept: "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Failed to load more:", error)
    } finally {
      this.loading = false
      this.hideLoading()
    }
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }
    if (this.hasPaginationTarget) {
      this.paginationTarget.classList.add("opacity-0")
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden")
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}

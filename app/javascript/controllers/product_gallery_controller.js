import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "container",
    "slide",
    "thumbnail",
    "dot",
    "counter",
    "modal",
    "modalImage",
    "modalCounter"
  ]

  static values = {
    currentIndex: { type: Number, default: 0 },
    images: { type: Array, default: [] }
  }

  connect() {
    this.updateIndicator(0)
    this.boundKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundKeydown)
    document.body.style.overflow = ""
  }

  // Smooth scroll to a specific slide index
  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    if (!isNaN(index)) {
      this.scrollToIndex(index)
    }
  }

  nextSlide() {
    if (!this.hasImagesValue || this.imagesValue.length === 0) return
    const nextIndex = (this.currentIndexValue + 1) % this.imagesValue.length
    this.scrollToIndex(nextIndex)
  }

  prevSlide() {
    if (!this.hasImagesValue || this.imagesValue.length === 0) return
    const prevIndex = (this.currentIndexValue - 1 + this.imagesValue.length) % this.imagesValue.length
    this.scrollToIndex(prevIndex)
  }

  scrollToIndex(index) {
    if (!this.hasContainerTarget) return
    const container = this.containerTarget
    const width = container.clientWidth
    container.scrollTo({
      left: width * index,
      behavior: "smooth"
    })
    this.updateIndicator(index)
  }

  // Detect scroll and update indicators dynamically
  onScroll() {
    if (!this.hasContainerTarget || !this.hasImagesValue || this.imagesValue.length === 0) return
    const container = this.containerTarget
    const width = container.clientWidth
    if (width === 0) return
    const index = Math.round(container.scrollLeft / width)
    if (index !== this.currentIndexValue && index >= 0 && index < this.imagesValue.length) {
      this.updateIndicator(index)
    }
  }

  updateIndicator(index) {
    this.currentIndexValue = index
    const total = this.hasImagesValue ? this.imagesValue.length : 0

    // Update dots
    if (this.hasDotTargets) {
      this.dotTargets.forEach((dot, idx) => {
        if (idx === index) {
          dot.classList.remove("bg-white/50", "w-2")
          dot.classList.add("bg-white", "w-5")
        } else {
          dot.classList.remove("bg-white", "w-5")
          dot.classList.add("bg-white/50", "w-2")
        }
      })
    }

    // Update thumbnails
    if (this.hasThumbnailTargets) {
      this.thumbnailTargets.forEach((thumb, idx) => {
        if (idx === index) {
          thumb.classList.add("ring-2", "ring-indigo-600", "scale-105")
        } else {
          thumb.classList.remove("ring-2", "ring-indigo-600", "scale-105")
        }
      })
    }

    // Update text counter (e.g. 1 / 4)
    if (this.hasCounterTarget && total > 0) {
      this.counterTarget.textContent = `${index + 1} / ${total}`
    }
  }

  // --- Lightbox Modal (Expand Fullscreen) ---

  openLightbox(event) {
    if (event) event.preventDefault()
    if (!this.hasImagesValue || this.imagesValue.length === 0) return

    let index = 0
    if (event && event.currentTarget && event.currentTarget.dataset.index !== undefined) {
      index = parseInt(event.currentTarget.dataset.index, 10)
    } else {
      index = this.currentIndexValue
    }

    if (isNaN(index) || index < 0 || index >= this.imagesValue.length) {
      index = 0
    }

    this.showModalImage(index)
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      this.modalTarget.classList.add("flex")
      document.body.style.overflow = "hidden"
      window.addEventListener("keydown", this.boundKeydown)
    }
  }

  closeLightbox(event) {
    if (event) {
      // If clicking inside the content box, do not close unless target is the close button or backdrop
      if (event.target !== event.currentTarget && !event.target.closest("[data-close-lightbox]")) {
        return
      }
      event.preventDefault()
    }

    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      this.modalTarget.classList.remove("flex")
      document.body.style.overflow = ""
      window.removeEventListener("keydown", this.boundKeydown)
    }
  }

  nextLightbox(event) {
    if (event) event.stopPropagation()
    if (!this.hasImagesValue || this.imagesValue.length === 0) return
    const nextIndex = (this.currentIndexValue + 1) % this.imagesValue.length
    this.showModalImage(nextIndex)
  }

  prevLightbox(event) {
    if (event) event.stopPropagation()
    if (!this.hasImagesValue || this.imagesValue.length === 0) return
    const prevIndex = (this.currentIndexValue - 1 + this.imagesValue.length) % this.imagesValue.length
    this.showModalImage(prevIndex)
  }

  showModalImage(index) {
    this.currentIndexValue = index
    const total = this.imagesValue.length
    const imageUrl = this.imagesValue[index]

    if (this.hasModalImageTarget && imageUrl) {
      this.modalImageTarget.src = imageUrl
    }
    if (this.hasModalCounterTarget && total > 0) {
      this.modalCounterTarget.textContent = `${index + 1} / ${total}`
    }
    this.updateIndicator(index)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.closeLightbox()
    } else if (event.key === "ArrowRight") {
      this.nextLightbox()
    } else if (event.key === "ArrowLeft") {
      this.prevLightbox()
    }
  }
}

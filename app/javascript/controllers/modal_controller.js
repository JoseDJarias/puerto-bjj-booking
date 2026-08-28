import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    // If the modal doesn't have the 'hidden' class when connecting (like the Turbo one), block the scroll
    if (!this.hasContainerTarget || !this.containerTarget.classList.contains("hidden")) {
      document.body.classList.add("overflow-hidden")
    }
  }

  // 2. Open the modal (For the static one that you already had)
  open(e) {
    if (e) e.preventDefault()
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove("hidden")
      document.body.classList.add("overflow-hidden")
    }
  }

  stopPropagation(e) {
    e.stopPropagation()
  }

  // 3. Close the modal (The "All terrain")
  close(e) {
    if (e) e.preventDefault()
    
    // CASE A: It's a modal loaded by Turbo (dynamic)
    const frame = this.element.closest('turbo-frame')
    if (frame && (frame.id === "admin_modal" || frame.id === "modal_detail")) {
      if (frame.id === "modal_detail" && window.location.pathname !== "/") {
        window.location.href = "/"
      } else {
        frame.src = "" // Clean the URL so it can be reopened
        this.element.remove() // Remove the dynamic modal HTML
      }
    } 

    // CASE B: It's your static modal (the 'Add Athlete')
    if (this.hasContainerTarget) {
      this.containerTarget.classList.add("hidden")
    }
    
    document.body.classList.remove("overflow-hidden")
  }

  handleSuccess(event) {
    if (event.detail.success) {
      this.close()
      event.target.reset() 
    }
  }

  handleKeyup(e) {
    if (e.key === "Escape") this.close()
  }

  // Cleanup when leaving
  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }
}
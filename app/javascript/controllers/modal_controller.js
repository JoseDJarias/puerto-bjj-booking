import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  // Open the modal removing the 'hidden' class
  open(e) {
    e.preventDefault()
    this.containerTarget.classList.remove("hidden")
    // Optional: Block the scroll of the body
    document.body.classList.add("overflow-hidden")
  }

  close(e) {
    if (e) e.preventDefault()
    this.containerTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  handleKeyup(e) {
    if (e.key === "Escape") this.close()
  }
}
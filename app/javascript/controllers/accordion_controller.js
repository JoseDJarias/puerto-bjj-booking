// app/javascript/controllers/accordion_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "icon", "card"]
  static values = { alwaysActive: Boolean }

  connect() {
  }

  toggle(event) {
    if (!this.alwaysActiveValue && window.innerWidth >= 1024) return
    event.preventDefault()

    this.wrapperTarget.classList.toggle("grid-rows-[0fr]")
    this.wrapperTarget.classList.toggle("grid-rows-[1fr]")
    
    this.wrapperTarget.classList.toggle("opacity-0")
    this.wrapperTarget.classList.toggle("opacity-100")

    this.iconTarget.classList.toggle("rotate-180")

    this.cardTarget.classList.toggle("ring-indigo-500")
    this.cardTarget.classList.toggle("ring-2")
    this.cardTarget.classList.toggle("ring-slate-200")
    this.cardTarget.classList.toggle("shadow-md")
  }
}
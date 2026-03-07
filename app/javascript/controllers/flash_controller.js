import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Espera 4000ms (4 segundos) y luego ejecuta dismiss()
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 4000)
  }

  dismiss() {
    // 1. Añade clases para desvanecer (animación de Tailwind)
    this.element.classList.add("transition", "ease-in", "duration-500", "opacity-0", "translate-x-full")

    // 2. Espera a que termine la animación (500ms) y elimina el elemento del DOM
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  disconnect() {
    // Limpia el timer si el usuario cambia de página antes de que termine
    clearTimeout(this.timeout)
  }
}
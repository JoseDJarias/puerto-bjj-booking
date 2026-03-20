import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    // Clonamos el contenido del template (el input de hora)
    const content = this.templateTarget.innerHTML
    // Lo insertamos antes del botón de "Añadir"
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    // Eliminamos el div contenedor del input específico
    event.target.closest('.time-slot-item').remove()
  }
}
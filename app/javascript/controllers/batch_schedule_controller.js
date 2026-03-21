import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Conectamos los targets que definiste en tu HTML
  static targets = ["container", "template"]

  // 1. Añadir hora extra al día específico
  add(event) {
    event.preventDefault()
    
    // Al ser un controlador por día, 'this.templateTarget' 
    // siempre será el de este cuadro de día (ej. Lunes)
    const content = this.templateTarget.innerHTML
    
    // Insertamos al final del contenedor de este día
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  // 2. Remover la hora extra
  remove(event) {
    event.preventDefault()
    
    // Buscamos el div que envuelve al input y al botón X
    const slot = event.currentTarget.closest('.relative')
    if (slot) {
      slot.remove()
    }
  }

  // 3. Activar/Desactivar visualmente (opcional por si el CSS peer falla)
  toggleDay(event) {
    const isChecked = event.target.checked
    
    if (isChecked) {
      this.containerTarget.classList.remove("opacity-20", "pointer-events-none")
      this.containerTarget.classList.add("opacity-100", "pointer-events-auto")
    } else {
      this.containerTarget.classList.add("opacity-20", "pointer-events-none")
      this.containerTarget.classList.remove("opacity-100", "pointer-events-auto")
    }
  }
}
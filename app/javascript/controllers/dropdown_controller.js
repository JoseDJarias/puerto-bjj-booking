import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu", "input", "label" ]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  // Se activa al hacer clic en una opción (Gi, No Gi, etc.)
  select(event) {
    const { value, label } = event.currentTarget.dataset
    
    // 1. Cambia el valor del input hidden para Rails
    if (this.hasInputTarget) this.inputTarget.value = value
    
    // 2. Cambia el texto visible en el botón
    if (this.hasLabelTarget) this.labelTarget.innerText = label
    
    // 3. Cierra el menú
    this.menuTarget.classList.add("hidden")
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["active", "inactive"]

  connect() {
    // Activa el primer tab por defecto al cargar
    this.showTab(0)
  }

  switch(event) {
    event.preventDefault()
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  showTab(index) {
    this.tabTargets.forEach((el, i) => {
      if (i === index) {
        // Tab Activo
        el.classList.add(...this.activeClasses)
        el.classList.remove(...this.inactiveClasses)
        this.panelTargets[i].classList.remove("hidden")
      } else {
        // Tab Inactivo
        el.classList.remove(...this.activeClasses)
        el.classList.add(...this.inactiveClasses)
        this.panelTargets[i].classList.add("hidden")
      }
    })
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  open() {
    // 1. Muestra el Sidebar (quita la clase que lo saca de la pantalla)
    this.sidebarTarget.classList.remove("-translate-x-full")
    
    // 2. Muestra el Overlay (quita transparencia y PERMITE clics)
    this.overlayTarget.classList.remove("opacity-0", "pointer-events-none")
    this.overlayTarget.classList.add("opacity-100") 
  }

  close() {
    // 1. Oculta el Sidebar
    this.sidebarTarget.classList.add("-translate-x-full")
    
    // 2. Oculta el Overlay (agrega transparencia y BLOQUEA clics para que no estorbe)
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0", "pointer-events-none")
  }
}
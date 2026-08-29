import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "newPreviewsContainer"]

  connect() {
    this.dataTransfer = new DataTransfer()
  }

  // Trigger the hidden file input when user clicks the upload button
  triggerFileInput(event) {
    if (event) event.preventDefault()
    this.inputTarget.click()
  }

  // Handle files selected from file picker and accumulate them
  handleFiles() {
    const files = Array.from(this.inputTarget.files)
    if (!files || files.length === 0) return

    // Append newly selected files to our DataTransfer collection
    files.forEach(file => {
      if (file.type.startsWith("image/")) {
        this.dataTransfer.items.add(file)
      }
    })

    // Sync input files with accumulated DataTransfer
    this.inputTarget.files = this.dataTransfer.files

    // Re-render the new previews grid
    this.renderPreviews()
  }

  renderPreviews() {
    if (!this.hasNewPreviewsContainerTarget) return
    this.newPreviewsContainerTarget.innerHTML = ""

    const files = Array.from(this.dataTransfer.files)
    files.forEach((file, index) => {
      const reader = new FileReader()
      reader.onload = (e) => {
        const card = document.createElement("div")
        card.className = "relative w-24 h-24 rounded-2xl overflow-hidden border-2 border-indigo-400 bg-slate-50 shadow-md group animate-in fade-in zoom-in duration-200"

        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "w-full h-full object-cover"

        // Badge
        const badge = document.createElement("span")
        badge.className = "absolute bottom-1.5 inset-x-1.5 text-center text-[9px] font-black uppercase tracking-wider bg-indigo-600/90 text-white rounded-lg py-0.5 backdrop-blur-sm pointer-events-none"
        badge.textContent = "Nueva"

        // Remove button for this specific file before saving
        const removeBtn = document.createElement("button")
        removeBtn.type = "button"
        removeBtn.className = "absolute top-1.5 right-1.5 w-6 h-6 rounded-full bg-slate-900/80 hover:bg-red-600 text-white flex items-center justify-center backdrop-blur-sm shadow-sm transition-colors cursor-pointer"
        removeBtn.innerHTML = `<svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>`
        removeBtn.title = "Quitar foto seleccionada"
        removeBtn.onclick = (ev) => {
          ev.preventDefault()
          ev.stopPropagation()
          this.removeFileAtIndex(index)
        }

        card.appendChild(img)
        card.appendChild(badge)
        card.appendChild(removeBtn)
        this.newPreviewsContainerTarget.appendChild(card)
      }
      reader.readAsDataURL(file)
    })
  }

  removeFileAtIndex(indexToRemove) {
    const newDt = new DataTransfer()
    const files = Array.from(this.dataTransfer.files)

    files.forEach((file, idx) => {
      if (idx !== indexToRemove) {
        newDt.items.add(file)
      }
    })

    this.dataTransfer = newDt
    this.inputTarget.files = this.dataTransfer.files
    this.renderPreviews()
  }
}

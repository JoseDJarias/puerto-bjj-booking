import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "previewContainer"]

  preview() {
    const files = this.inputTarget.files
    if (!files || files.length === 0) return

    // Clear any previous new preview cards
    const existingNewPreviews = this.previewContainerTarget.querySelectorAll(".new-preview-item")
    existingNewPreviews.forEach(el => el.remove())

    Array.from(files).forEach((file, index) => {
      if (!file.type.startsWith("image/")) return

      const reader = new FileReader()
      reader.onload = (e) => {
        const card = document.createElement("div")
        card.className = "new-preview-item relative w-24 h-24 rounded-2xl overflow-hidden border-2 border-indigo-400 bg-slate-50 shadow-md group animate-in fade-in zoom-in duration-200"

        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "w-full h-full object-cover"

        const badge = document.createElement("span")
        badge.className = "absolute bottom-1 inset-x-1 text-center text-[9px] font-black uppercase tracking-wider bg-indigo-600/90 text-white rounded-lg py-0.5 backdrop-blur-sm"
        badge.textContent = "Nueva"

        card.appendChild(img)
        card.appendChild(badge)
        this.previewContainerTarget.appendChild(card)
      }
      reader.readAsDataURL(file)
    })
  }
}

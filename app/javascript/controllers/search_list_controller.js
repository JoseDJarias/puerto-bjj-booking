// app/javascript/controllers/search_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  itemTargetConnected() {
    this.applyFilters()
  }

  toggleAll() {
    this.applyFilters()
  }

  filter() {
    this.applyFilters()
  }

  applyFilters() {
    const searchInput = this.element.querySelector('input[type="text"]')
    const toggleInput = this.element.querySelector('input[type="checkbox"]')
    
    const query = searchInput ? searchInput.value.toLowerCase() : ""
    const showAll = toggleInput ? toggleInput.checked : false

    this.itemTargets.forEach(item => {
      const name = item.dataset.searchName || ""
      const hasAccess = item.dataset.hasAccess === "true"

      const matchesSearch = name.includes(query)
      const matchesAccess = hasAccess || showAll

      if (matchesSearch && matchesAccess) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }
}
// app/javascript/controllers/search_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  
  toggleAll(e) {
    const showAll = e.target.checked
    this.itemTargets.forEach(item => {
      if (item.dataset.hasAccess === "false") {
        item.classList.toggle("hidden", !showAll)
      }
    })
  }

  filter(event) {
    const query = event.target.value.toLowerCase()

    this.itemTargets.forEach(item => {
      const searchContent = item.dataset.searchName
      if (searchContent.includes(query)) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }
}

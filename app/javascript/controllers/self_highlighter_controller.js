import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="self-highlighter"
export default class extends Controller {
  static values = {
    id: Number // The ID of the user in this row
  }

  static classes = ["active"] // The classes we will add if it matches

  connect() {
    // 1. We search who the logged in user is by reading the head
    const currentUserIdMeta = document.querySelector('meta[name="current-user-id"]')
    if (!currentUserIdMeta) return

    const currentUserId = parseInt(currentUserIdMeta.content)

    // 2. If the ID of this row matches the logged in user's ID...
    if (this.idValue === currentUserId) {
      this.highlight()
    }
  }

  highlight() {
    // We add the Tailwind classes defined in the HTML
    this.element.classList.add(...this.activeClasses)
    
    // Optional: Search for the badge of "You" and show it
    const badge = this.element.querySelector('.me-badge')
    if (badge) badge.classList.remove('hidden')
  }
}
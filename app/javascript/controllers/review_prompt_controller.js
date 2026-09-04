import { Controller } from "@hotwired/stimulus"
import { FetchRequest } from "@rails/request.js"

export default class extends Controller {
  // Hide temporarily (until page refresh)
  hideTemporarily(event) {
    if (event) event.preventDefault()
    this.element.classList.add("hidden")
  }

  // Hide permanently and hit backend to acknowledge
  async acknowledge(event) {
    // If it was the link, we let it open in a new tab but still hide it and acknowledge
    // We don't preventDefault if it's the <a> tag so it opens Google Maps.
    
    // Hide it visually right away for instant feedback
    this.element.classList.add("hidden")

    // Send the PATCH request to the backend
    const request = new FetchRequest("patch", "/user/acknowledge_review_prompt")
    await request.perform()
  }
}

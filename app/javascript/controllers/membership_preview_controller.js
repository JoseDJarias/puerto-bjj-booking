import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount", "endDate", "form"]

  update() {
    const formData = new FormData(this.formTarget)
    const params = new URLSearchParams(formData)

    fetch(`/admin/membresias/calculate_totals?${params.toString()}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then(data => {
        this.amountTarget.textContent = `$${data.amount}`
        this.endDateTarget.textContent = data.end_date
        const submitBtn = this.element.querySelector('input[type="submit"]')
        if (submitBtn) submitBtn.disabled = (data.amount <= 0)
      })
      .catch(() => {})
  }
}
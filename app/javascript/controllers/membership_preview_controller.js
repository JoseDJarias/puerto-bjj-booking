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
    
        // FIX 1: Usamos .value para que se vea en el input editable
        if (this.hasAmountTarget) {
          this.amountTarget.value = data.amount
        }

        // Actualizamos la fecha de vencimiento
        if (this.hasEndDateTarget) {
          this.endDateTarget.textContent = data.end_date
        }

        // FIX 2: Quitamos la restricción de deshabilitar si es 0
        // Ahora permitimos que el admin confirme incluso si el monto es 0 (becas/convenios)
        const submitBtn = this.element.querySelector('input[type="submit"]')
        if (submitBtn) {
          // El botón solo se deshabilita si NO hay datos básicos, no por el precio
          submitBtn.disabled = (!userId || !data.end_date)
        }
      })
      .catch((error) => {
        console.error("Error calculating totals:", error)
      })
  }
}
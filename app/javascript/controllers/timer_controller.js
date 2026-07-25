import { Controller } from "@hotwired/stimulus"

export default class TimerController extends Controller {
  static targets = ["remaining"]
  static values = { expiresAt: Number }

  connect() {
    this.update()
    this.intervalId = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    clearInterval(this.intervalId)
  }

  update() {
    const currentTime = Date.now() / 1000
    const remainingSeconds = Math.max(
      0,
      Math.ceil(this.expiresAtValue - currentTime)
    )

    const minutes = Math.floor(remainingSeconds / 60)
    const seconds = remainingSeconds % 60

    this.remainingTarget.textContent =
      `${minutes}:${String(seconds).padStart(2, "0")}`

    if (remainingSeconds === 0) {
      clearInterval(this.intervalId)
    }
  }
}

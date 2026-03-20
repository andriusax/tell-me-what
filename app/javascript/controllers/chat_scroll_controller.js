import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("chat-scroll controller connected")
    requestAnimationFrame(() => {
      this.element.scrollTop = this.element.scrollHeight
    })
  }
}

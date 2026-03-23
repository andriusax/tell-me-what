import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "container", "loader"]
  connect() {


    this.containerTarget.scrollTop = this.containerTarget.scrollHeight


    this.observer = new MutationObserver(() => {
    this.scrollBottom()
    })

    this.observer.observe(this.containerTarget, {
    childList: true
    })
  }
  // insertLoader() {
  //   const loader = `<h1 data-chat-scroll-target="loader">Loading...</h1>`
  //   this.containerTarget.insertAdjacentHTML("beforeend", loader)
  // }

  scrollBottom() {
    const el = this.containerTarget
    console.log(el)

    el.scrollTop = el.scrollHeight

  }
}

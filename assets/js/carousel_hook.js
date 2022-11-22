// This shit is cursed I just didn't think of another way using hooks
export default Carousel = {
  carouselPage() {
    return Number(this.el.dataset.carouselPage)
  },
  carouselPages() {
    return Number(this.el.dataset.carouselPages)
  },
  nextIndex() {
    this.el.dataset.carouselPage =
      (this.carouselPage() + 1) % this.carouselPages()
    return this.carouselPage()
  },
  prevIndex() {
    this.el.dataset.carouselPage =
      (this.carouselPage() + this.carouselPages() - 1) % this.carouselPages()
    return this.carouselPage()
  },
  images() {
    return this.el.querySelector("[data-carousel-body]")
  },
  dots() {
    return this.el.querySelector("[data-slide-indicators]")
  },
  toggleImage(n) {
    this.images()
      .querySelector(":scope > :not(.hidden)")
      .classList.toggle("hidden")
    this.images().children[n].classList.toggle("hidden")
    this.toggleDot(n)
  },
  toggleDot(n) {
    this.dots()
      .querySelector(":scope > :not(.opacity-30)")
      .classList.toggle("opacity-30")
    this.dots().children[n].classList.toggle("opacity-30")
  },
  mounted() {
    this.images().firstElementChild.classList.toggle("hidden")
    this.dots().firstElementChild.classList.toggle("opacity-30")
    this.el
      .querySelector("[data-carousel-next]")
      .addEventListener("click", () => {
        this.toggleImage(this.nextIndex())
      })
    this.el
      .querySelector("[data-carousel-prev]")
      .addEventListener("click", () => {
        this.toggleImage(this.prevIndex())
      })
  },
}

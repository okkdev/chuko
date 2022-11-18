// This shit is cursed I just didn't think of another way using hooks
export default Carousel = {
  carouselData() {
    return this.el.dataset
  },
  nextIndex() {
    this.carouselData().carouselPage =
      (this.carouselData().carouselPage + 1) % this.carouselData().carouselPages
    return this.carouselData().carouselPage
  },
  prevIndex() {
    this.carouselData().carouselPage =
      (this.carouselData().carouselPage - 1) % this.carouselData().carouselPages
    return this.carouselData().carouselPage
  },
  images() {
    return this.el.querySelector(".carousel-body")
  },
  dots() {
    return this.el.querySelector(".slide-indicators")
  },
  toggleImage(n) {
    this.images()
      .querySelector(":scope > :not(.hidden)")
      .classList.toggle("hidden")
    this.images().children[n].classList.toggle("hidden")
    this.toggleDot(n)
  },
  toggleDot(n) {
    console.log("toggle dot " + n)
    this.dots()
      .querySelector(":scope > :not(.opacity-30)")
      .classList.toggle("opacity-30")
    this.dots().children[n].classList.toggle("opacity-30")
  },
  mounted() {
    this.images().firstElementChild.classList.toggle("hidden")
    this.dots().firstElementChild.classList.toggle("opacity-30")
    this.el.querySelector(".carousel-next").addEventListener("click", () => {
      this.toggleImage(this.nextIndex())
    })
    this.el.querySelector(".carousel-prev").addEventListener("click", () => {
      this.toggleImage(this.prevIndex())
    })
  },
}

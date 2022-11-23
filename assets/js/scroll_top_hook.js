export default ScrollTop = {
  scrollViz() {
    if (window.scrollY >= window.innerHeight) {
      this.el.classList.remove("hidden")
    } else {
      this.el.classList.add("hidden")
    }
  },
  mounted() {
    this.el.addEventListener("click", () =>
      window.scroll({ top: 0, behavior: "smooth" })
    )

    window.addEventListener("scroll", () => this.scrollViz())
  },
}

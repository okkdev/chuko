const LocalstorageHook = {
  mounted() {
    this.handleEvent("set_history", ({ history }) => {
      console.log(history)
      localStorage.setItem("history", history)
    })

    this.pushEventTo(this.el, "receive_history", {
      history: localStorage.getItem("history"),
    })
  },
}

export default LocalstorageHook

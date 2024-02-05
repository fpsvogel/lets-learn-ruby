const backToTopButton = document.querySelector(".back-to-top");

window.onscroll = function(_event) {
  const scrolledUp = this.oldScrollY > this.scrollY;

  if (scrolledUp && this.scrollY > 70) {
    backToTopButton.style.visibility = "visible";
  } else {
    backToTopButton.style.visibility = "hidden";
  }

  this.oldScrollY = this.scrollY;
}

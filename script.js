const cursorOrb = document.querySelector(".cursor-orb");

let targetX = window.innerWidth / 2;
let targetY = window.innerHeight / 2;
let orbX = targetX;
let orbY = targetY;

window.addEventListener("pointermove", (event) => {
  targetX = event.clientX;
  targetY = event.clientY;
});

window.addEventListener("resize", () => {
  targetX = window.innerWidth / 2;
  targetY = window.innerHeight / 2;
});

function followCursor() {
  orbX += (targetX - orbX) * 0.12;
  orbY += (targetY - orbY) * 0.12;

  cursorOrb.style.transform = `translate3d(${orbX}px, ${orbY}px, 0) translate(-50%, -50%)`;
  requestAnimationFrame(followCursor);
}

followCursor();

const menuToggle = document.getElementById("menuToggle");
const dropdownMenu = document.getElementById("dropdownMenu");


menuToggle.addEventListener("click", () => {
    const isOpen = dropdownMenu.classList.toggle("open");

    menuToggle.setAttribute(
        "aria-expanded",
        isOpen
    );
});


document.addEventListener("click", (event) => {
    const clickedInsideMenu =
        menuToggle.contains(event.target) ||
        dropdownMenu.contains(event.target);

    if (!clickedInsideMenu) {
        dropdownMenu.classList.remove("open");

        menuToggle.setAttribute(
            "aria-expanded",
            "false"
        );
    }
});
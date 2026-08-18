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

/* Cart banner logic */

const cartBanner =
    document.getElementById("cartBanner");

const cartBannerClose =
    document.getElementById("cartBannerClose");

const cartBannerDismiss =
    document.getElementById("cartBannerDismiss");


function closeCartBanner() {
    if (cartBanner) {
        cartBanner.remove();
    }
}


if (cartBannerClose) {
    cartBannerClose.addEventListener(
        "click",
        closeCartBanner
    );
}


if (cartBannerDismiss) {
    cartBannerDismiss.addEventListener(
        "click",
        closeCartBanner
    );
}
var menu = document.querySelector(".menu");
let subMenu;
if (menu) {
    let menuSection = menu.querySelector(".menu-section");
    let menuArrow = menu.querySelector(".menu-mobile-arrow");
    let menuClosed = menu.querySelector(".menu-mobile-close");
    let menuTrigger = document.querySelector(".menu-mobile-trigger");
    let menuOverlay = document.querySelector(".overlay");
    menuSection.addEventListener("click", (e) => {
        if (menu &&!menu.classList.contains("active")) {
            return;
        }

        if (e.target.closest(".menu-item-has-children")) {
            let hasChildren = e.target.closest(".menu-item-has-children");
            showSubMenu(hasChildren);
        }
    });

    menuArrow.addEventListener("click", () => {
        hideSubMenu();
    });

    menuTrigger.addEventListener("click", () => {
        toggleMenu();
    });

    menuClosed.addEventListener("click", () => {
        toggleMenu();
    });

    menuOverlay.addEventListener("click", () => {
        toggleMenu();
    });
}


function toggleMenu() {
    if(menu){
        menu.classList.toggle("active");
    }
    if(menuOverlay){
        menuOverlay.classList.toggle("active");
    }
}

function showSubMenu(hasChildren) {
    subMenu = hasChildren.querySelector(".menu-subs");
    subMenu.classList.add("active");
    subMenu.style.animation = "slideLeft 0.5s ease forwards";
    let menuTitle =
        hasChildren.querySelector("i").parentNode.childNodes[0].textContent;
    menu.querySelector(".menu-mobile-title").innerHTML = menuTitle;
    menu.querySelector(".menu-mobile-header").classList.add("active");
}

function hideSubMenu() {
    subMenu.style.animation = "slideRight 0.5s ease forwards";
    setTimeout(() => {
        subMenu.classList.remove("active");
    }, 300);

    menu.querySelector(".menu-mobile-title").innerHTML = "";
    menu.querySelector(".menu-mobile-header").classList.remove("active");
}

window.onresize = function () {
    if (this.innerWidth > 991) {
        if (menu && menu.classList.contains("active")) {
            toggleMenu();
        }
    }
};
/*
(() => {
    let addWindowScrollEvent = false;
    function headerScroll() {
        var isHome = isHomePage();
        let header = document.querySelector("header.header");
        if(isHome){
            addWindowScrollEvent = true;
        }else{
            header.classList.add("fixed-colors");
            let headerWrappertemp = document.querySelector("div.headerWrapper");
            headerWrappertemp.classList.add("fixed-width-custom");
        }
        if (header) {
            let headerShow = header.hasAttribute("data-scroll-show");
            let headerShowTimer = header.dataset.scrollShow
                ? header.dataset.scrollShow
                : 500;
            let startPoint = header.dataset.scroll ? header.dataset.scroll : 1;
            let scrollDirection = 0;
            let timer;
            document.addEventListener("windowScroll", function (e) {
                let scrollTop = window.scrollY;
                clearTimeout(timer);
                if (scrollTop >= startPoint) {
                    !header.classList.contains("_header-scroll")
                        ? header.classList.add("_header-scroll")
                        : null;
                    if (headerShow) {
                        if (scrollTop > scrollDirection)
                            header.classList.contains("_header-show")
                                ? header.classList.remove("_header-show")
                                : null;
                        else
                            !header.classList.contains("_header-show")
                                ? header.classList.add("_header-show")
                                : null;
                        timer = setTimeout(() => {
                            !header.classList.contains("_header-show")
                                ? header.classList.add("_header-show")
                                : null;
                        }, headerShowTimer);
                    }
                } else {
                    header.classList.contains("_header-scroll")
                        ? header.classList.remove("_header-scroll")
                        : null;
                    if (headerShow)
                        header.classList.contains("_header-show")
                            ? header.classList.remove("_header-show")
                            : null;
                }
                scrollDirection = scrollTop <= 0 ? 0 : scrollTop;
            });
        }
    }

    function isHomePage(){
        var pathlength = window.location.href.split('?')[0].split('\/').length;
        var pageName = window.location.href.split('?')[0].split('\/')[pathlength - 1];
        var showHero = false;
        if (pageName == '') {
            showHero = true;
        }
        return showHero;
    }

    setTimeout(() => {
        if (addWindowScrollEvent) {
            let windowScroll = new Event("windowScroll");
            window.addEventListener("scroll", function (e) {
                document.dispatchEvent(windowScroll);
            });
        }
    }, 0);
    headerScroll();
})();
*/

let accordionTitles = document.querySelectorAll(".question");
if (accordionTitles) {
    accordionTitles.forEach((accordionTitle) => {
        accordionTitle.addEventListener("click", () => {
            if (accordionTitle.classList.contains("is-open")) {
                accordionTitle.classList.remove("is-open");
            } else {
                let accordionTitlesWithIsOpen = document.querySelectorAll(".is-open");
                accordionTitlesWithIsOpen.forEach((accordionTitleWithIsOpen) => {
                    accordionTitleWithIsOpen.classList.remove("is-open");
                });
                accordionTitle.classList.add("is-open");
            }
        });
    });
}

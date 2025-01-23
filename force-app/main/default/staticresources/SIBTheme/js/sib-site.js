
function addCategorySwiper(){
    let swiper = new Swiper("#swiper-categories", {
        // Optional parameters
        observeParents: true,
        loop: true,
        speed: 1000,
        autoplay: {
            delay: 800,
            disableOnInteraction: false,
        },
        pagination: {
            el: ".pagination-categories",
            type: "progressbar",
        },
        navigation: {
            prevEl: ".swiper-button-prev",
            nextEl: ".swiper-button-next",
        },
        breakpoints: {
            240: {
                slidesPerView: "auto",
                spaceBetween: 10,
                grabCursor: true,
            },
    
            540: {
                slidesPerView: "2",
                spaceBetween: 10,
            },
            1020: {
                slidesPerView: "3",
                spaceBetween: 24,
            },
            1360: {
                slidesPerView: 4,
                spaceBetween: 24,
            },
        },
    });
    
    let swiperProducts = new Swiper("#swiper-products", {
        // Optional parameters
        observeParents: true,
        loop: true,
        speed: 1000,
        autoplay: {
            delay: 800,
            disableOnInteraction: false,
        },
        pagination: {
            el: ".pagination-products",
            type: "progressbar",
        },
        navigation: {
            prevEl: ".swiper-button-prev-products",
            nextEl: ".swiper-button-next-products",
        },
        breakpoints: {
            240: {
                slidesPerView: "auto",
                spaceBetween: 14,
                grabCursor: true,
            },
    
            540: {
                slidesPerView: "1",
                spaceBetween: 10,
            },
            700: {
                slidesPerView: "2",
                spaceBetween: 10,
            },
            980: {
                slidesPerView: "3",
                spaceBetween: 16,
            },
        },
    });
    
    let swiperHero = new Swiper(".swiper-hero", {
        // Optional parameters
        observeParents: true,
        loop: true,
        speed: 2000,
        autoplay: {
            delay: 1600,
            disableOnInteraction: false,
        },
        pagination: {
            el: ".pagination-hero",
            type: "progressbar",
        },
        navigation: {
            prevEl: ".swiper-button-prev-hero",
            nextEl: ".swiper-button-next-hero",
        },
        breakpoints: {
            240: {
                centeredSlides: true,
                slidesPerView: 1,
                spaceBetween: 0,
                grabCursor: true,
            },
        },
    });
}
addCategorySwiper();

(function () {
    "use strict";

    // breakpoint where swiper will be destroyed
    // and switches to a dual-column layout
    let breakpoint = window.matchMedia("(max-width: 820.9px)");

    // keep track of swiper instances to destroy later
    let mySwiper;

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    let breakpointChecker = function () {
        // if larger viewport and multi-row layout needed
        if (breakpoint.matches === true) {
            // clean up old instances and inline styles when available
            if (mySwiper !== undefined) mySwiper.destroy(true, true);

            // or/and do nothing
            return;

            // else if a small viewport and single column layout needed
        } else if (breakpoint.matches === false) {
            // fire small viewport version of swiper
            return enableSwiper();
        }
    };

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    let enableSwiper = function () {
        mySwiper = new Swiper(".swiper-add", {
            observeParents: true,
            loop: true,
            speed: 1600,
            autoplay: {
                delay: 800,
                disableOnInteraction: false,
            },
            navigation: {
                prevEl: ".swiper-button-prev-add",
                nextEl: ".swiper-button-next-add",
            },
            breakpoints: {
                240: {
                    slidesPerView: "4",
                    spaceBetween: 10,
                    grabCursor: true,
                },

                540: {
                    slidesPerView: "2",
                    spaceBetween: 10,
                },
                820: {
                    slidesPerView: "3",
                    spaceBetween: 20,
                },
                900: {
                    slidesPerView: "4",
                    spaceBetween: 24,
                },
            },
        });
    };

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    // keep an eye on viewport size changes
    breakpoint.addListener(breakpointChecker);

    // kickstart
    breakpointChecker();
})(); /* IIFE end */

function enableCardRelatedProductSwiper(){
     // breakpoint where swiper will be destroyed
    // and switches to a dual-column layout
    let breakpoint = window.matchMedia("(max-width: 820.9px)");

    // keep track of swiper instances to destroy later
    let mySwiper;

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    let breakpointChecker = function () {
        // if larger viewport and multi-row layout needed
        if (breakpoint.matches === true) {
            // clean up old instances and inline styles when available
            if (mySwiper !== undefined) mySwiper.destroy(true, true);

            // or/and do nothing
            return;

            // else if a small viewport and single column layout needed
        } else if (breakpoint.matches === false) {
            // fire small viewport version of swiper
            return enableSwiper();
        }
    };

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    let enableSwiper = function () {
        mySwiper = new Swiper(".swiper-add", {
            observeParents: true,
            loop: true,
            speed: 1600,
            autoplay: {
                delay: 800,
                disableOnInteraction: false,
            },
            navigation: {
                prevEl: ".swiper-button-prev-add",
                nextEl: ".swiper-button-next-add",
            },
            breakpoints: {
                240: {
                    slidesPerView: "4",
                    spaceBetween: 10,
                    grabCursor: true,
                },

                540: {
                    slidesPerView: "2",
                    spaceBetween: 10,
                },
                820: {
                    slidesPerView: "3",
                    spaceBetween: 20,
                },
                900: {
                    slidesPerView: "4",
                    spaceBetween: 24,
                },
            },
        });
    };

    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    // keep an eye on viewport size changes
    breakpoint.addListener(breakpointChecker);

    // kickstart
    breakpointChecker();
}

enableCardRelatedProductSwiper();

function enableRelatedProductSwiper(){
    let swiperAlso = new Swiper("#swiper-also", {
        // Optional parameters
        observeParents: true,
    
        speed: 1500,
        autoplay: {
            delay: 800,
            disableOnInteraction: false,
        },
        pagination: {
            el: ".pagination-also",
            type: "progressbar",
        },
        navigation: {
            prevEl: ".swiper-button-prev-also",
            nextEl: ".swiper-button-next-also",
        },
        breakpoints: {
            240: {
                slidesPerView: 1,
                spaceBetween: 10,
                grabCursor: true,
                freeMode: true,
            },
    
            540: {
                slidesPerView: 2,
                spaceBetween: 10,
                loop: true,
            },
            740: {
                slidesPerView: 3,
                spaceBetween: 10,
                loop: true,
            },
            1200: {
                slidesPerView: 4,
                spaceBetween: 16,
                loop: true,
            },
        },
    });
}
enableRelatedProductSwiper();



function QuantityCounter() {
    let counters = document.querySelectorAll(".js-quantity-counter");

    if (counters.length == 0) {
        return;
    }

    counters.forEach((counter) => {
        let input = counter.querySelector(".js-quantity-counter-input");
        let buttons = counter.querySelectorAll(
            ".js-quantity-counter-prev, .js-quantity-counter-next"
        );

        input.addEventListener("keyup", function () {
            this.value = this.value.replace(/\D/g, "");
            let inputValue = this.value;
            if (inputValue && parseInt(inputValue) < 1) {
                this.value = 1;
            }
        });

        buttons.forEach((button) => {
            button.addEventListener("click", function () {
                let inputValue = input.value.replace(/\D/g, "");

                if (inputValue) {
                    inputValue = parseInt(inputValue);
                } else {
                    inputValue = 1;
                }

                if (this.classList.contains("js-quantity-counter-prev")) {
                    if (inputValue > 1) {
                        inputValue--;
                    }
                } else if (this.classList.contains("js-quantity-counter-next")) {
                    inputValue++;
                }

                input.value = inputValue;
            });
        }); // forEach buttons
    }); // forEach counters
}
QuantityCounter();


function enableProductPageSwiper(){
    //Product Page Slider
var swiperProductPage = new Swiper(".mySwiper", {
    loop: true,
    autoplay: false,
    spaceBetween: 2,
    slidesPerView: "auto",
    direction: "vertical",
    mousewheel: false,
});
var swiper2 = new Swiper(".mySwiper2", {
    loop: true,
    autoplay: false,
    spaceBetween: 10,
    effect: "fade",
    pagination: {
        el: ".pagination-product-page",
        type: "progressbar",
    },
    zoom: {
        maxRatio: 2,
    },
    thumbs: {
        swiper: swiperProductPage,
    },
    breakpoints: {
        240: {
            loop: true,
            slidesPerView: 1,
            grabCursor: true,
        },
        640: {
            slidesPerView: 1,
            pagination: false,
        },
    },
});
}
enableProductPageSwiper();


function cardDelete(){
    let deleteBtn = document.querySelectorAll(".card-remove");
    if(deleteBtn){
        deleteBtn.forEach(function (btn) {
            btn.addEventListener("click", function () {
                this.parentElement.parentElement.parentElement.parentElement.remove();
            });
        });
    }
    
}

function categoryHandleLayoutSwitch(){
    document.addEventListener("DOMContentLoaded", () => {
        let listViewButton = document.querySelector(".list-view-button");
        let gridViewButton = document.querySelector(".grid-view-button");
        let list = document.querySelector("#view-cards");
    
        listViewButton.addEventListener("click", function () {
            list.classList.remove("grid-view-filter");
            list.classList.add("list-view-filter");
            listViewButton.classList.add("active");
            gridViewButton.classList.remove("active");
        });
    
        gridViewButton.addEventListener("click", function () {
            list.classList.remove("list-view-filter");
            list.classList.add("grid-view-filter");
            gridViewButton.classList.add("active");
            listViewButton.classList.remove("active");
        });
    
        let clearFilters = document.getElementById("filter-btn");
        let panelFilters = document.getElementById("filters-panel");
        clearFilters.addEventListener("click", function () {
            this.classList.toggle("active");
            panelFilters.classList.toggle("active");
        });
    
    
    
    });
}
categoryHandleLayoutSwitch();


function handlePromo(){
    let promocodeClose = document.getElementById("promocode");
    if(promocodeClose){
        promocodeClose.addEventListener("click", function () {
            this.parentElement.remove();
        });
    }
}
handlePromo();


const consoleLogging = (message) => {
    if(true)
    {
        console.log(message);
    }
};

let loggingEnabled = false;
let firstTimeLoad = false

const applicationLogging = (loggingList) => {
    if (!loggingEnabled) {
        showLog();
    }
    if (loggingEnabled)
    {
        let logMessages = JSON.parse(loggingList);
        logMessages.forEach(function (item, index)
        {
            if (item.loggingLevel === 'DEBUG')
            {
                console.log(item.entryPoint + item.className + ':' + item.methodName + ': ' + item.message);
            } else if (item.loggingLevel === 'ERROR')
            {
                console.error(item.entryPoint + item.className + ':' + item.methodName + ': ' + item.message);
            }
        });
    }
};


function showLog() {
    if (!firstTimeLoad)
    {
        let params = getUrlVars(window.location.href);
        let loggingTokenExist = false ;//TODO getCookie("loggingToken");
        consoleLogging('loggingTokenExist : ' + loggingTokenExist);
        if ((params.hasOwnProperty('loggingToken') && params['loggingToken'] === 'B2B') ||
            (loggingTokenExist && loggingTokenExist === 'B2B') || loggingEnabled)
        {
            //TODO setCookie('loggingToken', B2B_logging_identifier)
            loggingEnabled = true;
        }
        firstTimeLoad = true;
    }
}

function getUrlVars(urlParams) {
    var vars = [], hash;
    if (urlParams) {
        var hashes = urlParams?.slice(urlParams?.indexOf('?') + 1)?.split('&');
        if (hashes) {
            for (var i = 0; i < hashes?.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
        }
    }
    return vars;
}

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
    var expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(";");
    for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == " ") {
        c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
    }
    }
    return "";
}

const isInSitePreview = () => {
    let url = document.URL;
    return (url.indexOf('sitepreview') > 0 
        || url.indexOf('livepreview') > 0
        || url.indexOf('live-preview') > 0 
        || url.indexOf('live.') > 0
        || url.indexOf('.builder.') > 0);
};
const googleTagManager = (dataMap,type) => {
    window.dataLayer = window.dataLayer || [];
    let obj = {};
    if(type == 'view_item_list'){
        obj = {
            event: 'view_item_list',
            ecommerce: {
                items: dataMap.items
            }
        }
    }else if(type == 'select_item'){
        obj = {
            event: 'select_item',
            ecommerce: {
                items: dataMap.items
            }
        }
    }else if(type == 'view_item'){
        obj = {
            event: 'view_item',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                value : dataMap.value,
                items: dataMap.items
            }
        }
    }else if(type == 'add_to_cart'){
        obj = {
            event: 'add_to_cart',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                value : dataMap.value,
                items: dataMap.items
            }
        }
    }else if(type == 'remove_from_cart'){
        obj = {
            event: 'remove_from_cart',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                value : dataMap.value,
                items: dataMap.items
            }
        }
    }else if(type == 'view_cart'){
        obj = {
            event: 'view_cart',
            ecommerce: {
                items: dataMap.items
            }
        }
    }else if(type == 'begin_checkout'){
        obj = {
            event: 'begin_checkout',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                value : dataMap.value,
                items: dataMap.items
            }
        }
    }else if(type == 'add_payment_details'){
        obj = {
            event: 'add_payment_details',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                payment_type : dataMap.paymentType,
                value : dataMap.value,
                items: dataMap.items
            }
        }
    }else if(type == 'add_shipping_info'){
        obj = {
            event: 'add_shipping_info',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                shipping_tier : dataMap.shippingTier,
                value : dataMap.value,
                items: dataMap.items
            }
        }
    }else if(type == 'view_item_list_order'){
        obj = {
            event: 'purchase',
            ecommerce: {
                currency : dataMap.currencyISOCode,
                transaction_id : dataMap.transactionId,
                value : dataMap.value,
                shipping: dataMap.shippingAmount,
                tax: dataMap.taxAmount,
                coupon: dataMap.coupon,
                items: dataMap.items
            }
        }
    }
    window.dataLayer.push(obj);
};
const convertWebCartItemstoGTItems = (cartItems) => {
    let items = [];
    for(let i = 0; i < cartItems.length; i++) {
        let cartItem = cartItems[i];
        let item = {
            item_id: cartItem.Id,
            item_name: cartItem.Name,
            index: i,
            price: cartItem.SalesPrice,
            quantity: cartItem.Quantity
        };
        items.push(item);
    }
    return items;
};

export {isInSitePreview,consoleLogging , applicationLogging, showLog , getUrlVars, setCookie, getCookie};

//garora@rafter.oe - 24 Sep 2024 - reusable method to calculate stars for ratings
export function calculateReviewStars(value){
    const fullStars = Math.floor(value);
    const decimalPart = value % 1;
    
    // Calculate half star based on the specified range
    const halfStar = (decimalPart > 0) ? 1 : 0; 
    const emptyStars = 5 - fullStars - halfStar;

    let stars = [];

    for (let i = 0; i < fullStars; i++) {
        stars.push({ key: `full-${i}`, class: 'star full' });
    }

    if (halfStar) {
        stars.push({ key: `half`, class: 'star half' });
    }

    for (let i = 0; i < emptyStars; i++) {
        stars.push({ key: `empty-${i}`, class: 'star empty' });
    }

    return stars;
}
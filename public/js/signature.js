function Clear() {
    $.get('/app/Signature/clear');
    return false;
}
function Capture() {
    $.get('/app/Signature/capture');
    return false;
}

function pageY(elem) {
    return elem.offsetParent ? (elem.offsetTop + pageY(elem.offsetParent)) : elem.offsetTop;
}

function pageX(elem) {
    return elem.offsetParent ? (elem.offsetLeft + pageX(elem.offsetParent)) : elem.offsetLeft;
}

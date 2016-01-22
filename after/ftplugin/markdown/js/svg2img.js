
(function() {
    var svg2Img = window.svg2Img === 'true' || /svg2img/i.test(window.location.hash);
    if (!svg2Img) {
        return;
    }

    window.setTimeout(function () {
        var svgElements = document.querySelectorAll('svg'),
            index = 0,
            renderSvgAsImg = function (svg){
                var xml = svg.outerHTML;
                var tempImg = new Image();
                tempImg.src = 'data:image/svg+xml,' + escape(xml);
                tempImg.onload = function() {
                    tempImg.onload = null;
                    var canvas = document.createElement('canvas'),
                        context,
                        newImg;

                    canvas.width = tempImg.width;
                    canvas.height = tempImg.height;

                    context = canvas.getContext('2d');
                    context.drawImage(tempImg, 0, 0);

                    newImg = new Image();
                    newImg.onload = function () {
                        newImg.onload = null;
                        svg.parentNode.replaceChild(newImg, svg);
                    };
                    newImg.src = canvas.toDataURL();
                    tempImg = null;
                };
            };

        for (index = 0; index < svgElements.length; index++) {
            renderSvgAsImg(svgElements[index]);
        }
    }, 1000);

})();


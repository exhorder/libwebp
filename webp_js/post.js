var WebpToSDL = Module.cwrap('WebpToSDL', 'number', ['array', 'number']);

return function webpToCanvas(data, length, canvas) {
    if (canvas) {
        canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
    }
    canvas = canvas || document.createElement('canvas');
    Module.canvas = canvas;
    var ret = WebpToSDL(data, length || data.length);
    Module.canvas = null;
    return ret ? canvas : false;
};
}));

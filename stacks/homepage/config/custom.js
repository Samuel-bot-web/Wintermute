// Sanfter Parallax-Effekt: Hintergrund bewegt sich langsamer als der Inhalt beim Scrollen
(function () {
  var maxOffset = 60;   // maximale Verschiebung in px, erreicht ganz unten auf der Seite

  function onScroll(scrollContainer, bg) {
    var maxScroll = scrollContainer.scrollHeight - scrollContainer.clientHeight;
    var progress = maxScroll > 0 ? scrollContainer.scrollTop / maxScroll : 0;
    var offset = progress * maxOffset;
    bg.style.transform = "translateY(-" + offset + "px)";
  }

  function initParallax() {
    var bg = document.getElementById("background");
    var scrollContainer = document.getElementById("inner_wrapper");
    if (!bg || !scrollContainer) return false;

    scrollContainer.addEventListener("scroll", function () {
      window.requestAnimationFrame(function () {
        onScroll(scrollContainer, bg);
      });
    });
    return true;
  }

  // Homepage rendert client-seitig (Next.js), daher kurz auf das DOM warten
  var tries = 0;
  var interval = setInterval(function () {
    if (initParallax() || tries > 50) {
      clearInterval(interval);
    }
    tries++;
  }, 200);
})();

// Automatische Akzentfarbe passend zum aktuellen Hintergrundbild
(function () {
  // Ziel-Helligkeit pro "Tailwind-Stufe", angelehnt an das übliche 50-900 Schema
  var SHADE_LIGHTNESS = {
    50: 95, 100: 90, 200: 82, 300: 72, 400: 62,
    500: 52, 600: 43, 700: 35, 800: 27, 900: 19
  };
  var MIN_SATURATION = 35; // verhindert zu "matschige"/graue Akzentfarben

  function rgbToHsl(r, g, b) {
    r /= 255; g /= 255; b /= 255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b);
    var h, s, l = (max + min) / 2;
    if (max === min) {
      h = s = 0;
    } else {
      var d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r: h = (g - b) / d + (g < b ? 6 : 0); break;
        case g: h = (b - r) / d + 2; break;
        case b: h = (r - g) / d + 4; break;
      }
      h /= 6;
    }
    return [h * 360, s * 100, l * 100];
  }

  function hslToRgb(h, s, l) {
    h /= 360; s /= 100; l /= 100;
    function hue2rgb(p, q, t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }
    var r, g, b;
    if (s === 0) {
      r = g = b = l;
    } else {
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      var p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }
    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
  }

  function extractBackgroundUrl(bg) {
    var img = getComputedStyle(bg).backgroundImage || bg.style.backgroundImage;
    var match = img && img.match(/url\(["']?(.*?)["']?\)/);
    return match ? match[1] : null;
  }

  function applyPaletteFromColor(r, g, b) {
    var hsl = rgbToHsl(r, g, b);
    var hue = hsl[0];
    var sat = Math.max(hsl[1], MIN_SATURATION);
    var root = document.documentElement;

    Object.keys(SHADE_LIGHTNESS).forEach(function (shade) {
      var rgb = hslToRgb(hue, sat, SHADE_LIGHTNESS[shade]);
      root.style.setProperty("--color-" + shade, rgb.join(" "));
    });
  }

  function extractAverageColor(imageEl) {
    var canvas = document.createElement("canvas");
    var size = 16;
    canvas.width = size;
    canvas.height = size;
    var ctx = canvas.getContext("2d");
    ctx.drawImage(imageEl, 0, 0, size, size);

    var data;
    try {
      data = ctx.getImageData(0, 0, size, size).data;
    } catch (e) {
      // CORS-Problem oder Bild von anderer Domain ohne Freigabe - einfach abbrechen
      return null;
    }

    var r = 0, g = 0, b = 0, count = 0;
    for (var i = 0; i < data.length; i += 4) {
      r += data[i];
      g += data[i + 1];
      b += data[i + 2];
      count++;
    }
    return [Math.round(r / count), Math.round(g / count), Math.round(b / count)];
  }

  function initAdaptiveColor() {
    var bg = document.getElementById("background");
    if (!bg) return false;

    var url = extractBackgroundUrl(bg);
    if (!url) return false;

    var img = new Image();
    img.crossOrigin = "anonymous";
    img.onload = function () {
      var avg = extractAverageColor(img);
      if (avg) applyPaletteFromColor(avg[0], avg[1], avg[2]);
    };
    img.onerror = function () {
      // Bild nicht ladbar - Standardfarbe (settings.yaml "color") bleibt einfach aktiv
    };
    img.src = url;
    return true;
  }

  var tries2 = 0;
  var interval2 = setInterval(function () {
    if (initAdaptiveColor() || tries2 > 50) {
      clearInterval(interval2);
    }
    tries2++;
  }, 200);
})();

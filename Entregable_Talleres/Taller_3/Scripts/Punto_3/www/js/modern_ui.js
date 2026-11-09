/**
 * ==============================================================================
 * Controlador JavaScript Institucional - MathJax Dinámico y Redimensionamiento
 * Taller 3 · Grupo 10 | Facultad de Economía, Universidad de los Andes
 * ==============================================================================
 */

// 1. Re-procesar ecuaciones LaTeX con MathJax tras actualizaciones reactivas de Shiny
function renderizarMathJax() {
  if (window.MathJax) {
    if (window.MathJax.Hub && typeof window.MathJax.Hub.Queue === "function") {
      window.MathJax.Hub.Queue(["Typeset", window.MathJax.Hub]);
    } else if (typeof window.MathJax.typesetPromise === "function") {
      window.MathJax.typesetPromise().catch(function() {});
    }
  }
}

// 2. Ajuste responsivo de mapas Leaflet y gráficos Plotly
function recalcularDimensionesWidgets() {
  window.dispatchEvent(new Event("resize"));

  if (window.HTMLWidgets && window.HTMLWidgets.find) {
    const leafletWidgets = document.querySelectorAll(".leaflet-container");
    leafletWidgets.forEach(function(el) {
      try {
        const widgetObj = window.HTMLWidgets.find("#" + el.id);
        if (widgetObj && typeof widgetObj.getMap === "function") {
          const map = widgetObj.getMap();
          if (map && typeof map.invalidateSize === "function") {
            map.invalidateSize();
          }
        }
      } catch (err) {}
    });
  }

  const plotlyPlots = document.querySelectorAll(".js-plotly-plot");
  plotlyPlots.forEach(function(plot) {
    if (window.Plotly && window.Plotly.Plots && typeof window.Plotly.Plots.resize === "function") {
      try {
        window.Plotly.Plots.resize(plot);
      } catch (err) {}
    }
  });
}

// Función debounce para eventos de alta frecuencia
function debounce(func, wait) {
  let timeout;
  return function(...args) {
    clearTimeout(timeout);
    timeout = setTimeout(function() {
      func.apply(null, args);
    }, wait);
  };
}

// Escuchar actualizaciones de salidas dinámicas en Shiny (renderUI / textOutput)
document.addEventListener("DOMContentLoaded", function() {
  setTimeout(function() {
    renderizarMathJax();
    recalcularDimensionesWidgets();
  }, 350);

  if (window.jQuery) {
    window.jQuery(document).on("shiny:value", debounce(function() {
      setTimeout(renderizarMathJax, 60);
    }, 80));

    window.jQuery(document).on("shown.bs.tab shown.bs.collapse", function() {
      setTimeout(function() {
        renderizarMathJax();
        recalcularDimensionesWidgets();
      }, 120);
    });
  }
});

window.addEventListener("resize", debounce(recalcularDimensionesWidgets, 200));

document.addEventListener("bslib.sidebar.toggle", function() {
  setTimeout(recalcularDimensionesWidgets, 250);
});

window.addEventListener("orientationchange", function() {
  setTimeout(recalcularDimensionesWidgets, 300);
});

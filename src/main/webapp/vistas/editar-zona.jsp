<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    // Escapa caracteres especiales para mostrar texto de la BD dentro del HTML
    private String esc(Object valor) {
        if (valor == null) return "";
        return valor.toString()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
%>
<%
    // La zona la carga EditarZonaSv (doGet) antes de llegar acá
    java.util.Map<String, Object> zona = (java.util.Map<String, Object>) request.getAttribute("zona");
    if (zona == null) {
        response.sendRedirect(request.getContextPath() + "/LeerMapaSv");
        return;
    }
    String riesgoActual = zona.get("riesgo") != null ? zona.get("riesgo").toString() : "Normal";
    String[] riesgos = { "Normal", "Atención", "Alerta", "Evacuación" };
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar dispositivo | HIDROSAFE</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">

    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/estilos/leaflet.css" />

    <!-- CSS del Proyecto -->
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/estilos/estilo.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/estilos/dispositivo.css">
</head>
<body>

    <header class="navbar">
        <div class="brand">
            <span class="brand-dot"></span>
            <h1>HIDROSAFE</h1>
            <span class="location-tag">| Editar dispositivo</span>
        </div>
    </header>

    <main class="container">

        <a class="link-volver" href="${pageContext.request.contextPath}/LeerMapaSv">← Volver al mapa</a>

        <div class="editar-layout">

            <!-- Formulario: envía vía POST a EditarZonaSv -->
            <section class="card">
                <h2>Datos del dispositivo</h2>

                <form class="form-editar" action="${pageContext.request.contextPath}/EditarZonaSv" method="POST">
                    <input type="hidden" name="id" value="<%= zona.get("id") %>">

                    <label class="campo">
                        Nombre
                        <input type="text" name="nombre_zona" required class="search-input"
                               value="<%= esc(zona.get("nombre")) %>">
                    </label>

                    <label class="campo">
                        Ubicación
                        <input type="text" name="ubicacion" class="search-input"
                               value="<%= esc(zona.get("ubicacion")) %>">
                    </label>

                    <label class="campo">
                        Nivel de riesgo
                        <select name="nivel_riesgo" class="select-field">
                            <% for (String r : riesgos) { %>
                                <option value="<%= r %>" <%= r.equalsIgnoreCase(riesgoActual) ? "selected" : "" %>><%= r %></option>
                            <% } %>
                        </select>
                    </label>

                    <div class="campo-doble">
                        <label class="campo">
                            Latitud
                            <input type="number" step="any" name="latitud" required class="search-input"
                                   value="<%= zona.get("latitud") %>">
                        </label>
                        <label class="campo">
                            Longitud
                            <input type="number" step="any" name="longitud" required class="search-input"
                                   value="<%= zona.get("longitud") %>">
                        </label>
                    </div>

                    <div class="botones-editar">
                        <button type="submit" class="search-button">Guardar cambios</button>
                        <a class="btn-cancelar" href="${pageContext.request.contextPath}/LeerMapaSv">Cancelar</a>
                    </div>
                </form>
            </section>

            <!-- Mapa chico para reubicar el punto -->
            <section class="card">
                <h2>Ubicación en el mapa</h2>
                <p class="ayuda-mapa">Hacé clic en el mapa para mover el dispositivo.</p>
                <div id="mapa-editar"></div>
            </section>

        </div>
    </main>

    <!-- JS de Leaflet -->
    <script src="${pageContext.request.contextPath}/js/leaflet.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const latInput = document.querySelector('input[name="latitud"]');
            const lngInput = document.querySelector('input[name="longitud"]');

            const lat = parseFloat(latInput.value) || -34.6625;
            const lng = parseFloat(lngInput.value) || -58.4485;

            const mapa = L.map('mapa-editar').setView([lat, lng], 16);

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '© OpenStreetMap'
            }).addTo(mapa);

            // Punto actual del dispositivo
            const punto = L.circleMarker([lat, lng], {
                radius: 9,
                fillColor: "#e63946",
                color: "#ffffff",
                weight: 2,
                fillOpacity: 0.95
            }).addTo(mapa);

            // Clic en el mapa: mueve el punto y actualiza los inputs
            mapa.on('click', function (e) {
                punto.setLatLng(e.latlng);
                latInput.value = e.latlng.lat.toFixed(6);
                lngInput.value = e.latlng.lng.toFixed(6);
            });

            // Si se escriben las coordenadas a mano, también se mueve el punto
            function moverDesdeInputs() {
                const nuevaLat = parseFloat(latInput.value);
                const nuevaLng = parseFloat(lngInput.value);
                if (isFinite(nuevaLat) && isFinite(nuevaLng)) {
                    punto.setLatLng([nuevaLat, nuevaLng]);
                    mapa.panTo([nuevaLat, nuevaLng]);
                }
            }
            latInput.addEventListener('change', moverDesdeInputs);
            lngInput.addEventListener('change', moverDesdeInputs);

            setTimeout(function () { mapa.invalidateSize(); }, 300);
        });
    </script>
</body>
</html>
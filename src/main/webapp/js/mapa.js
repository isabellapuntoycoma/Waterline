document.addEventListener('DOMContentLoaded', function () {
    // Coordenadas iniciales (Villa Soldati)
    const centroInicial = [-34.6625, -58.4485];

    // Inicializar el mapa
    const map = L.map('map').setView(centroInicial, 15);

    // Cargar capa de OpenStreetMap
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '© OpenStreetMap'
    }).addTo(map);

    // Marcador temporal para mostrar dónde se hizo clic
    let tempMarker = null;

    // Obtener los inputs del formulario del header
    const latInput = document.querySelector('input[name="latitud"]');
    const lngInput = document.querySelector('input[name="longitud"]');

    // Evento al hacer clic sobre el mapa
    map.on('click', function (e) {
        const lat = e.latlng.lat.toFixed(6);
        const lng = e.latlng.lng.toFixed(6);

        // 1. Rellenar los inputs del formulario
        if (latInput && lngInput) {
            latInput.value = lat;
            lngInput.value = lng;
        }

        // 2. Mover o crear el marcador visual temporal (icono estándar)
        if (tempMarker) {
            tempMarker.setLatLng(e.latlng);
        } else {
            tempMarker = L.marker(e.latlng).addTo(map);
        }

        tempMarker.bindPopup(`<b>Punto seleccionado</b><br>Lat: ${lat}<br>Lng: ${lng}`).openPopup();
    });

    // 3. Dibujar en el mapa las zonas registradas en MySQL (Puntos Rojos Distintivos)
    const limites = [];   // acá juntamos las coordenadas para encuadrar el mapa

    if (window.puntosGuardados && Array.isArray(window.puntosGuardados)) {
        console.table(window.puntosGuardados);   // ver lat/lng reales en la consola (F12)

        window.puntosGuardados.forEach(function (zona) {
            let lat = Number(zona.lat);
            let lng = Number(zona.lng);

            if (!isFinite(lat) || !isFinite(lng) || lat === 0 || lng === 0) {
                console.warn('Zona sin coordenadas válidas, no se dibuja:', zona);
                return;
            }

            // En CABA la latitud es ~ -34 y la longitud ~ -58.
            // Si vienen al revés (lat ~ -58), las damos vuelta y avisamos.
            if (lat < -50 && lng > -50) {
                console.warn('Lat/Lng invertidas en la BD para "' + zona.nombre + '". Se corrigen al dibujar.');
                const aux = lat; lat = lng; lng = aux;
            }

            limites.push([lat, lng]);

            // Círculo rojo de Leaflet para dispositivos guardados
            const redCircle = L.circleMarker([lat, lng], {
                radius: 8,             // Tamaño del punto
                fillColor: "#e63946",  // Rojo
                color: "#ffffff",      // Borde blanco
                weight: 2,             // Grosor de borde
                opacity: 1,
                fillOpacity: 0.95
            }).addTo(map);

            // Popup descriptivo al hacer clic en el punto rojo
            const popupContent = `
                <div style="font-family: inherit;">
                    <strong style="color: #2F4156; font-size: 1em;">${zona.nombre}</strong><br>
                    <span style="color: #555;">📍 ${zona.ubicacion}</span><br>
                    <small style="color: #888;">Nivel: <b>${zona.riesgo}</b></small>
                </div>
            `;

            redCircle.bindPopup(popupContent);
        });
    }

    // Ajuste de renderizado de Leaflet y encuadre sobre los puntos guardados
    setTimeout(function () {
        map.invalidateSize();
        if (limites.length > 0) {
            map.fitBounds(limites, { padding: [40, 40], maxZoom: 16 });
        }
    }, 300);
});
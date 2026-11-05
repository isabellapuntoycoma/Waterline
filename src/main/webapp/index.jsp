<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HIDROSAFE | Villa Soldati</title>
    
    <!-- Google Fonts: Lora -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
    
    <!-- Leaflet CSS (Mapa) -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <!-- Ruta absoluta dinámica de Tomcat para el CSS -->
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/estilos/estilo.css">
</head>
<body>

    <header class="navbar">
        <div class="brand">
            <span class="brand-dot"></span>
            <h1>HIDROSAFE</h1>
            <span class="location-tag">| Villa Soldati</span>
        </div>
        <form class="search-box" action="${pageContext.request.contextPath}/MapaServlet" method="GET">
            <input type="text" name="buscar" placeholder="Buscar calle o barrio..." class="search-input">
            <button type="submit" class="search-button">Buscar</button>
        </form>
    </header>

    <main class="container">

        <section class="top-bar">
            <div class="station-picker">
                <label for="station">Punto de Medición:</label>
                <select id="station" class="select-field">
                    <option value="fatima">Estación Instituto Fátima (Villa Soldati)</option>
                    <option value="carrillo">Estación Ramón Carrillo</option>
                    <option value="roca">Estación Av. Coronel Roca</option>
                </select>
            </div>
            <div class="live-status">
                <span class="pulse-dot"></span>
                <span>Sensor en tiempo real | Actualizado: 11:34 hs</span>
            </div>
        </section>

        <section class="banner-alert">
            <div class="alert-symbol">⚠️</div>
            <div>
                <strong>Precaución: Acumulación de agua en zona baja</strong>
                <p>Lluvia constante de 25 mm/h. Se registran 18 cm de agua sobre calzada en la intersección de Av. Coronel Roca y Escalada.</p>
            </div>
        </section>

        <p class="subtitle">Proyecto comunitario para la prevención y monitoreo temprano de anegamientos en la Comuna 8.</p>

        <!-- Layout con mapa agrandado -->
        <div class="dashboard-layout">
            
            <!-- Columna Izquierda -->
            <div class="side-panel">
                <div class="card">
                    <h2>Lluvia Actual</h2>
                    <div class="data-value">25,0 <small>mm/h</small></div>
                    <span class="badge warning">Moderada / Alta</span>
                </div>

                <div class="card">
                    <h2>Ráfagas de Viento</h2>
                    <div class="data-value">33,0 <small>km/h</small></div>
                    <span class="badge info">Viento Sur</span>
                </div>

                <div class="card">
                    <h2>Absorción del Terreno</h2>
                    <div class="data-value">85 %</div>
                    <span class="badge danger">Saturado</span>
                </div>
            </div>

            <!-- Mapa Central Ampliado -->
            <div class="map-container">
                <div class="card map-card">
                    <h2>Mapa de Monitoreo Territorial</h2>
                    <div id="map"></div>
                </div>
            </div>

            <!-- Columna Derecha -->
            <div class="side-panel">
                <div class="card">
                    <h2>Nivel de Agua en Calle</h2>
                    <div class="data-value">18 <small>cm</small></div>
                    <span class="badge warning">Altura Cordón</span>
                </div>

                <div class="card">
                    <h2>Estado del Sumidero</h2>
                    <div class="data-value text-medium">Obstruido</div>
                    <span class="badge danger">Requiere Limpieza</span>
                </div>

                <div class="card alert-highlight">
                    <h2>Nivel de Alerta</h2>
                    <div class="data-value text-danger">Riesgo Alto</div>
                    <span class="badge danger">Monitoreo Activo</span>
                </div>
            </div>

        </div>

        <!-- Parte Inferior -->
        <div class="bottom-layout">
            <section class="card">
                <h3>Estados de Emergencia</h3>
                <div class="legend">
                    <span><i class="dot normal"></i> Normal</span>
                    <span><i class="dot atencion"></i> Atención</span>
                    <span><i class="dot alerta"></i> Alerta</span>
                    <span><i class="dot evacuacion"></i> Evacuación</span>
                </div>
                <div class="threshold-grid">
                    <div>> 20 mm/h <small>Precipitación</small></div>
                    <div>> 30 km/h <small>Vientos</small></div>
                    <div>> 80 % <small>Saturación</small></div>
                </div>
            </section>

            <section class="card">
                <h3>Avisos Recientes</h3>
                <div class="notice">
                    <strong>Mariano Acosta y Cruz</strong>
                    <p>Boca de tormenta juntando hojas y basura. El agua empieza a acumularse lentamente en la esquina.</p>
                    <small>Reportado por un vecino hace 20 min</small>
                </div>
            </section>
        </div>

    </main>

    <!-- JS de Leaflet -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    
    <!-- Script para renderizar el mapa -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Coordenadas de Villa Soldati
            const latitud = -34.6625;
            const longitud = -58.4485;

            // Inicializar el mapa
            const map = L.map('map').setView([latitud, longitud], 14);

            // Cargar capas del mapa de OpenStreetMap
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '© OpenStreetMap'
            }).addTo(map);

            // Agregar el marcador
            const marker = L.marker([latitud, longitud]).addTo(map);
            marker.bindPopup('<b>Estación Instituto Fátima</b><br>Nivel de agua: 18 cm').openPopup();

            // Ajuste para evitar que quede gris al cargar
            setTimeout(function() {
                map.invalidateSize();
            }, 300);
        });
    </script>
</body>
</html>
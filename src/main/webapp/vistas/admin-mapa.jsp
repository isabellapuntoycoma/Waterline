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
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HIDROSAFE | Villa Soldati</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
    
    <!-- Leaflet CSS (local, dentro del proyecto) -->
<!-- En el <head> -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/estilos/leaflet.css" />

<!-- Antes de window.puntosGuardados --> 
    <!-- CSS del Proyecto -->
       
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/estilos/estilo.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/estilos/dispositivo.css">
</head>
<body>

    <header class="navbar">
        <div class="brand">
            <span class="brand-dot"></span>
            <h1>HIDROSAFE</h1>
            <span class="location-tag">| Villa Soldati</span>
        </div>
        
        <!-- Formulario HTML tradicional enviando vía POST a MapaServlet -->
        <form class="search-box" action="${pageContext.request.contextPath}/MapaServlet" method="POST">
            <input type="text" name="nombre_zona" placeholder="Nombre (ej: Estación Fátima)" required class="search-input">
            <input type="text" name="ubicacion" placeholder="Ubicación (ej: Av. Roca)" class="search-input">
            <input type="number" step="any" name="latitud" placeholder="Latitud" required class="search-input" style="width: 110px;">
            <input type="number" step="any" name="longitud" placeholder="Longitud" required class="search-input" style="width: 110px;">
            <button type="submit" class="search-button">+ Dispositivo</button>
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

        <%
            // Mensaje después de editar / eliminar (viene como ?msg=... desde los servlets)
            String msg = request.getParameter("msg");
            if ("editado".equals(msg)) {
        %>
            <div class="mensaje mensaje-ok">✔ Dispositivo actualizado correctamente.</div>
        <%  } else if ("eliminado".equals(msg)) { %>
            <div class="mensaje mensaje-ok">✔ Dispositivo eliminado.</div>
        <%  } else if ("error".equals(msg) || "noencontrado".equals(msg)) { %>
            <div class="mensaje mensaje-error">No se pudo completar la operación. Revisá la consola del servidor.</div>
        <%  } %>

        <section class="banner-alert">
            <div class="alert-symbol">⚠️</div>
            <div>
                <strong>Precaución: Acumulación de agua en zona baja</strong>
                <p>Lluvia constante de 25 mm/h. Se registran 18 cm de agua sobre calzada en la intersección de Av. Coronel Roca y Escalada.</p>
            </div>
        </section>

        <p class="subtitle">Proyecto comunitario para la prevención y monitoreo temprano de anegamientos en la Comuna 8.</p>

        <div class="dashboard-layout">
            
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

            <div class="map-container">
                <div class="card map-card">
                    <h2>Mapa de Monitoreo Territorial</h2>
                    <div id="map" style="width: 100%; height: 480px;"></div>
                </div>
            </div>

            <div class="side-panel">
                <div class="card">
                    <h2>Nivel de Agua en Calle</h2>
                    <div id="nivel-agua" clafss="data-value">18 <small>cm</small></div>
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

        <!-- ============ LISTADO DE DISPOSITIVOS (EDITAR / ELIMINAR) ============ -->
        <section class="card tabla-card">
            <h3>Dispositivos registrados</h3>
            <%
                java.util.List<java.util.Map<String, Object>> listado = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("zonas");
                if (listado == null || listado.isEmpty()) {
            %>
                <p class="tabla-vacia">Todavía no hay dispositivos cargados.</p>
            <%
                } else {
            %>
            <div class="tabla-scroll">
                <table class="tabla-zonas">
                    <thead>
                        <tr>
                            <th>Nombre</th>
                            <th>Ubicación</th>
                            <th>Riesgo</th>
                            <th>Latitud</th>
                            <th>Longitud</th>
                            <th class="col-acciones">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for (java.util.Map<String, Object> zona : listado) {
                    %>
                        <tr>
                            <td><%= esc(zona.get("nombre")) %></td>
                            <td><%= esc(zona.get("ubicacion")) %></td>
                            <td><%= esc(zona.get("riesgo")) %></td>
                            <td><%= esc(zona.get("latitud")) %></td>
                            <td><%= esc(zona.get("longitud")) %></td>
                            <td class="col-acciones">
                                <a class="btn-editar" href="${pageContext.request.contextPath}/EditarZonaSv?id=<%= zona.get("id") %>">Editar</a>

                                <form action="${pageContext.request.contextPath}/EliminarZonaSv" method="POST" class="form-eliminar"
                                      onsubmit="return confirm('¿Eliminar el dispositivo &quot;<%= esc(zona.get("nombre")).replace("'", "\\'") %>&quot;?');">
                                    <input type="hidden" name="id" value="<%= zona.get("id") %>">
                                    <button type="submit" class="btn-eliminar">Eliminar</button>
                                </form>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
            <%
                }
            %>
        </section>

    </main>

   <!-- En el <head> -->

<!-- Antes de window.puntosGuardados -->
<script src="${pageContext.request.contextPath}/js/leaflet.js"></script>
    
    <!-- Generación del Array JS leyendo del request despachado por LeerMapaSv -->
    <script>
        window.puntosGuardados = [
            <%
                java.util.List<java.util.Map<String, Object>> zonas = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("zonas");
                if (zonas != null && !zonas.isEmpty()) {
                    for (int i = 0; i < zonas.size(); i++) {
                        java.util.Map<String, Object> z = zonas.get(i);
                        
                        Object latObj = z.get("latitud");
                        Object lngObj = z.get("longitud");
                        
                        if (latObj != null && lngObj != null) {
                            String nombre = z.get("nombre") != null ? z.get("nombre").toString().replace("\"", "\\\"").replace("\r", "").replace("\n", "") : "Dispositivo";
                            String ubicacion = z.get("ubicacion") != null ? z.get("ubicacion").toString().replace("\"", "\\\"").replace("\r", "").replace("\n", "") : "Sin ubicación";
                            String riesgo = z.get("riesgo") != null ? z.get("riesgo").toString() : "Normal";
            %>
                {
                    id: <%= z.get("id") %>,
                    nombre: "<%= nombre %>",
                    ubicacion: "<%= ubicacion %>",
                    riesgo: "<%= riesgo %>",
                    lat: parseFloat("<%= latObj %>"),
                    lng: parseFloat("<%= lngObj %>")
                }<%= (i < zonas.size() - 1) ? "," : "" %>
            <%
                        }
                    }
                }
            %>
        ];

        // Muestra en la consola la estructura generada para depurar
        console.log("Puntos inyectados a JS:", window.puntosGuardados);
    </script>

    <!-- JS Principal del mapa (el ?v= evita que el navegador use una versión vieja en caché) -->
    <script src="${pageContext.request.contextPath}/js/mapa.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
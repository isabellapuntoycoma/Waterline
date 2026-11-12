package com.app;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * GET  /EditarZonaSv?id=5  -> busca la zona y muestra el formulario (editar-zona.jsp)
 * POST /EditarZonaSv       -> guarda los cambios y vuelve al mapa
 */
@WebServlet("/EditarZonaSv")
public class EditarZonaSv extends HttpServlet {

    private static final long serialVersionUID = 1L;
    
 // Solo números: 12, -34.66, 58.4485 (sin letras)
    private static final String ES_NUMERO = "-?\\d+(\\.\\d+)?";

    // Devuelve true si el texto es null, está vacío o tiene solo espacios
    private boolean estaVacio(String texto) {
        return texto == null || texto.trim().isEmpty();
    }
    // ---------- Mostrar el formulario con los datos actuales ----------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/LeerMapaSv");
            return;
        }

        String sql = "SELECT id, nombre_zona, ubicacion, latitud, longitud, nivel_riesgo FROM zonas WHERE id = ?";

        try (Connection conn = ConexionBD.obtenerConexion();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> zona = new HashMap<>();
                    zona.put("id", rs.getInt("id"));
                    zona.put("nombre", rs.getString("nombre_zona"));
                    zona.put("ubicacion", rs.getString("ubicacion"));
                    zona.put("latitud", rs.getDouble("latitud"));
                    zona.put("longitud", rs.getDouble("longitud"));
                    zona.put("riesgo", rs.getString("nivel_riesgo"));

                    request.setAttribute("zona", zona);
                    request.getRequestDispatcher("/vistas/editar-zona.jsp").forward(request, response);
                    return;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Si no existe la zona o falló la BD, volvemos al mapa
        response.sendRedirect(request.getContextPath() + "/LeerMapaSv?msg=noencontrado");
    }

    // ---------- Guardar los cambios ----------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idStr     = request.getParameter("id");
        String nombre    = request.getParameter("nombre_zona");
        String ubicacion = request.getParameter("ubicacion");
        String riesgo    = request.getParameter("nivel_riesgo");
        String latStr    = request.getParameter("latitud");
        String lngStr    = request.getParameter("longitud");
     // El id viene de un campo oculto: si está mal no hay nada para editar
        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/LeerMapaSv?msg=error");
            return;
        }

        // =================== VALIDACIONES ===================
        List<String> errores = new ArrayList<>();

        // Nombre: no vacío y no puede ser un número
        if (estaVacio(nombre)) {
            errores.add("El nombre no puede estar vacío.");
        } else if (nombre.trim().replace(",", ".").matches(ES_NUMERO)) {
            errores.add("El nombre no puede ser un número.");
        }

        // Ubicación: no vacía
        if (estaVacio(ubicacion)) {
            errores.add("La ubicación no puede estar vacía.");
        }

        // Latitud: no vacía y sin letras
        boolean latitudValida = false;
        if (estaVacio(latStr)) {
            errores.add("La latitud no puede estar vacía.");
        } else if (!latStr.trim().matches(ES_NUMERO)) {
            errores.add("La latitud debe ser un número, sin letras.");
        } else {
            latitudValida = true;
        }

        // Longitud: no vacía y sin letras
        boolean longitudValida = false;
        if (estaVacio(lngStr)) {
            errores.add("La longitud no puede estar vacía.");
        } else if (!lngStr.trim().matches(ES_NUMERO)) {
            errores.add("La longitud debe ser un número, sin letras.");
        } else {
            longitudValida = true;
        }

        // Si hay algún error: NO se guarda y se vuelve al formulario con los mensajes
        if (!errores.isEmpty()) {
            Map<String, Object> zona = new HashMap<>();
            zona.put("id", id);
            zona.put("nombre", nombre != null ? nombre : "");
            zona.put("ubicacion", ubicacion != null ? ubicacion : "");
            zona.put("riesgo", riesgo != null ? riesgo : "Normal");
            zona.put("latitud", latitudValida ? latStr.trim() : "");
            zona.put("longitud", longitudValida ? lngStr.trim() : "");

            request.setAttribute("zona", zona);
            request.setAttribute("errores", errores);
            request.getRequestDispatcher("/vistas/editar-zona.jsp").forward(request, response);
            return; // corta acá: no llega al UPDATE
        }
        // ================= FIN VALIDACIONES =================

        String msg = "error";

        try {
            
            double latitud = Double.parseDouble(latStr);
            double longitud = Double.parseDouble(lngStr);

            String sql = "UPDATE zonas SET nombre_zona = ?, ubicacion = ?, nivel_riesgo = ?, latitud = ?, longitud = ? WHERE id = ?";

            try (Connection conn = ConexionBD.obtenerConexion();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, nombre);
                ps.setString(2, ubicacion != null ? ubicacion : "");
                ps.setString(3, riesgo != null ? riesgo : "Normal");
                ps.setDouble(4, latitud);
                ps.setDouble(5, longitud);
                ps.setInt(6, id);

                int filas = ps.executeUpdate();
                System.out.println("Zona " + id + " editada. Filas afectadas: " + filas);
                if (filas > 0) msg = "editado";
            }

        } catch (NumberFormatException | NullPointerException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/LeerMapaSv?msg=" + msg);
    }
}
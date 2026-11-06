package com.app;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/MapaServlet")
public class MapaServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String nombre = request.getParameter("nombre_zona");
        String ubicacion = request.getParameter("ubicacion");
        String latStr = request.getParameter("latitud");
        String lngStr = request.getParameter("longitud");

        if (nombre != null && latStr != null && lngStr != null) {
            try {
                double latitud = Double.parseDouble(latStr);
                double longitud = Double.parseDouble(lngStr);

                String sql = "INSERT INTO zonas (nombre_zona, ubicacion, nivel_riesgo, latitud, longitud) VALUES (?, ?, ?, ?, ?)";

                try (Connection conn = ConexionBD.obtenerConexion();
                     PreparedStatement ps = conn.prepareStatement(sql)) {

                    ps.setString(1, nombre);
                    ps.setString(2, ubicacion != null ? ubicacion : "");
                    ps.setString(3, "Normal");
                    ps.setDouble(4, latitud);
                    ps.setDouble(5, longitud);

                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }

            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // Redirige al Servlet de lectura para refrescar los datos en el mapa
        response.sendRedirect(request.getContextPath() + "/LeerMapaSv");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/LeerMapaSv");
    }
}
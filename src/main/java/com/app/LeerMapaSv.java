package com.app;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/LeerMapaSv")
public class LeerMapaSv extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List listaZonas = new ArrayList<>();

        String sql = "SELECT id, nombre_zona, ubicacion, latitud, longitud, nivel_riesgo FROM zonas";

        try (Connection conn = ConexionBD.obtenerConexion();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> zona = new HashMap<>();
                zona.put("id", rs.getInt("id"));
                zona.put("nombre", rs.getString("nombre_zona"));
                zona.put("ubicacion", rs.getString("ubicacion"));
                zona.put("latitud", rs.getDouble("latitud"));
                zona.put("longitud", rs.getDouble("longitud"));
                zona.put("riesgo", rs.getString("nivel_riesgo"));
                
                listaZonas.add(zona);
            }

            request.setAttribute("zonas", listaZonas);
            
            System.out.println(listaZonas);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorBD", "Error al conectar con la base de datos hidrosafe.");
        }

        // SI TU ARCHIVO ESTÁ EN LA RAÍZ: "/admin-mapa.jsp"
        // SI ESTÁ DENTRO DE VISTAS: "/vistas/admin-mapa.jsp"
        request.getRequestDispatcher("/vistas/admin-mapa.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
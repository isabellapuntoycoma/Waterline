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

/**
 * POST /EliminarZonaSv  (con el parámetro id) -> borra la zona y vuelve al mapa.
 * Se usa POST y no GET para que no se borre nada con solo abrir un link.
 */
@WebServlet("/EliminarZonaSv")
public class EliminarZonaSv extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String msg = "error";

        try {
            int id = Integer.parseInt(request.getParameter("id"));

            String sql = "DELETE FROM zonas WHERE id = ?";

            try (Connection conn = ConexionBD.obtenerConexion();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);
                int filas = ps.executeUpdate();
                System.out.println("Zona " + id + " eliminada. Filas afectadas: " + filas);
                if (filas > 0) msg = "eliminado";
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/LeerMapaSv?msg=" + msg);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Por GET no se elimina nada: solo volvemos al mapa
        response.sendRedirect(request.getContextPath() + "/LeerMapaSv");
    }
}
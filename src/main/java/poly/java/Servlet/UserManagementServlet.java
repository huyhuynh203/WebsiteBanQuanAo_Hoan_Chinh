package poly.java.Servlet;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import poly.java.DAO.UserDAO;
import poly.java.DAO.Impl.UserDAOImpl;
import poly.java.Entity.Role;
import poly.java.Entity.User;
import poly.java.Utils.JpaUtil;

import java.io.IOException;
import java.util.List;

@WebServlet({"/admin/users", "/admin/user/change-role", "/admin/user/delete"})
public class UserManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        String action = req.getParameter("action");

        // 1. Phân lại quyền người dùng (CUSTOMER <-> ADMIN)
        if (uri.contains("/admin/user/change-role") || "change-role".equalsIgnoreCase(action)) {
            String idStr = req.getParameter("id");
            String targetRole = req.getParameter("role");
            if (idStr != null && !idStr.isBlank()) {
                try {
                    int userId = Integer.parseInt(idStr);
                    User user = userDAO.findById(userId);
                    if (user != null) {
                        EntityManager em = JpaUtil.getEntityManager();
                        try {
                            String rName = (targetRole != null && targetRole.equalsIgnoreCase("ADMIN")) ? "ADMIN" : "CUSTOMER";
                            Role role = null;
                            try {
                                role = em.createQuery("SELECT r FROM Role r WHERE UPPER(r.roleName) = :rName", Role.class)
                                        .setParameter("rName", rName.toUpperCase())
                                        .getSingleResult();
                            } catch (Exception ignored) {}

                            if (role == null) {
                                role = new Role();
                                role.setRoleName(rName);
                                em.getTransaction().begin();
                                em.persist(role);
                                em.getTransaction().commit();
                            }

                            user.setRoleID(role);
                            userDAO.update(user);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        } finally {
                            em.close();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        // 2. Xóa người dùng khỏi hệ thống
        if (uri.contains("/admin/user/delete") || "delete".equalsIgnoreCase(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isBlank()) {
                try {
                    int userId = Integer.parseInt(idStr);
                    userDAO.delete(userId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        // 3. Hiển thị danh sách người dùng & Tìm kiếm phân trang
        String keyword = req.getParameter("keyword");
        String email = req.getParameter("email");
        String statusStr = req.getParameter("status");
        String pageStr = req.getParameter("page");

        Boolean status = null;
        if (statusStr != null && !statusStr.isBlank()) {
            status = Boolean.parseBoolean(statusStr);
        }

        int page = 1;
        int pageSize = 10;

        if (pageStr != null && !pageStr.isBlank()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {}
        }

        List<User> userList = userDAO.searchUsers(keyword, email, status, page, pageSize);
        long totalUsers = userDAO.countSearchUsers(keyword, email, status);
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
        if (totalPages < 1) totalPages = 1;

        req.setAttribute("users", userList);
        req.setAttribute("keyword", keyword);
        req.setAttribute("email", email);
        req.setAttribute("status", statusStr);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalUsers", totalUsers);

        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }
}

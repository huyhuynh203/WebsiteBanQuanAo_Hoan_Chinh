package poly.java.Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import poly.java.DAO.AddressDAO;
import poly.java.DAO.UserDAO;
import poly.java.DAO.Impl.AddressDAOImpl;
import poly.java.DAO.Impl.UserDAOImpl;
import poly.java.Entity.Address;
import poly.java.Entity.User;

import java.io.File;
import java.io.IOException;

@WebServlet({"/profile", "/profile/update"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();
    private final AddressDAO addressDAO = new AddressDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        if ("/profile/update".equals(path) || "/profile".equals(path)) {
            String fullname = req.getParameter("fullname");
            String phone = req.getParameter("phone");
            String addressStr = req.getParameter("address");
            String avatar = req.getParameter("avatar");

            if (fullname == null || fullname.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/profile?error=missing_fullname");
                return;
            }

            // Handle file upload from computer
            try {
                Part filePart = req.getPart("avatarFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = extractFileName(filePart);
                    if (fileName != null && !fileName.isBlank()) {
                        String uploadPath = req.getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "avatars";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        String newFileName = "avatar_" + user.getId() + "_" + System.currentTimeMillis() + "_" + fileName;
                        String filePath = uploadPath + File.separator + newFileName;
                        filePart.write(filePath);
                        avatar = "uploads/avatars/" + newFileName;
                    }
                }
            } catch (Exception e) {
                System.err.println("Upload avatar error: " + e.getMessage());
            }

            try {
                user.setFullName(fullname);
                user.setPhone(phone);
                if (avatar != null && !avatar.isBlank()) {
                    user.setAvatar(avatar);
                }

                User updatedUser = userDAO.update(user);
                req.getSession().setAttribute("currentUser", updatedUser);

                if (addressStr != null) {
                    Address defaultAddr = addressDAO.findDefaultAddress(updatedUser.getId());
                    if (defaultAddr != null) {
                        defaultAddr.setAddressDetail(addressStr);
                        defaultAddr.setPhone(phone);
                        defaultAddr.setReceiverName(fullname);
                        addressDAO.update(defaultAddr);
                    } else if (!addressStr.isBlank()) {
                        Address newAddr = new Address();
                        newAddr.setUserID(updatedUser);
                        newAddr.setAddressDetail(addressStr);
                        newAddr.setReceiverName(fullname);
                        newAddr.setPhone(phone);
                        newAddr.setIsDefault(true);
                        addressDAO.create(newAddr);
                    }
                }

                resp.sendRedirect(req.getContextPath() + "/profile?success=update_ok");
                return;

            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/profile?error=update_failed");
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String s : contentDisp.split(";")) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}

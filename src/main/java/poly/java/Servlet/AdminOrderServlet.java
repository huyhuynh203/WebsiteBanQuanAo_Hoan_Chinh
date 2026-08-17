package poly.java.Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import poly.java.DAO.OrderDAO;
import poly.java.DAO.OrderStatusHistoryDAO;
import poly.java.DAO.PaymentDAO;
import poly.java.DAO.Impl.OrderDAOImpl;
import poly.java.DAO.Impl.OrderStatusHistoryDAOImpl;
import poly.java.DAO.Impl.PaymentDAOImpl;
import poly.java.Entity.Order;
import poly.java.Entity.OrderStatusHistory;
import poly.java.Entity.Payment;
import poly.java.Entity.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@WebServlet({"/admin/orders", "/admin/orders/status", "/admin/orders/delete"})
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final OrderStatusHistoryDAO historyDAO = new OrderStatusHistoryDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String action = req.getParameter("action");

        // Cập nhật trạng thái đơn hàng qua GET
        if ("/admin/orders/status".equals(path) || "status".equalsIgnoreCase(action)) {
            updateStatus(req, resp);
            return;
        }

        if ("/admin/orders/delete".equals(path) || "delete".equalsIgnoreCase(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    int orderId = Integer.parseInt(idStr);
                    orderDAO.delete(orderId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        List<Order> orders = orderDAO.findAll();
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/WEB-INF/views/admin/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        updateStatus(req, resp);
    }

    private void updateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isBlank()) {
            orderIdStr = req.getParameter("id");
        }
        String status = req.getParameter("status");
        String paymentStatus = req.getParameter("paymentStatus");

        if (orderIdStr != null && status != null && !status.isBlank()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                Order order = orderDAO.findById(orderId);
                if (order != null) {
                    order.setOrderStatus(status);

                    // Tự động đồng bộ Trạng thái thanh toán PayOS & Tiền tệ
                    if ("DELIVERED".equalsIgnoreCase(status) || "PAID".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status) || "CONFIRMED".equalsIgnoreCase(status)) {
                        if (!"PAID".equalsIgnoreCase(order.getPaymentStatus())) {
                            order.setPaymentStatus("PAID");
                        }
                    } else if ("CANCELLED".equalsIgnoreCase(status)) {
                        order.setPaymentStatus("CANCELLED");
                    }

                    if (paymentStatus != null && !paymentStatus.isBlank()) {
                        order.setPaymentStatus(paymentStatus);
                    }
                    orderDAO.update(order);

                    // Đồng bộ với bảng Payments (Giao dịch PayOS)
                    try {
                        Payment existingPayment = paymentDAO.findByOrder(orderId);
                        if (existingPayment != null) {
                            existingPayment.setStatus(order.getPaymentStatus());
                            paymentDAO.update(existingPayment);
                        } else {
                            Payment payment = new Payment();
                            payment.setOrderID(order);
                            payment.setTransactionCode("PAYOS-ADMIN-SYNC-" + System.currentTimeMillis());
                            payment.setPaymentMethod(order.getPaymentMethod() != null ? order.getPaymentMethod() : "PAYOS");
                            payment.setAmount(order.getFinalAmount() != null ? order.getFinalAmount() : BigDecimal.ZERO);
                            payment.setStatus(order.getPaymentStatus());
                            payment.setPaymentDate(Instant.now());
                            paymentDAO.create(payment);
                        }
                    } catch (Exception ignored) {}

                    // Ghi vết lịch sử trạng thái đơn hàng PayOS
                    try {
                        User adminUser = (User) req.getSession().getAttribute("currentUser");
                        OrderStatusHistory history = new OrderStatusHistory();
                        history.setOrderID(order);
                        history.setStatus("PAYOS_SYNC: " + status + " [Thanh toán: " + order.getPaymentStatus() + "]");
                        history.setChangedAt(Instant.now());
                        history.setChangedBy(adminUser != null ? adminUser : order.getUserID());
                        historyDAO.create(history);
                    } catch (Exception ignored) {}

                    resp.sendRedirect(req.getContextPath() + "/admin/orders?success=status_updated");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/orders");
    }
}

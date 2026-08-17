package poly.java.Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import poly.java.DAO.*;
import poly.java.DAO.Impl.*;
import poly.java.Entity.*;
import poly.java.Service.PayOSService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@WebServlet({"/checkout", "/checkout/submit", "/checkout/payment", "/checkout/payment/status", "/checkout/payment/payos", "/checkout/payment/payos-return", "/checkout/payment/payos-cancel", "/checkout/payment/confirm"})
public class CheckoutServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final OrderDetailDAO orderDetailDAO = new OrderDetailDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final OrderStatusHistoryDAO historyDAO = new OrderStatusHistoryDAOImpl();
    private final CouponDAO couponDAO = new CouponDAOImpl();
    private final CartDAO cartDAO = new CartDAOImpl();
    private final CartDetailDAO cartDetailDAO = new CartDetailDAOImpl();
    private final AddressDAO addressDAO = new AddressDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/checkout/payment/status".equals(path)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.findById(orderId);
                    if (order != null) {
                        resp.getWriter().write("{\"status\": \"" + order.getPaymentStatus() + "\"}");
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.getWriter().write("{\"status\": \"UNPAID\"}");
            return;
        }



        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if ("/checkout/payment/payos".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.findById(orderId);
                    if (order != null && order.getUserID().getId().equals(user.getId())) {
                        String scheme = req.getScheme();
                        String serverName = req.getServerName();
                        int serverPort = req.getServerPort();
                        String contextPath = req.getContextPath();
                        String baseUrl = scheme + "://" + serverName + (serverPort == 80 || serverPort == 443 ? "" : ":" + serverPort) + contextPath;

                        String returnUrl = baseUrl + "/checkout/payment/payos-return?orderId=" + order.getId();
                        String cancelUrl = baseUrl + "/checkout/payment/payos-cancel?orderId=" + order.getId();

                        int amount = order.getFinalAmount() != null ? order.getFinalAmount().intValue() : 0;
                        String desc = "TT Don Hang " + order.getId();
                        long payosOrderCode = (long) order.getId() * 100000L + (System.currentTimeMillis() % 100000L);

                        PayOSService.PayOSResult payOSResult = PayOSService.createPaymentLink(payosOrderCode, amount, desc, returnUrl, cancelUrl);

                        Payment payment = new Payment();
                        payment.setOrderID(order);
                        payment.setTransactionCode("PAYOS-" + order.getId() + "-" + System.currentTimeMillis());
                        payment.setPaymentMethod("PAYOS");
                        payment.setAmount(order.getFinalAmount() != null ? order.getFinalAmount() : BigDecimal.ZERO);
                        payment.setStatus("PENDING");
                        payment.setPaymentDate(Instant.now());
                        paymentDAO.create(payment);

                        if (payOSResult.isSuccess() && payOSResult.getCheckoutUrl() != null && !payOSResult.getCheckoutUrl().isBlank()) {
                            resp.sendRedirect(payOSResult.getCheckoutUrl());
                        } else {
                            req.setAttribute("order", order);
                            req.setAttribute("payosQrCode", payOSResult.getQrCode());
                            req.getRequestDispatcher("/payment.jsp").forward(req, resp);
                        }
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        if ("/checkout/payment/confirm".equals(path) || "/checkout/payment/payos-return".equals(path)) {
            String cancel = req.getParameter("cancel");
            String code = req.getParameter("code");
            if ("true".equalsIgnoreCase(cancel) || (code != null && !"00".equals(code))) {
                resp.sendRedirect(req.getContextPath() + "/orders?error=payos_cancelled");
                return;
            }

            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.findById(orderId);
                    if (order != null) {
                        order.setPaymentStatus("PAID");
                        order.setOrderStatus("CONFIRMED");
                        orderDAO.update(order);

                        Payment payment = new Payment();
                        payment.setOrderID(order);
                        payment.setTransactionCode("PAYOS-CONFIRM-" + System.currentTimeMillis());
                        payment.setPaymentMethod("PAYOS");
                        payment.setAmount(order.getFinalAmount() != null ? order.getFinalAmount() : BigDecimal.ZERO);
                        payment.setStatus("PAID");
                        payment.setPaymentDate(Instant.now());
                        paymentDAO.create(payment);

                        OrderStatusHistory history = new OrderStatusHistory();
                        history.setOrderID(order);
                        history.setStatus("PAID & CONFIRMED (PayOS/MB Bank)");
                        history.setChangedAt(Instant.now());
                        history.setChangedBy(user != null ? user : order.getUserID());
                        historyDAO.create(history);

                        resp.sendRedirect(req.getContextPath() + "/orders?success=payment_completed");
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        if ("/checkout/payment/payos-cancel".equals(path)) {
            resp.sendRedirect(req.getContextPath() + "/orders?error=payos_cancelled");
            return;
        }

        if ("/checkout/payment".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.findById(orderId);
                    if (order != null && order.getUserID().getId().equals(user.getId())) {
                        req.setAttribute("order", order);
                        req.getRequestDispatcher("/payment.jsp").forward(req, resp);
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        // Handle /checkout
        Cart cart = cartDAO.findByUser(user.getId());
        List<CartDetail> cartItems = (cart != null) ? cartDetailDAO.findByCart(cart.getId()) : List.of();

        if (cartItems.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        BigDecimal subTotal = BigDecimal.ZERO;
        for (CartDetail item : cartItems) {
            subTotal = subTotal.add(item.getTotalAmount());
        }

        String codeParam = req.getParameter("code");
        Coupon coupon = null;
        BigDecimal discountAmount = BigDecimal.ZERO;

        if (codeParam != null && !codeParam.isBlank()) {
            coupon = couponDAO.findByCode(codeParam);
            if (coupon != null) {
                if (coupon.getMinimumOrder() == null || subTotal.compareTo(coupon.getMinimumOrder()) >= 0) {
                    if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
                        discountAmount = subTotal.multiply(coupon.getDiscountValue()).divide(BigDecimal.valueOf(100));
                    } else {
                        discountAmount = coupon.getDiscountValue();
                    }
                    if (discountAmount.compareTo(subTotal) > 0) {
                        discountAmount = subTotal;
                    }
                } else {
                    req.setAttribute("errorMessage", "Đơn hàng phải tối thiểu " + coupon.getMinimumOrder() + "đ để dùng mã này!");
                    coupon = null;
                }
            } else {
                req.setAttribute("errorMessage", "Mã giảm giá không hợp lệ hoặc đã hết hạn!");
            }
        }

        BigDecimal grandTotal = subTotal.subtract(discountAmount);
        if (grandTotal.compareTo(BigDecimal.ZERO) < 0) grandTotal = BigDecimal.ZERO;

        req.setAttribute("cartItems", cartItems);
        req.setAttribute("subTotal", subTotal);
        req.setAttribute("discountAmount", discountAmount);
        req.setAttribute("grandTotal", grandTotal);
        req.setAttribute("discountCode", coupon);

        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();



        if ("/checkout/submit".equals(path)) {
            User user = (User) req.getSession().getAttribute("currentUser");
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            String fullname = req.getParameter("fullname");
            String phone = req.getParameter("phone");
            String addressText = req.getParameter("address");
            String note = req.getParameter("note");
            String paymentMethod = req.getParameter("paymentMethod");
            String discountCodeStr = req.getParameter("discountCode");

            if (fullname == null || fullname.isBlank() || phone == null || phone.isBlank() || addressText == null || addressText.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/checkout?error=missing_info");
                return;
            }

            Cart cart = cartDAO.findByUser(user.getId());
            List<CartDetail> cartItems = (cart != null) ? cartDetailDAO.findByCart(cart.getId()) : List.of();

            if (cartItems.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/cart");
                return;
            }

            BigDecimal subTotal = BigDecimal.ZERO;
            for (CartDetail item : cartItems) {
                subTotal = subTotal.add(item.getTotalAmount());
            }

            Coupon coupon = null;
            BigDecimal discountAmount = BigDecimal.ZERO;
            if (discountCodeStr != null && !discountCodeStr.isBlank()) {
                coupon = couponDAO.findByCode(discountCodeStr);
                if (coupon != null) {
                    if (coupon.getMinimumOrder() == null || subTotal.compareTo(coupon.getMinimumOrder()) >= 0) {
                        if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
                            discountAmount = subTotal.multiply(coupon.getDiscountValue()).divide(BigDecimal.valueOf(100));
                        } else {
                            discountAmount = coupon.getDiscountValue();
                        }
                        if (discountAmount.compareTo(subTotal) > 0) {
                            discountAmount = subTotal;
                        }
                    }
                }
            }

            BigDecimal finalAmount = subTotal.subtract(discountAmount);
            if (finalAmount.compareTo(BigDecimal.ZERO) < 0) finalAmount = BigDecimal.ZERO;

            Address address = addressDAO.findDefaultAddress(user.getId());
            if (address == null) {
                address = new Address();
                address.setUserID(user);
                address.setReceiverName(fullname);
                address.setPhone(phone);
                address.setAddressDetail(addressText);
                address.setIsDefault(true);
                address = addressDAO.create(address);
            } else {
                address.setReceiverName(fullname);
                address.setPhone(phone);
                address.setAddressDetail(addressText);
                addressDAO.update(address);
            }

            Order order = new Order();
            order.setUserID(user);
            order.setAddressID(address);
            order.setCouponID(coupon);
            order.setOrderDate(Instant.now());
            order.setTotalAmount(subTotal);
            order.setDiscountAmount(discountAmount);
            order.setShippingFee(BigDecimal.ZERO);
            order.setFinalAmount(finalAmount);
            order.setPaymentMethod(paymentMethod != null ? paymentMethod : "COD");
            order.setPaymentStatus("UNPAID");
            order.setOrderStatus("PENDING");
            order.setNote(note);

            order = orderDAO.create(order);

            for (CartDetail cd : cartItems) {
                OrderDetail od = new OrderDetail();
                od.setOrderID(order);
                od.setVariantID(cd.getVariantID());
                od.setPrice(cd.getActualPrice());
                od.setQuantity(cd.getQuantity());
                od.setTotal(cd.getTotalAmount());
                orderDetailDAO.create(od);

                cartDetailDAO.delete(cd.getId());
            }

            OrderStatusHistory history = new OrderStatusHistory();
            history.setOrderID(order);
            history.setStatus("PENDING");
            history.setChangedAt(Instant.now());
            history.setChangedBy(user);
            historyDAO.create(history);

            if ("PAYOS".equalsIgnoreCase(paymentMethod) || "ONLINE".equalsIgnoreCase(paymentMethod)) {
                resp.sendRedirect(req.getContextPath() + "/checkout/payment/payos?orderId=" + order.getId());
            } else {
                resp.sendRedirect(req.getContextPath() + "/orders?success=order_placed");
            }
        }
    }
}

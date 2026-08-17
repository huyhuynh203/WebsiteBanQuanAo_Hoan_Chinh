package poly.java.Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import poly.java.DAO.CartDAO;
import poly.java.DAO.CartDetailDAO;
import poly.java.DAO.ProductVariantDAO;
import poly.java.DAO.Impl.CartDAOImpl;
import poly.java.DAO.Impl.CartDetailDAOImpl;
import poly.java.DAO.Impl.ProductVariantDAOImpl;
import poly.java.Entity.Cart;
import poly.java.Entity.CartDetail;
import poly.java.Entity.ProductVariant;
import poly.java.Entity.User;

import java.io.IOException;

@WebServlet("/cart/add")
public class AddToCartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final CartDetailDAO cartDetailDAO = new CartDetailDAOImpl();
    private final ProductVariantDAO variantDAO = new ProductVariantDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String variantIdStr = req.getParameter("variantId");
        String productIdStr = req.getParameter("productId");
        String color = req.getParameter("color");
        String size = req.getParameter("size");
        String qtyStr = req.getParameter("quantity");

        int quantity = 1;
        if (qtyStr != null && !qtyStr.isBlank()) {
            try {
                quantity = Math.max(1, Integer.parseInt(qtyStr));
            } catch (NumberFormatException ignored) {}
        }

        ProductVariant variant = null;

        if (variantIdStr != null && !variantIdStr.isBlank()) {
            try {
                int variantId = Integer.parseInt(variantIdStr);
                variant = variantDAO.findById(variantId);
            } catch (Exception ignored) {}
        }

        if (variant == null && productIdStr != null && !productIdStr.isBlank()) {
            try {
                int productId = Integer.parseInt(productIdStr);
                variant = variantDAO.findByProductColorSize(productId, color, size);
                
                // Nếu chưa có đúng màu/size, lấy bất kỳ biến thể nào của sản phẩm
                if (variant == null) {
                    var list = variantDAO.findByProductId(productId);
                    if (!list.isEmpty()) {
                        variant = list.get(0);
                    }
                }

                // Nếu sản phẩm hoàn toàn chưa có biến thể nào trong CSDL (sản phẩm mới tạo), tự động khởi tạo biến thể
                if (variant == null) {
                    poly.java.DAO.ProductDAO productDAO = new poly.java.DAO.Impl.ProductDAOImpl();
                    poly.java.Entity.Product prod = productDAO.findById(productId);
                    if (prod != null) {
                        ProductVariant newPv = new ProductVariant();
                        newPv.setProductID(prod);

                        poly.java.Entity.Color c = new poly.java.Entity.Color();
                        c.setId(1); // Trắng
                        poly.java.Entity.Size s = new poly.java.Entity.Size();
                        s.setId(2); // M

                        newPv.setColorID(c);
                        newPv.setSizeID(s);
                        newPv.setSku("SKU-" + prod.getId() + "-AUTO");
                        newPv.setPrice(prod.getDiscountPrice() != null && prod.getDiscountPrice().compareTo(java.math.BigDecimal.ZERO) > 0 ? prod.getDiscountPrice() : prod.getPrice());
                        newPv.setQuantity(50);

                        variant = variantDAO.create(newPv);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (variant != null) {
            try {
                Cart cart = CartServlet.getOrCreateCart(user, cartDAO);
                CartDetail existing = cartDetailDAO.findByCartAndVariant(cart.getId(), variant.getId());
                if (existing != null) {
                    existing.setQuantity(existing.getQuantity() + quantity);
                    cartDetailDAO.update(existing);
                } else {
                    CartDetail cd = new CartDetail();
                    cd.setCartID(cart);
                    cd.setVariantID(variant);
                    cd.setQuantity(quantity);
                    cartDetailDAO.create(cd);
                }
                String action = req.getParameter("action");
                if ("buy_now".equals(action)) {
                    resp.sendRedirect(req.getContextPath() + "/checkout");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/cart");
                }
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/products");
    }
}
package poly.java.Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import poly.java.DAO.CategoryDAO;
import poly.java.DAO.ProductDAO;
import poly.java.DAO.ProductVariantDAO;
import poly.java.DAO.Impl.CategoryDAOImpl;
import poly.java.DAO.Impl.ProductDAOImpl;
import poly.java.DAO.Impl.ProductVariantDAOImpl;
import poly.java.Entity.Product;
import poly.java.Entity.ProductVariant;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet({"/products", "/product-detail"})
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAOImpl();
    private final CategoryDAO categoryDAO = new CategoryDAOImpl();
    private final ProductVariantDAO variantDAO = new ProductVariantDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/product-detail".equals(path)) {
            showProductDetail(request, response);
        } else {
            showProductList(request, response);
        }
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String categoryIdStr = request.getParameter("categoryId");
        List<Product> products;

        if (categoryIdStr != null && !categoryIdStr.isBlank()) {
            try {
                int categoryId = Integer.parseInt(categoryIdStr);
                products = productDAO.findByCategoryId(categoryId);
                request.setAttribute("selectedCategoryId", categoryId);
            } catch (NumberFormatException e) {
                products = productDAO.findActiveProducts();
            }
        } else {
            products = productDAO.findActiveProducts();
        }

        request.setAttribute("categories", categoryDAO.findActiveCategories());
        request.setAttribute("products", products);
        request.getRequestDispatcher("/WEB-INF/views/products.jsp").forward(request, response);
    }

    private void showProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Product product = productDAO.findById(id);
                if (product != null) {
                    try {
                        productDAO.updateViewCount(id);
                    } catch (Exception ignored) {}

                    Set<String> colors = new LinkedHashSet<>();
                    Set<String> sizes = new LinkedHashSet<>();

                    try {
                        List<ProductVariant> variants = variantDAO.findByProductId(id);
                        for (ProductVariant v : variants) {
                            if (v.getColorID() != null && v.getColorID().getColorName() != null) {
                                colors.add(v.getColorID().getColorName());
                            }
                            if (v.getSizeID() != null && v.getSizeID().getSizeName() != null) {
                                sizes.add(v.getSizeID().getSizeName());
                            }
                        }
                    } catch (Exception ignored) {}

                    if (colors.size() < 2) {
                        colors.add("Trắng");
                        colors.add("Đen");
                    }

                    if (sizes.size() < 2) {
                        sizes.add("M");
                        sizes.add("L");
                        sizes.add("XL");
                        sizes.add("2XL");
                        sizes.add("3XL");
                        sizes.add("4XL");
                        sizes.add("5XL");
                    }

                    request.setAttribute("colorsSet", colors);
                    request.setAttribute("sizesSet", sizes);
                    poly.java.DAO.ProductImageDAO productImageDAO = new poly.java.DAO.Impl.ProductImageDAOImpl();
                    List<poly.java.Entity.ProductImage> extraImages = productImageDAO.findByProduct(id);
                    request.setAttribute("extraImages", extraImages);

                    request.setAttribute("colorsSet", colors);
                    request.setAttribute("sizesSet", sizes);
                    request.setAttribute("product", product);
                    request.getRequestDispatcher("/WEB-INF/views/product-detail.jsp").forward(request, response);
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/products");
    }
}
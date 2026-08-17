package poly.java.Servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import poly.java.DAO.CategoryDAO;
import poly.java.DAO.ProductDAO;
import poly.java.DAO.Impl.CategoryDAOImpl;
import poly.java.DAO.Impl.ProductDAOImpl;
import poly.java.Entity.Brand;
import poly.java.Entity.Category;
import poly.java.Entity.Product;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/admin/products", "/admin/products/add", "/admin/products/edit", "/admin/product/create", "/admin/product/edit", "/admin/product/delete"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdminProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAOImpl();
    private final CategoryDAO categoryDAO = new CategoryDAOImpl();
    private final poly.java.DAO.BrandDAO brandDAO = new poly.java.DAO.Impl.BrandDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        switch (path) {
            case "/admin/product/edit", "/admin/products/edit" -> {
                try {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Product product = productDAO.findById(id);
                    req.setAttribute("product", product);
                } catch (Exception ignored) {}
            }
            case "/admin/product/delete" -> {
                try {
                    int id = Integer.parseInt(req.getParameter("id"));
                    productDAO.delete(id);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                resp.sendRedirect(req.getContextPath() + "/admin/products");
                return;
            }
        }

        String keyword = req.getParameter("keyword");
        String categoryIdStr = req.getParameter("categoryId");
        String statusStr = req.getParameter("status");

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isBlank()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException ignored) {}
        }

        Boolean status = null;
        if (statusStr != null && !statusStr.isBlank()) {
            status = Boolean.parseBoolean(statusStr);
        }

        List<Product> products;
        if ((keyword != null && !keyword.isBlank()) || categoryId != null || status != null) {
            products = productDAO.searchProducts(keyword, categoryId, status, 1, 100);
        } else {
            products = productDAO.findAll();
        }

        req.setAttribute("categories", categoryDAO.findAll());
        req.setAttribute("products", products);
        req.getRequestDispatcher("/admin/products.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String idStr = req.getParameter("id");
        String productName = req.getParameter("name");
        if (productName == null || productName.isBlank()) {
            productName = req.getParameter("productName");
        }

        String categoryIdStr = req.getParameter("categoryId");
        String brandIdStr = req.getParameter("brandId");
        String priceStr = req.getParameter("price");
        String discountStr = req.getParameter("discountPrice");
        String description = req.getParameter("description");
        String imageUrlParam = req.getParameter("imageUrl");
        if (imageUrlParam == null || imageUrlParam.isBlank()) {
            imageUrlParam = req.getParameter("extraImageUrls");
        }

        List<String> allImageUrls = new ArrayList<>();

        // 1. Phân tách danh sách URL nhập vào
        if (imageUrlParam != null && !imageUrlParam.isBlank()) {
            String[] urls = imageUrlParam.split("[\n,]+");
            for (String url : urls) {
                url = url.trim();
                if (!url.isEmpty()) {
                    allImageUrls.add(url);
                }
            }
        }

        // 2. Tải lên file ảnh từ máy tính (hỗ trợ chọn cùng lúc 1 hoặc nhiều file)
        try {
            for (Part part : req.getParts()) {
                if (("imageFile".equals(part.getName()) || "extraImageFiles".equals(part.getName())) && part.getSize() > 0) {
                    String fileName = extractFileName(part);
                    if (fileName != null && !fileName.isBlank()) {
                        String uploadPath = req.getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "products";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        String newFileName = System.currentTimeMillis() + "_" + fileName;
                        String filePath = uploadPath + File.separator + newFileName;
                        part.write(filePath);
                        allImageUrls.add("uploads/products/" + newFileName);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Upload image error: " + e.getMessage());
        }

        String brandName = req.getParameter("brandName");
        if (brandName == null || brandName.isBlank()) {
            brandName = req.getParameter("brandId");
        }

        int categoryId = categoryIdStr != null && !categoryIdStr.isBlank() ? Integer.parseInt(categoryIdStr) : 1;
        BigDecimal price = priceStr != null && !priceStr.isBlank() ? new BigDecimal(priceStr) : BigDecimal.ZERO;
        BigDecimal discountPrice = (discountStr != null && !discountStr.isBlank()) ? new BigDecimal(discountStr) : null;

        Brand brand = null;
        if (brandName != null && !brandName.isBlank()) {
            try {
                int bId = Integer.parseInt(brandName);
                brand = brandDAO.findById(bId);
            } catch (NumberFormatException e) {
                brand = brandDAO.findByName(brandName.trim());
                if (brand == null) {
                    Brand newBrand = new Brand();
                    newBrand.setBrandName(brandName.trim());
                    brand = brandDAO.create(newBrand);
                }
            }
        }
        if (brand == null) {
            brand = brandDAO.findById(1);
        }

        Product product = new Product();
        if (idStr != null && !idStr.isBlank()) {
            Product existing = productDAO.findById(Integer.parseInt(idStr));
            if (existing != null) {
                product = existing;
            }
        }

        product.setProductName(productName);

        Category category = new Category();
        category.setId(categoryId);
        product.setCategoryID(category);

        product.setBrandID(brand);

        product.setPrice(price);
        product.setDiscountPrice(discountPrice);
        if (!allImageUrls.isEmpty()) {
            product.setThumbnail(allImageUrls.get(0));
        }
        product.setDescription(description);
        product.setStatus(true);

        String customColors = req.getParameter("customColors");
        String customSizes = req.getParameter("customSizes");

        if (product.getId() != null) {
            productDAO.update(product);
            try {
                createVariantsFromInputs(product, customColors, customSizes);
                saveExtraImages(product, allImageUrls);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            product.setSoldQuantity(0);
            product.setViewCount(0);
            Product created = productDAO.create(product);
            
            try {
                createVariantsFromInputs(created, customColors, customSizes);
                saveExtraImages(created, allImageUrls);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private void saveExtraImages(Product product, List<String> allImageUrls) {
        if (product == null || product.getId() == null || allImageUrls == null || allImageUrls.isEmpty()) return;
        poly.java.DAO.ProductImageDAO imgDAO = new poly.java.DAO.Impl.ProductImageDAOImpl();

        for (int i = 0; i < allImageUrls.size(); i++) {
            String url = allImageUrls.get(i);
            poly.java.Entity.ProductImage pi = new poly.java.Entity.ProductImage();
            pi.setProductID(product);
            pi.setImageURL(url);
            pi.setIsMain(i == 0);
            try {
                imgDAO.create(pi);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private void createVariantsFromInputs(Product product, String customColors, String customSizes) {
        if (product == null || product.getId() == null) return;
        if (customColors == null || customColors.isBlank() || customSizes == null || customSizes.isBlank()) {
            createDefaultVariants(product);
            return;
        }

        String[] colors = customColors.split(",");
        String[] sizes = customSizes.split(",");

        poly.java.DAO.ColorDAO colorDAO = new poly.java.DAO.Impl.ColorDAOImpl();
        poly.java.DAO.SizeDAO sizeDAO = new poly.java.DAO.Impl.SizeDAOImpl();
        poly.java.DAO.ProductVariantDAO variantDAO = new poly.java.DAO.Impl.ProductVariantDAOImpl();

        List<poly.java.Entity.Color> allColors = colorDAO.findAll();
        List<poly.java.Entity.Size> allSizes = sizeDAO.findAll();

        for (String cName : colors) {
            cName = cName.trim();
            if (cName.isEmpty()) continue;

            poly.java.Entity.Color colorEntity = null;
            for (poly.java.Entity.Color c : allColors) {
                if (c.getColorName() != null && c.getColorName().equalsIgnoreCase(cName)) {
                    colorEntity = c;
                    break;
                }
            }
            if (colorEntity == null) {
                colorEntity = new poly.java.Entity.Color();
                colorEntity.setColorName(cName);
                colorEntity = colorDAO.create(colorEntity);
                allColors.add(colorEntity);
            }

            for (String sName : sizes) {
                sName = sName.trim();
                if (sName.isEmpty()) continue;

                poly.java.Entity.Size sizeEntity = null;
                for (poly.java.Entity.Size s : allSizes) {
                    if (s.getSizeName() != null && s.getSizeName().equalsIgnoreCase(sName)) {
                        sizeEntity = s;
                        break;
                    }
                }
                if (sizeEntity == null) {
                    sizeEntity = new poly.java.Entity.Size();
                    sizeEntity.setSizeName(sName);
                    sizeEntity = sizeDAO.create(sizeEntity);
                    allSizes.add(sizeEntity);
                }

                try {
                    poly.java.Entity.ProductVariant existing = variantDAO.findByProductColorSize(product.getId(), cName, sName);
                    if (existing == null) {
                        poly.java.Entity.ProductVariant pv = new poly.java.Entity.ProductVariant();
                        pv.setProductID(product);
                        pv.setColorID(colorEntity);
                        pv.setSizeID(sizeEntity);
                        pv.setSku("SKU-" + product.getId() + "-C" + colorEntity.getId() + "S" + sizeEntity.getId());
                        pv.setPrice(product.getDiscountPrice() != null && product.getDiscountPrice().compareTo(BigDecimal.ZERO) > 0 ? product.getDiscountPrice() : product.getPrice());
                        pv.setQuantity(50);
                        variantDAO.create(pv);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    private void createDefaultVariants(Product product) {
        if (product == null || product.getId() == null) return;
        poly.java.DAO.ProductVariantDAO variantDAO = new poly.java.DAO.Impl.ProductVariantDAOImpl();
        
        // Tạo các biến thể cơ bản: Màu Trắng (ID 1), Đen (ID 2); Size M (ID 2), Size L (ID 3), Size XL (ID 4)
        int[][] combinations = {
            {1, 2}, // Trắng - M
            {1, 3}, // Trắng - L
            {1, 4}, // Trắng - XL
            {2, 2}, // Đen - M
            {2, 3}, // Đen - L
            {2, 4}  // Đen - XL
        };

        for (int[] combo : combinations) {
            try {
                poly.java.Entity.ProductVariant pv = new poly.java.Entity.ProductVariant();
                pv.setProductID(product);
                
                poly.java.Entity.Color col = new poly.java.Entity.Color();
                col.setId(combo[0]);
                pv.setColorID(col);
                
                poly.java.Entity.Size sz = new poly.java.Entity.Size();
                sz.setId(combo[1]);
                pv.setSizeID(sz);
                
                pv.setSku("SKU-" + product.getId() + "-C" + combo[0] + "S" + combo[1]);
                pv.setPrice(product.getDiscountPrice() != null && product.getDiscountPrice().compareTo(BigDecimal.ZERO) > 0 ? product.getDiscountPrice() : product.getPrice());
                pv.setQuantity(50); // Tồn kho ban đầu 50 cái
                
                variantDAO.create(pv);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
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
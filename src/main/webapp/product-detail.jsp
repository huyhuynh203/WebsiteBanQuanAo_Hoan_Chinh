<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.*, poly.java.Entity.*" %>
<%@ include file="/WEB-INF/views/header.jsp" %>

<%
    Product product = (Product) request.getAttribute("product");
    Set<String> colors = (Set<String>) request.getAttribute("colorsSet");
    Set<String> sizes = (Set<String>) request.getAttribute("sizesSet");

    if (colors == null || colors.isEmpty()) {
        colors = new LinkedHashSet<>();
        if (product != null && product.getId() != null) {
            try {
                poly.java.DAO.ProductVariantDAO vDao = new poly.java.DAO.Impl.ProductVariantDAOImpl();
                List<ProductVariant> vars = vDao.findByProductId(product.getId());
                for (ProductVariant d : vars) {
                    if (d.getColorID() != null && d.getColorID().getColorName() != null) {
                        colors.add(d.getColorID().getColorName().trim());
                    }
                }
            } catch (Exception ignored) {}
        }
    }

    if (sizes == null || sizes.isEmpty()) {
        sizes = new LinkedHashSet<>();
        if (product != null && product.getId() != null) {
            try {
                poly.java.DAO.ProductVariantDAO vDao = new poly.java.DAO.Impl.ProductVariantDAOImpl();
                List<ProductVariant> vars = vDao.findByProductId(product.getId());
                for (ProductVariant d : vars) {
                    if (d.getSizeID() != null && d.getSizeID().getSizeName() != null) {
                        sizes.add(d.getSizeID().getSizeName().trim());
                    }
                }
            } catch (Exception ignored) {}
        }
    }

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
%>

<div class="container" style="padding-top: 20px;">
    <!-- Thông báo lỗi hoặc thành công -->
    <c:if test="${param.error == 'variant_not_found'}">
        <div class="form-error">Biến thể với màu sắc và kích cỡ đã chọn hiện không tồn tại. Vui lòng chọn lại.</div>
    </c:if>
    <c:if test="${param.error == 'out_of_stock'}">
        <div class="form-error">Sản phẩm này hiện đang hết hàng hoặc số lượng trong kho không đủ.</div>
    </c:if>
    <c:if test="${param.error == 'add_failed'}">
        <div class="form-error">Không thể thêm vào giỏ hàng. Vui lòng thử lại.</div>
    </c:if>

    <div class="detail-container">
        <!-- Gallery Hình Ảnh -->
        <div class="detail-gallery">
            <div class="main-image" style="position: relative; overflow: hidden; border-radius: var(--radius-md);">
                <button type="button" class="gallery-arrow arrow-left" onclick="navigateGallery(-1)" title="Ảnh trước" style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%); width: 44px; height: 44px; border-radius: 50%; background: rgba(11, 15, 23, 0.75); color: #e5b842; border: 1.5px solid rgba(229, 184, 66, 0.4); cursor: pointer; display: flex; align-items: center; justify-content: center; z-index: 10; font-size: 1.2rem; backdrop-filter: blur(4px); box-shadow: 0 4px 12px rgba(0,0,0,0.3); transition: all 0.2s ease;">
                    <i class="fa-solid fa-chevron-left"></i>
                </button>
                <img id="mainProductImg" src="${product.imageUrl}" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop';" alt="${product.productName}">
                <button type="button" class="gallery-arrow arrow-right" onclick="navigateGallery(1)" title="Ảnh tiếp theo" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); width: 44px; height: 44px; border-radius: 50%; background: rgba(11, 15, 23, 0.75); color: #e5b842; border: 1.5px solid rgba(229, 184, 66, 0.4); cursor: pointer; display: flex; align-items: center; justify-content: center; z-index: 10; font-size: 1.2rem; backdrop-filter: blur(4px); box-shadow: 0 4px 12px rgba(0,0,0,0.3); transition: all 0.2s ease;">
                    <i class="fa-solid fa-chevron-right"></i>
                </button>
            </div>
            
            <div id="thumbStrip" style="display: flex; gap: 10px; overflow-x: auto; margin-top: 12px; padding-bottom: 6px;">
                <div class="thumb-item active-thumb" onclick="changeMainImg('${product.imageUrl}', this)" style="width: 75px; height: 95px; border-radius: var(--radius-sm); overflow: hidden; border: 2px solid #e5b842; box-shadow: 0 0 10px rgba(229, 184, 66, 0.6); cursor: pointer; flex-shrink: 0; transition: all 0.25s ease;">
                    <img src="${product.imageUrl}" style="width: 100%; height: 100%; object-fit: cover;">
                </div>
                <c:forEach var="img" items="${not empty extraImages ? extraImages : product.productImages}">
                    <div class="thumb-item" onclick="changeMainImg(this.querySelector('img').src, this)" style="width: 75px; height: 95px; border-radius: var(--radius-sm); overflow: hidden; border: 1px solid var(--border-color); cursor: pointer; flex-shrink: 0; transition: all 0.25s ease;">
                        <img src="${img.imageURL.startsWith('http') ? img.imageURL : pageContext.request.contextPath.concat('/').concat(img.imageURL)}" style="width: 100%; height: 100%; object-fit: cover;">
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Thông Tin Chi Tiết -->
        <div class="detail-info">
            <div>
                <span style="color: var(--accent); font-weight: 700; text-transform: uppercase; letter-spacing: 1px; font-size: 0.9rem;">
                    Thương hiệu: ${product.brandID.brandName}
                </span>
                <h1 class="detail-title" style="margin-top: 6px; margin-bottom: 12px;">${product.productName}</h1>
                <div style="display: flex; align-items: center; gap: 15px;">
                    <span style="color: #f59e0b; font-size: 1.1rem;">
                        <c:forEach begin="1" end="5" var="i">
                            <i class="${i <= avgRating ? 'fa-solid fa-star' : 'fa-regular fa-star'}"></i>
                        </c:forEach>
                    </span>
                    <span style="color: var(--text-secondary); font-size: 0.9rem;">(${reviews.size()} đánh giá)</span>
                    <span style="color: #10b981; font-weight: 600; font-size: 0.85rem; margin-left: auto;">● Tình trạng: Còn hàng</span>
                </div>
            </div>

            <div class="detail-price-box">
                <c:choose>
                    <c:when test="${product.discountPrice != null && product.discountPrice > 0}">
                        <div style="font-size: 2.2rem; font-weight: 800; color: #ef4444;">
                            <fmt:formatNumber value="${product.discountPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                        <div style="color: var(--text-muted); text-decoration: line-through; font-size: 1.1rem; margin-top: 4px;">
                            Giá gốc: <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="font-size: 2.2rem; font-weight: 800; color: var(--text-primary);">
                            <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <p style="color: var(--text-secondary); border-bottom: 1px solid var(--border-color); padding-bottom: 24px;">
                ${product.description}
            </p>

            <!-- Form Thêm Vào Giỏ Hàng & Mua Ngay -->
            <form action="${pageContext.request.contextPath}/cart/add" method="POST" style="display: flex; flex-direction: column; gap: 20px;">
                <input type="hidden" name="productId" value="${product.id}">
                
                <!-- Chọn Màu Sắc -->
                <div class="options-group">
                    <span class="options-title">Màu Sắc</span>
                    <div class="options-selector">
                        <c:forEach var="col" items="${colorsSet}" varStatus="loop">
                            <input type="radio" id="col_${col}" name="color" value="${col}" class="option-radio" ${loop.first ? 'checked' : ''} required>
                            <label for="col_${col}" class="option-label">${col}</label>
                        </c:forEach>
                    </div>
                </div>

                <!-- Chọn Size -->
                <div class="options-group">
                    <span class="options-title">Kích thước (Size)</span>
                    <div class="options-selector">
                        <c:forEach var="sz" items="${sizesSet}" varStatus="loop">
                            <input type="radio" id="sz_${sz}" name="size" value="${sz}" class="option-radio" ${loop.first ? 'checked' : ''} required>
                            <label for="sz_${sz}" class="option-label">${sz}</label>
                        </c:forEach>
                    </div>
                </div>

                <!-- Chọn Số Lượng -->
                <div class="options-group">
                    <span class="options-title">Số Lượng</span>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <div style="display: flex; align-items: center; border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden; background: var(--bg-primary);">
                            <button type="button" onclick="adjustQty(-1)" style="width: 36px; height: 42px; background: transparent; border: none; color: var(--text-primary); font-size: 1.1rem; cursor: pointer; font-weight: 700;">-</button>
                            <input type="number" id="detailQty" name="quantity" value="1" min="1" max="99" class="form-control" style="width: 50px; text-align: center; border: none; background: transparent; color: var(--text-primary); font-weight: 700; padding: 0;">
                            <button type="button" onclick="adjustQty(1)" style="width: 36px; height: 42px; background: transparent; border: none; color: var(--text-primary); font-size: 1.1rem; cursor: pointer; font-weight: 700;">+</button>
                        </div>
                    </div>
                </div>

                <!-- Bộ Nút Bấm Mua Hàng -->
                <div style="display: flex; gap: 14px; margin-top: 10px;">
                    <c:choose>
                        <c:when test="${sessionScope.currentUser != null}">
                            <button type="submit" name="action" value="add_cart" class="btn" style="flex: 1; padding: 14px; background: transparent; border: 2px solid var(--accent); color: var(--accent); font-weight: 800; font-size: 0.95rem; border-radius: var(--radius-md); cursor: pointer;">
                                <i class="fa-solid fa-cart-plus" style="margin-right: 6px;"></i> THÊM VÀO GIỎ
                            </button>
                            <button type="submit" name="action" value="buy_now" class="btn" style="flex: 1; padding: 14px; background: linear-gradient(135deg, #e5b842 0%, #c99726 100%); border: none; color: #0b0f19; font-weight: 900; font-size: 0.95rem; border-radius: var(--radius-md); cursor: pointer; box-shadow: 0 4px 15px rgba(229, 184, 66, 0.3);">
                                <i class="fa-solid fa-bolt" style="margin-right: 6px;"></i> MUA NGAY
                            </button>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="width: 100%; padding: 14px; text-align: center; font-weight: 800;">
                                ĐĂNG NHẬP ĐỂ MUA HÀNG
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>

<script>
    var galleryImages = [];
    var currentImageIndex = 0;

    function initGallery() {
        galleryImages = [];
        var mainImg = document.getElementById('mainProductImg');
        if (mainImg && mainImg.src) {
            galleryImages.push(mainImg.src);
        }
        var thumbImgs = document.querySelectorAll('.detail-gallery img');
        thumbImgs.forEach(function(img) {
            if (img.src && !galleryImages.includes(img.src) && img.id !== 'mainProductImg') {
                galleryImages.push(img.src);
            }
        });
        currentImageIndex = 0;
    }

    function updateActiveThumbnail(src) {
        var items = document.querySelectorAll('#thumbStrip .thumb-item');
        items.forEach(function(item) {
            var img = item.querySelector('img');
            if (img && img.src === src) {
                item.style.border = '2px solid #e5b842';
                item.style.boxShadow = '0 0 10px rgba(229, 184, 66, 0.6)';
                try {
                    item.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                } catch (e) {}
            } else {
                item.style.border = '1px solid var(--border-color)';
                item.style.boxShadow = 'none';
            }
        });
    }

    function changeMainImg(src, elem) {
        if (src) {
            document.getElementById('mainProductImg').src = src;
            if (galleryImages.length === 0) initGallery();
            var idx = galleryImages.indexOf(src);
            if (idx !== -1) {
                currentImageIndex = idx;
            }
            updateActiveThumbnail(src);
        }
    }

    function navigateGallery(direction) {
        if (!galleryImages || galleryImages.length <= 1) {
            initGallery();
        }
        if (!galleryImages || galleryImages.length === 0) return;

        currentImageIndex += direction;
        if (currentImageIndex < 0) {
            currentImageIndex = galleryImages.length - 1;
        } else if (currentImageIndex >= galleryImages.length) {
            currentImageIndex = 0;
        }
        var nextSrc = galleryImages[currentImageIndex];
        document.getElementById('mainProductImg').src = nextSrc;
        updateActiveThumbnail(nextSrc);
    }

    function adjustQty(amount) {
        var input = document.getElementById('detailQty');
        var val = parseInt(input.value) || 1;
        val += amount;
        if (val < 1) val = 1;
        if (val > 99) val = 99;
        input.value = val;
    }

    document.addEventListener('DOMContentLoaded', initGallery);
</script>

    <!-- Phần Đánh Giá (Reviews) -->
    <section style="margin-top: 60px; border-top: 1px solid var(--border-color); padding-top: 40px; margin-bottom: 80px;">
        <h3 class="section-title">Đánh Giá Từ Khách Hàng</h3>
        <p class="section-desc">Ý kiến phản hồi từ những người đã mua sản phẩm này</p>

        <!-- Form Viết Nhận Xét (Nếu đã đăng nhập) -->
        <c:if test="${sessionScope.currentUser != null}">
            <div style="background-color: var(--bg-secondary); border: 1px solid var(--border-color); padding: 30px; border-radius: var(--radius-md); margin-bottom: 40px;">
                <h4 style="margin-bottom: 16px; font-weight: 700;">Viết nhận xét của bạn</h4>
                
                <form action="${pageContext.request.contextPath}/review/add" method="POST">
                    <input type="hidden" name="productId" value="${product.id}">
                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label">Chọn số sao đánh giá</label>
                        <select name="rating" class="form-control" style="width: 150px; background-color: var(--bg-primary); border: 1px solid var(--border-color);">
                            <option value="5">5 Sao (Rất tốt)</option>
                            <option value="4">4 Sao (Tốt)</option>
                            <option value="3">3 Sao (Bình thường)</option>
                            <option value="2">2 Sao (Kém)</option>
                            <option value="1">1 Sao (Rất kém)</option>
                        </select>
                    </div>
                    <div class="form-group" style="margin-bottom: 20px;">
                        <label class="form-label">Nội dung nhận xét</label>
                        <textarea name="comment" rows="4" placeholder="Nhập cảm nhận của bạn về sản phẩm (vải, size, màu sắc...)" class="form-control" style="width: 100%; resize: none;" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary" style="padding: 10px 24px;">Gửi Đánh Giá</button>
                </form>
            </div>
        </c:if>

        <!-- Danh sách nhận xét -->
        <div style="display: flex; flex-direction: column; gap: 20px;">
            <c:choose>
                <c:when test="${not empty reviews}">
                    <c:forEach var="rev" items="${reviews}">
                        <div class="review-bubble">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                <span style="font-weight: 600; font-size: 1.05rem;">
                                    <i class="fa-regular fa-user" style="margin-right: 6px;"></i> ${rev.fullname}
                                </span>
                                <span style="color: #f59e0b; font-size: 0.9rem;">
                                    <c:forEach begin="1" end="5" var="i">
                                        <i class="${i <= rev.rating ? 'fa-solid fa-star' : 'fa-regular fa-star'}"></i>
                                    </c:forEach>
                                </span>
                            </div>
                            <p style="color: var(--text-secondary); font-size: 0.95rem; margin-bottom: 6px;">${rev.comment}</p>
                            <span style="color: var(--text-muted); font-size: 0.8rem;">
                                Đăng ngày: <fmt:formatDate value="${rev.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="color: var(--text-secondary); font-style: italic;">Chưa có đánh giá nào cho sản phẩm này. Hãy là người đầu tiên đánh giá!</p>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

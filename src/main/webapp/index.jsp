<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="/WEB-INF/views/header.jsp" %>

<!-- Banner Slider / Hero Section -->
<section class="container">
    <div class="hero-slider">
        <c:choose>
            <c:when test="${not empty banners}">
                <c:forEach var="banner" items="${banners}" varStatus="status">
                    <div class="slide ${status.first ? 'active' : ''}" style="background-image: linear-gradient(90deg, #0b0f17 0%, rgba(11,15,23,0.85) 55%, rgba(11,15,23,0.4) 100%), url('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&auto=format&fit=crop');">
                        <div class="slide-content">
                            <div class="slide-tag-group">
                                <span class="slide-tag-dot"></span>
                                <span class="slide-tag">ƯU ĐÃI ĐỘC QUYỀN</span>
                            </div>
                            <h2 class="slide-title">${banner.title}</h2>
                            <p class="slide-subdesc" style="margin-bottom: 24px;">Khám phá bộ sưu tập thời trang cao cấp với ưu đãi giảm giá đến <span style="color: #e5b842; font-weight: 800;">50%</span></p>
                            <a href="${pageContext.request.contextPath}/products" class="btn-banner-pill" style="display: inline-flex; align-items: center; gap: 10px; background: linear-gradient(135deg, #e5b842 0%, #c99726 100%); color: #0b0f19; font-weight: 900; font-size: 0.9rem; letter-spacing: 1.5px; padding: 12px 28px; border-radius: 50px; text-decoration: none; box-shadow: 0 6px 20px rgba(229, 184, 66, 0.4);">
                                <span>MUA NGAY</span>
                                <i class="fa-solid fa-arrow-right" style="margin-left: 4px;"></i>
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <!-- Fallback slide matching exact luxury design -->
                <div class="slide active" style="background-image: linear-gradient(90deg, #0b0f17 0%, rgba(11,15,23,0.85) 55%, rgba(11,15,23,0.4) 100%), url('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&auto=format&fit=crop');">
                    <div class="slide-content">
                        <div class="slide-tag-group">
                            <span class="slide-tag-dot"></span>
                            <span class="slide-tag">ƯU ĐÃI ĐỘC QUYỀN</span>
                        </div>
                        <h2 class="slide-title">Bộ Sưu Tập Mùa Hè<br><span style="color: #e5b842;">2026</span></h2>
                        <p class="slide-subdesc" style="margin-bottom: 24px;">Khám phá bộ sưu tập thời trang cao cấp với ưu đãi giảm giá đến <span style="color: #e5b842; font-weight: 800;">50%</span></p>
                        <a href="${pageContext.request.contextPath}/products" class="btn-banner-pill" style="display: inline-flex; align-items: center; gap: 10px; background: linear-gradient(135deg, #e5b842 0%, #c99726 100%); color: #0b0f19; font-weight: 900; font-size: 0.9rem; letter-spacing: 1.5px; padding: 12px 28px; border-radius: 50px; text-decoration: none; box-shadow: 0 6px 20px rgba(229, 184, 66, 0.4);">
                            <span>MUA NGAY</span>
                            <i class="fa-solid fa-arrow-right" style="margin-left: 4px;"></i>
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- Category Grid Section -->
<section class="container" style="margin-bottom: 60px;">
    <h3 class="section-title">Danh Mục Nổi Bật</h3>
    <p class="section-desc">Khám phá các dòng sản phẩm thời trang cao cấp phù hợp với phong cách của bạn</p>

    <div class="grid-categories">
        <c:forEach var="cat" items="${applicationScope.categories}">
            <a href="${pageContext.request.contextPath}/products?categoryId=${cat.id}" class="category-card">
                <div class="category-icon">
                    <c:choose>
                        <c:when test="${cat.categoryName.contains('Áo Nam') || cat.categoryName.contains('Áo Nữ') || cat.categoryName.contains('Áo')}">
                            <i class="fa-solid fa-shirt"></i>
                        </c:when>
                        <c:when test="${cat.categoryName.contains('Quần')}">
                            <i class="fa-solid fa-socks"></i>
                        </c:when>
                        <c:when test="${cat.categoryName.contains('Phụ Kiện') || cat.categoryName.contains('Phụ kiện')}">
                            <i class="fa-solid fa-glasses"></i>
                        </c:when>
                        <c:otherwise>
                            <i class="fa-solid fa-gem"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="category-title">${cat.categoryName}</div>
            </a>
        </c:forEach>
    </div>
</section>

<!-- Discount Products Section -->
<c:if test="${not empty discountProducts}">
    <section class="container">
        <h3 class="section-title">Khuyến Mãi Đặc Biệt</h3>
        <p class="section-desc">Cơ hội mua sắm thời trang hàng hiệu giá tốt nhất trong tuần</p>

        <div class="grid-products">
            <c:forEach var="prod" items="${discountProducts}">
                <a href="${pageContext.request.contextPath}/product-detail?id=${prod.id}" class="product-card" style="text-decoration: none; color: inherit; display: block; cursor: pointer;">
                    <span class="product-badge">SALE</span>
                    <div class="product-image-wrapper">
                        <img src="${prod.imageUrl}" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop';" alt="${prod.productName}">
                    </div>
                    <div class="product-info">
                        <div class="product-brand">${prod.brandID.brandName}</div>
                        <h4 class="product-name" style="margin: 0;">${prod.productName}</h4>
                        <div class="product-price-wrapper">
                            <span class="product-price discounted">
                                <fmt:formatNumber value="${prod.discountPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                            <span class="product-old-price">
                                <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                        </div>
                    </div>
                </a>
            </c:forEach>
        </div>
    </section>
</c:if>

<!-- New Arrivals Section -->
<section class="container">
    <h3 class="section-title">Hàng Mới Về</h3>
    <p class="section-desc">Bộ sưu tập thời trang độc quyền vừa ra mắt của thương hiệu</p>

    <div class="grid-products">
        <c:forEach var="prod" items="${newArrivals}">
            <a href="${pageContext.request.contextPath}/product-detail?id=${prod.id}" class="product-card" style="text-decoration: none; color: inherit; display: block; cursor: pointer;">
                <span class="product-badge" style="background-color: #3b82f6; color: #fff;">NEW</span>
                <div class="product-image-wrapper">
                    <img src="${prod.imageUrl}" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop';" alt="${prod.productName}">
                </div>
                <div class="product-info">
                    <div class="product-brand">${prod.brandID.brandName}</div>
                    <h4 class="product-name" style="margin: 0;">${prod.productName}</h4>
                    <div class="product-price-wrapper">
                        <c:choose>
                            <c:when test="${prod.discountPrice != null && prod.discountPrice > 0}">
                                <span class="product-price discounted">
                                    <fmt:formatNumber value="${prod.discountPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                                <span class="product-old-price">
                                    <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="product-price">
                                    <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </a>
        </c:forEach>
    </div>
</section>

<!-- Best Sellers Section -->
<section class="container" style="margin-bottom: 80px;">
    <h3 class="section-title">Bán Chạy Nhất</h3>
    <p class="section-desc">Những thiết kế được yêu thích và lựa chọn nhiều nhất bởi khách hàng</p>

    <div class="grid-products">
        <c:forEach var="prod" items="${bestSellers}">
            <a href="${pageContext.request.contextPath}/product-detail?id=${prod.id}" class="product-card" style="text-decoration: none; color: inherit; display: block; cursor: pointer;">
                <span class="product-badge" style="background-color: var(--accent); color: #0b0f19;">HOT</span>
                <div class="product-image-wrapper">
                    <img src="${prod.imageUrl}" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop';" alt="${prod.productName}">
                </div>
                <div class="product-info">
                    <div class="product-brand">${prod.brandID.brandName}</div>
                    <h4 class="product-name" style="margin: 0;">${prod.productName}</h4>
                    <div class="product-price-wrapper">
                        <c:choose>
                            <c:when test="${prod.discountPrice != null && prod.discountPrice > 0}">
                                <span class="product-price discounted">
                                    <fmt:formatNumber value="${prod.discountPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                                <span class="product-old-price">
                                    <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="product-price">
                                    <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </a>
        </c:forEach>
    </div>
</section>

<!-- Slider Script -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const slides = document.querySelectorAll(".hero-slider .slide");
        if (slides.length > 0) {
            slides[0].classList.add("active");
            if (slides.length > 1) {
                let currentSlide = 0;
                setInterval(() => {
                    slides[currentSlide].classList.remove("active");
                    currentSlide = (currentSlide + 1) % slides.length;
                    slides[currentSlide].classList.add("active");
                }, 5000);
            }
        }
    });
</script>

<%@ include file="/WEB-INF/views/footer.jsp" %>
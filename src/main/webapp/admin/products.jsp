<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Sản Phẩm - Admin Panel</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=3">
</head>
<body class="admin-layout">

    <!-- Sidebar Admin -->
    <aside class="admin-sidebar">
        <div class="logo" style="margin-bottom: 30px;">
            <i class="fa-solid fa-crown" style="color: var(--accent);"></i> PANEL ADMIN
        </div>
        <div style="color: var(--text-muted); font-size: 0.8rem; text-transform: uppercase; font-weight: 700; letter-spacing: 1px; margin-bottom: 12px;">
            QUẢN LÝ HỆ THỐNG
        </div>
        <nav class="admin-menu">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-menu-item">
                <i class="fa-solid fa-chart-pie"></i> Tổng quan
            </a>
            <a href="${pageContext.request.contextPath}/admin/products" class="admin-menu-item active">
                <i class="fa-solid fa-shirt"></i> Sản phẩm
            </a>
            <a href="${pageContext.request.contextPath}/admin/categories" class="admin-menu-item">
                <i class="fa-solid fa-list"></i> Danh mục
            </a>
            <a href="${pageContext.request.contextPath}/admin/orders" class="admin-menu-item">
                <i class="fa-solid fa-receipt"></i> Đơn hàng
            </a>
            <a href="${pageContext.request.contextPath}/admin/coupons" class="admin-menu-item">
                <i class="fa-solid fa-ticket"></i> Mã giảm giá
            </a>
            <a href="${pageContext.request.contextPath}/admin/users" class="admin-menu-item">
                <i class="fa-solid fa-users"></i> Người dùng
            </a>
            <a href="${pageContext.request.contextPath}/admin/statistics" class="admin-menu-item">
                <i class="fa-solid fa-chart-line"></i> Báo cáo thống kê
            </a>
            <a href="${pageContext.request.contextPath}/" class="admin-menu-item" style="margin-top: 30px; border-top: 1px solid var(--border-color); padding-top: 20px; color: var(--accent);">
                <i class="fa-solid fa-store"></i> Về Cửa Hàng
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="admin-menu-item" style="color: #ef4444;">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng Xuất
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="admin-main">
        <header style="background: transparent; border: none; padding: 0; margin-bottom: 30px; position: static;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 style="font-size: 2rem; font-weight: 800;">Quản Lý Sản Phẩm Thời Trang</h1>
                    <p style="color: var(--text-secondary);">Thêm mới, sửa đổi thông tin và quản lý danh mục hàng hóa</p>
                </div>
                <button class="btn btn-primary" onclick="openAddModal()">
                    <i class="fa-solid fa-plus"></i> Thêm Sản Phẩm Mới
                </button>
            </div>
        </header>

        <!-- Tìm kiếm lọc sản phẩm -->
        <form action="${pageContext.request.contextPath}/admin/products" method="GET" style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 18px; margin-bottom: 24px; display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)) 120px; gap: 14px; align-items: end;">
            <div>
                <label class="form-label" style="font-size: 0.85rem;">Từ khóa tìm kiếm</label>
                <input type="text" name="keyword" value="${param.keyword}" placeholder="Tên sản phẩm..." class="form-control">
            </div>
            <div>
                <label class="form-label" style="font-size: 0.85rem;">Danh mục</label>
                <select name="categoryId" class="form-control">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${param.categoryId == cat.id ? 'selected' : ''}>${cat.categoryName}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="form-label" style="font-size: 0.85rem;">Trạng thái</label>
                <select name="status" class="form-control">
                    <option value="">-- Tất cả --</option>
                    <option value="true" ${param.status == 'true' ? 'selected' : ''}>Đang bán</option>
                    <option value="false" ${param.status == 'false' ? 'selected' : ''}>Ngừng bán</option>
                </select>
            </div>
            <div>
                <button type="submit" class="btn btn-primary" style="width: 100%; height: 42px;">
                    <i class="fa-solid fa-magnifying-glass"></i> Lọc
                </button>
            </div>
        </form>

        <!-- Bảng Sản Phẩm -->
        <div style="background-color: var(--bg-secondary); border-radius: var(--radius-md); border: 1px solid var(--border-color); padding: 20px; overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse; text-align: left;">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border-color); color: var(--text-secondary);">
                        <th style="padding: 12px; width: 70px;">Hình ảnh</th>
                        <th style="padding: 12px;">Mã SP</th>
                        <th style="padding: 12px;">Tên Sản Phẩm</th>
                        <th style="padding: 12px;">Danh Mục</th>
                        <th style="padding: 12px;">Thương Hiệu</th>
                        <th style="padding: 12px;">Giá Bán</th>
                        <th style="padding: 12px;">Giá Giảm</th>
                        <th style="padding: 12px;">Trạng Thái</th>
                        <th style="padding: 12px; text-align: center;">Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty products}">
                            <c:forEach var="p" items="${products}">
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px;">
                                        <c:choose>
                                            <c:when test="${not empty p.thumbnail}">
                                                <img src="${p.thumbnail.startsWith('http') ? p.thumbnail : pageContext.request.contextPath.concat('/').concat(p.thumbnail)}" style="width: 48px; height: 58px; object-fit: cover; border-radius: 4px;">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/assets/images/placeholder.jpg" style="width: 48px; height: 58px; object-fit: cover; border-radius: 4px;">
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px; font-weight: 700; color: var(--accent);">#${p.id}</td>
                                    <td style="padding: 12px; font-weight: 600;">${p.productName}</td>
                                    <td style="padding: 12px; color: var(--text-secondary);">${p.categoryID.categoryName}</td>
                                    <td style="padding: 12px; color: var(--text-secondary);">${p.brandID != null ? p.brandID.brandName : 'Fashion'}</td>
                                    <td style="padding: 12px; font-weight: 700;">
                                        <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td style="padding: 12px; font-weight: 700; color: #ef4444;">
                                        <c:choose>
                                            <c:when test="${p.discountPrice != null}">
                                                <fmt:formatNumber value="${p.discountPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px;">
                                        <c:choose>
                                            <c:when test="${p.status}">
                                                <span style="color: #10b981; font-weight: 600;">● Đang bán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #ef4444; font-weight: 600;">● Ngừng bán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px; text-align: center; display: flex; gap: 8px; justify-content: center;">
                                        <button type="button" class="btn" style="background-color: #3b82f6; color: #fff; padding: 6px 12px; font-size: 0.85rem; border-radius: 4px;"
                                                data-id="${p.id}"
                                                data-name="<c:out value='${p.productName}'/>"
                                                data-catid="${p.categoryID.id}"
                                                data-brand="<c:out value='${p.brandID != null ? p.brandID.brandName : ""}'/>"
                                                data-price="${p.price}"
                                                data-discount="${p.discountPrice != null ? p.discountPrice : ''}"
                                                data-img="<c:out value='${p.thumbnail}'/>"
                                                data-desc="<c:out value='${p.description}'/>"
                                                onclick="openEditModalFromBtn(this)">
                                            <i class="fa-solid fa-pen-to-square"></i> Sửa
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/product/delete?id=${p.id}" class="btn" style="background-color: #ef4444; color: #fff; padding: 6px 12px; font-size: 0.85rem; text-decoration: none; border-radius: 4px;" onclick="return confirm('Bạn có chắc muốn xóa sản phẩm này?');">
                                            <i class="fa-solid fa-trash"></i> Xóa
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 30px; color: var(--text-secondary);">Không tìm thấy sản phẩm nào.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Modal Thêm / Sửa Sản Phẩm -->
    <div id="productModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); z-index: 9999; justify-content: center; align-items: center; padding: 20px;">
        <div style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-md); width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto; padding: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 id="modalTitle" style="font-size: 1.3rem; font-weight: 800;">Thêm Sản Phẩm Mới</h3>
                <button onclick="closeModal()" style="background: transparent; border: none; color: var(--text-secondary); font-size: 1.4rem; cursor: pointer;">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/products" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="id" id="prodId">
                <div class="form-group" style="margin-bottom: 14px;">
                    <label class="form-label">Tên Sản Phẩm (*)</label>
                    <input type="text" name="name" id="prodName" class="form-control" required>
                </div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                    <div>
                        <label class="form-label">Danh Mục</label>
                        <select name="categoryId" id="prodCat" class="form-control" style="background-color: #181f2a; color: #ffffff; border: 1px solid var(--border-color); padding: 10px;">
                            <c:forEach var="c" items="${categories}">
                                <option value="${c.id}" style="background-color: #181f2a; color: #ffffff; padding: 10px;">${c.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="form-label">Thương Hiệu</label>
                        <input type="text" name="brandName" id="prodBrand" list="brandList" class="form-control" placeholder="Nhập tên thương hiệu..." style="background-color: #181f2a; color: #ffffff; border: 1px solid var(--border-color);">
                        <datalist id="brandList">
                            <c:forEach var="b" items="${applicationScope.brands}">
                                <option value="${b.brandName}"></option>
                            </c:forEach>
                            <option value="Nike"></option>
                            <option value="Adidas"></option>
                            <option value="Puma"></option>
                            <option value="Uniqlo"></option>
                            <option value="Zara"></option>
                            <option value="Gucci"></option>
                        </datalist>
                    </div>
                </div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                    <div>
                        <label class="form-label">Giá Bán (VNĐ) (*)</label>
                        <input type="number" step="any" name="price" id="prodPrice" class="form-control" required>
                    </div>
                    <div>
                        <label class="form-label">Giá Khuyến Mãi (VNĐ)</label>
                        <input type="number" step="any" name="discountPrice" id="prodDiscount" class="form-control">
                    </div>
                </div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                    <div>
                        <label class="form-label">Tùy Chọn Màu Sắc</label>
                        <input type="text" name="customColors" id="prodColors" class="form-control" placeholder="Trắng, Đen, Đỏ, Xanh..." value="Trắng, Đen" style="background-color: #181f2a; color: #ffffff; border: 1px solid var(--border-color);">
                    </div>
                    <div>
                        <label class="form-label">Tùy Chọn Size</label>
                        <input type="text" name="customSizes" id="prodSizes" class="form-control" placeholder="S, M, L, XL, 2XL, 3XL... hoặc 38, 39, 40" value="M, L, XL, 2XL, 3XL" style="background-color: #181f2a; color: #ffffff; border: 1px solid var(--border-color);">
                    </div>
                </div>
                <div class="form-group" style="margin-bottom: 12px;">
                    <label class="form-label">Link Hình Ảnh</label>
                    <textarea name="imageUrl" id="prodImg" class="form-control" rows="2" placeholder="https://link-anh-1.jpg&#10;https://link-anh-2.jpg" style="background-color: #181f2a; color: #ffffff; border: 1px solid var(--border-color);"></textarea>
                </div>
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label">Tải File Ảnh Từ Máy Tính</label>
                    <input type="file" name="imageFile" class="form-control" accept="image/*" multiple style="background-color: #181f2a; color: #ffffff; border: 1px solid var(--border-color);">
                </div>
                <div class="form-group" style="margin-bottom: 20px;">
                    <label class="form-label">Mô Tả Sản Phẩm</label>
                    <textarea name="description" id="prodDesc" class="form-control" rows="3"></textarea>
                </div>
                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn" style="background: rgba(255,255,255,0.1); color: #fff;" onclick="closeModal()">Đóng</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu Sản Phẩm</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openAddModal() {
            document.getElementById('modalTitle').innerText = 'Thêm Sản Phẩm Mới';
            document.getElementById('prodId').value = '';
            document.getElementById('prodName').value = '';
            document.getElementById('prodPrice').value = '';
            document.getElementById('prodDiscount').value = '';
            document.getElementById('prodImg').value = '';
            document.getElementById('prodDesc').value = '';
            document.getElementById('productModal').style.display = 'flex';
        }

        function openEditModalFromBtn(btn) {
            var id = btn.getAttribute('data-id');
            var name = btn.getAttribute('data-name');
            var catId = btn.getAttribute('data-catid');
            var brand = btn.getAttribute('data-brand');
            var price = btn.getAttribute('data-price');
            var discount = btn.getAttribute('data-discount');
            var img = btn.getAttribute('data-img');
            var desc = btn.getAttribute('data-desc');

            document.getElementById('modalTitle').innerText = 'Cập Nhật Sản Phẩm #' + id;
            document.getElementById('prodId').value = id;
            document.getElementById('prodName').value = name || '';
            document.getElementById('prodCat').value = catId || '1';
            document.getElementById('prodBrand').value = brand || '';
            document.getElementById('prodPrice').value = price || '';
            document.getElementById('prodDiscount').value = (discount && parseFloat(discount) > 0) ? discount : '';
            document.getElementById('prodImg').value = img || '';
            document.getElementById('prodDesc').value = desc || '';
            document.getElementById('productModal').style.display = 'flex';
        }

        function openEditModal(id, name, catId, brandId, price, discount, img, desc) {
            document.getElementById('modalTitle').innerText = 'Cập Nhật Sản Phẩm #' + id;
            document.getElementById('prodId').value = id;
            document.getElementById('prodName').value = name || '';
            document.getElementById('prodCat').value = catId || '1';
            document.getElementById('prodBrand').value = brandId || '';
            document.getElementById('prodPrice').value = price || '';
            document.getElementById('prodDiscount').value = (discount > 0) ? discount : '';
            document.getElementById('prodImg').value = img || '';
            document.getElementById('prodDesc').value = desc || '';
            document.getElementById('productModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('productModal').style.display = 'none';
        }
    </script>
</body>
</html>

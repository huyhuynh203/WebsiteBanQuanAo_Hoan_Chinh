<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Người Dùng - Admin Panel</title>
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
            <a href="${pageContext.request.contextPath}/admin/products" class="admin-menu-item">
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
            <a href="${pageContext.request.contextPath}/admin/users" class="admin-menu-item active">
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
                    <h1 style="font-size: 2rem; font-weight: 800;">Quản Lý Người Dùng & Nhân Viên</h1>
                    <p style="color: var(--text-secondary);">Danh sách tài khoản thành viên và phân quyền trong hệ thống</p>
                </div>
            </div>
        </header>

        <!-- Form Tìm Kiếm Lọc Người Dùng -->
        <form action="${pageContext.request.contextPath}/admin/users" method="GET" style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 18px; margin-bottom: 24px; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)) 120px; gap: 14px; align-items: end;">
            <div>
                <label class="form-label" style="font-size: 0.85rem;">Họ tên / Tên đăng nhập</label>
                <input type="text" name="keyword" value="${keyword}" placeholder="Nhập tên..." class="form-control">
            </div>
            <div>
                <label class="form-label" style="font-size: 0.85rem;">Địa chỉ Email</label>
                <input type="text" name="email" value="${email}" placeholder="Nhập email..." class="form-control">
            </div>
            <div>
                <label class="form-label" style="font-size: 0.85rem;">Trạng Thái Tài Khoản</label>
                <select name="status" class="form-control">
                    <option value="">-- Tất cả trạng thái --</option>
                    <option value="true" ${status == 'true' ? 'selected' : ''}>Hoạt động (Active)</option>
                    <option value="false" ${status == 'false' ? 'selected' : ''}>Đã khóa (Locked)</option>
                </select>
            </div>
            <div>
                <button type="submit" class="btn btn-primary" style="width: 100%; height: 42px;">
                    <i class="fa-solid fa-magnifying-glass"></i> Tìm Kiếm
                </button>
            </div>
        </form>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
            <span style="color: var(--text-secondary);">Tổng số người dùng: <strong>${totalUsers != null ? totalUsers : users.size()}</strong></span>
        </div>

        <!-- Bảng Danh Sách Người Dùng -->
        <div style="background-color: var(--bg-secondary); border-radius: var(--radius-md); border: 1px solid var(--border-color); padding: 20px; overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse; text-align: left;">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border-color); color: var(--text-secondary);">
                        <th style="padding: 12px;">Mã TV (#)</th>
                        <th style="padding: 12px;">Họ và Tên</th>
                        <th style="padding: 12px;">Email</th>
                        <th style="padding: 12px;">Số Điện Thoại</th>
                        <th style="padding: 12px;">Vai Trò</th>
                        <th style="padding: 12px;">Trạng Thái</th>
                        <th style="padding: 12px; text-align: center;">Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty users}">
                            <c:forEach var="u" items="${users}">
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 14px; font-weight: 700; color: var(--accent);">#${u.id}</td>
                                    <td style="padding: 14px; font-weight: 600;">${u.fullName}</td>
                                    <td style="padding: 14px; color: var(--text-secondary);">${u.email}</td>
                                    <td style="padding: 14px; color: var(--text-secondary);">${u.phone != null ? u.phone : '-'}</td>
                                    <td style="padding: 14px;">
                                        <c:choose>
                                            <c:when test="${u.email == 'admin@gmail.com'}">
                                                <span style="background: rgba(212, 175, 55, 0.2); color: #e5b842; padding: 6px 12px; border-radius: 6px; font-weight: 800; font-size: 0.85rem; border: 1px solid rgba(229, 184, 66, 0.4); display: inline-block;">👑 SUPER ADMIN</span>
                                            </c:when>
                                            <c:otherwise>
                                                <select onchange="changeUserRole(${u.id}, this.value, '${u.fullName}')" 
                                                        style="background: #181f2a; color: ${u.roleID != null && u.roleID.roleName == 'ADMIN' ? '#e5b842' : '#3b82f6'}; border: 1px solid var(--border-color); border-radius: 6px; padding: 6px 12px; font-weight: 700; font-size: 0.85rem; cursor: pointer; outline: none;">
                                                    <option value="CUSTOMER" ${u.roleID != null && u.roleID.roleName == 'CUSTOMER' ? 'selected' : ''} style="background-color: #181f2a; color: #3b82f6;">👤 CUSTOMER</option>
                                                    <option value="ADMIN" ${u.roleID != null && u.roleID.roleName == 'ADMIN' ? 'selected' : ''} style="background-color: #181f2a; color: #e5b842;">👑 ADMIN</option>
                                                </select>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 14px;">
                                        <c:choose>
                                            <c:when test="${u.status}">
                                                <span style="color: #10b981; font-weight: 600;">● Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #ef4444; font-weight: 600;">● Đã khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 14px; text-align: center;">
                                        <c:choose>
                                            <c:when test="${u.id <= 6 || u.email == 'admin@gmail.com'}">
                                                <span style="color: var(--text-muted); font-size: 0.82rem; font-style: italic;"><i class="fa-solid fa-lock"></i> Mặc định</span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/admin/users?action=delete&id=${u.id}" 
                                                   class="btn" 
                                                   style="background-color: #ef4444; color: #fff; padding: 6px 14px; font-size: 0.85rem; text-decoration: none; border-radius: 6px; display: inline-flex; align-items: center; gap: 6px;"
                                                   onclick="return confirm('Bạn có chắc chắn muốn XÓA VĨNH VIỄN tài khoản mới #${u.id} (${u.fullName}) khỏi hệ thống?');">
                                                    <i class="fa-solid fa-trash"></i> Xóa
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 30px; color: var(--text-secondary);">Không tìm thấy người dùng phù hợp.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </main>
    <script>
        function changeUserRole(userId, newRole, fullName) {
            if (confirm('Bạn có chắc chắn muốn đổi vai trò của #' + userId + ' (' + fullName + ') thành ' + newRole + '?')) {
                window.location.href = '${pageContext.request.contextPath}/admin/users?action=change-role&id=' + userId + '&role=' + newRole;
            } else {
                location.reload();
            }
        }
    </script>
</body>
</html>

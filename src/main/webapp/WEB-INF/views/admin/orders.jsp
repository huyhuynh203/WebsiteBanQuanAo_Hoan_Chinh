<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Đơn Hàng - Admin Panel</title>
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
            <a href="${pageContext.request.contextPath}/admin/orders" class="admin-menu-item active">
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
                    <h1 style="font-size: 2rem; font-weight: 800;">Quản Lý Hóa Đơn & Đơn Hàng</h1>
                    <p style="color: var(--text-secondary);">Theo dõi tình trạng đơn đặt hàng và xử lý vận chuyển</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/statistics" class="btn btn-primary">
                        <i class="fa-solid fa-chart-line"></i> Báo Cáo Doanh Thu
                    </a>
                </div>
            </div>
        </header>

        <c:if test="${param.success == 'status_updated'}">
            <div style="background-color: #065f46; color: #34d399; padding: 14px; border-radius: var(--radius-sm); margin-bottom: 20px; border: 1px solid #059669;">
                <i class="fa-solid fa-circle-check"></i> Đã cập nhật tình trạng đơn hàng thành công!
            </div>
        </c:if>
        <c:if test="${param.success == 'cancel_order'}">
            <div style="background-color: #7f1d1d; color: #fca5a5; padding: 14px; border-radius: var(--radius-sm); margin-bottom: 20px; border: 1px solid #dc2626;">
                <i class="fa-solid fa-circle-check"></i> Đã hủy đơn hàng thành công!
            </div>
        </c:if>

        <!-- Bảng Danh Sách Đơn Hàng -->
        <div style="background-color: var(--bg-secondary); border-radius: var(--radius-md); border: 1px solid var(--border-color); padding: 20px; overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse; text-align: left;">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border-color); color: var(--text-secondary);">
                        <th style="padding: 12px;">Mã Đơn (#)</th>
                        <th style="padding: 12px;">Khách Hàng</th>
                        <th style="padding: 12px;">Ngày Tạo</th>
                        <th style="padding: 12px;">Tổng Tiền</th>
                        <th style="padding: 12px;">Phương Thức</th>
                        <th style="padding: 12px;">Trạng Thái</th>
                        <th style="padding: 12px; text-align: center;">Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty orders}">
                            <c:forEach var="o" items="${orders}">
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 14px; font-weight: 700; color: var(--accent);">#${o.id}</td>
                                    <td style="padding: 14px; font-weight: 600;">
                                        ${o.userID != null ? o.userID.fullName : (o.fullname != null ? o.fullname : 'Khách hàng')}
                                    </td>
                                    <td style="padding: 14px; color: var(--text-secondary);">${o.orderDate}</td>
                                    <td style="padding: 14px; font-weight: 700; color: #ef4444;">
                                        <fmt:formatNumber value="${o.finalAmount != null ? o.finalAmount : o.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td style="padding: 14px;">
                                        <span class="badge" style="background: rgba(255,255,255,0.08); padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;">${o.paymentMethod}</span>
                                    </td>
                                    <td style="padding: 14px;">
                                        <c:choose>
                                            <c:when test="${o.orderStatus == 'DELIVERED' || o.orderStatus == 'COMPLETED'}">
                                                <span style="color: #10b981; background: rgba(16, 185, 129, 0.15); padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; display: inline-block;">● Đã giao / Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'CONFIRMED' || o.orderStatus == 'PAID'}">
                                                <span style="color: #3b82f6; background: rgba(59, 130, 246, 0.15); padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; display: inline-block;">● Đã xác nhận</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'SHIPPING'}">
                                                <span style="color: #8b5cf6; background: rgba(139, 92, 246, 0.15); padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; display: inline-block;">● Đang giao hàng</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'CANCELLED'}">
                                                <span style="color: #ef4444; background: rgba(239, 68, 68, 0.15); padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; display: inline-block;">● Đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #f59e0b; background: rgba(245, 158, 11, 0.15); padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 0.85rem; display: inline-block;">● Chờ xử lý</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 14px; text-align: center; display: flex; gap: 8px; justify-content: center; align-items: center;">
                                        <!-- Nút Xem Chi Tiết Hóa Đơn -->
                                        <a href="${pageContext.request.contextPath}/admin/orders/detail?id=${o.id}" 
                                           class="btn" 
                                           style="background-color: #3b82f6; color: #fff; padding: 6px 12px; font-size: 0.85rem; text-decoration: none; border-radius: 6px; display: inline-flex; align-items: center; gap: 5px;">
                                            <i class="fa-solid fa-eye"></i> Chi Tiết
                                        </a>

                                        <!-- Thẻ Sổ Chọn Cập Nhật Trạng Thái Đơn Hàng -->
                                        <select onchange="updateOrderStatus(${o.id}, this.value)" 
                                                style="background: #181f2a; color: ${o.orderStatus == 'CANCELLED' ? '#ef4444' : (o.orderStatus == 'DELIVERED' || o.orderStatus == 'COMPLETED' ? '#10b981' : (o.orderStatus == 'CONFIRMED' ? '#3b82f6' : (o.orderStatus == 'SHIPPING' ? '#8b5cf6' : '#f59e0b')))}; border: 1px solid var(--border-color); border-radius: 6px; padding: 6px 10px; font-weight: 700; font-size: 0.85rem; cursor: pointer; outline: none;">
                                            <option value="PENDING" ${o.orderStatus == 'PENDING' ? 'selected' : ''} style="background-color: #181f2a; color: #f59e0b;">⏳ Chờ xử lý (PENDING)</option>
                                            <option value="CONFIRMED" ${o.orderStatus == 'CONFIRMED' ? 'selected' : ''} style="background-color: #181f2a; color: #3b82f6;">✅ Đã xác nhận (CONFIRMED)</option>
                                            <option value="SHIPPING" ${o.orderStatus == 'SHIPPING' ? 'selected' : ''} style="background-color: #181f2a; color: #8b5cf6;">🚚 Đang giao hàng (SHIPPING)</option>
                                            <option value="DELIVERED" ${o.orderStatus == 'DELIVERED' || o.orderStatus == 'COMPLETED' ? 'selected' : ''} style="background-color: #181f2a; color: #10b981;">🎉 Đã giao / Hoàn thành (DELIVERED)</option>
                                            <option value="CANCELLED" ${o.orderStatus == 'CANCELLED' ? 'selected' : ''} style="background-color: #181f2a; color: #ef4444;">❌ Hủy đơn hàng (CANCELLED)</option>
                                        </select>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 30px; color: var(--text-secondary);">Chưa có đơn hàng nào.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </main>

    <script>
        function updateOrderStatus(orderId, newStatus) {
            if (confirm('Bạn có chắc chắn muốn chuyển trạng thái hóa đơn #' + orderId + ' thành ' + newStatus + '?')) {
                window.location.href = '${pageContext.request.contextPath}/admin/orders?action=status&orderId=' + orderId + '&status=' + newStatus;
            } else {
                location.reload();
            }
        }
    </script>
</body>
</html>

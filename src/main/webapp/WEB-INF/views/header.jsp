<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Clothing Store - Luxury Clothing Brand</title>

    <!-- Link FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Link Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=2">
</head>
<body>
<header>
    <div class="container navbar">
        <a href="${pageContext.request.contextPath}/" class="logo">
            Fashion Shop
        </a>

        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/" class="${pageContext.request.requestURI.endsWith('index.jsp') || pageContext.request.requestURI.endsWith('home') ? 'active' : ''}">Trang Chủ</a>
            <a href="${pageContext.request.contextPath}/products" class="${pageContext.request.requestURI.contains('products.jsp') ? 'active' : ''}">Sản Phẩm</a>

            <%-- SỬA LỖI 1: Trỏ qua roleID -> tên field chứa vai trò trong class Role (ví dụ: roleName hoặc name) --%>
            <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.roleID.roleName == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/dashboard" style="color: #ef4444; font-weight: 700;">Quản Trị</a>
            </c:if>
        </nav>

        <div class="nav-actions">
            <!-- Giỏ hàng -->
            <c:if test="${sessionScope.currentUser != null}">
                <a href="${pageContext.request.contextPath}/cart" class="action-btn" title="Giỏ hàng">
                    <i class="fa-solid fa-bag-shopping fa-lg"></i>
                </a>

                <a href="${pageContext.request.contextPath}/orders" class="action-btn" title="Đơn hàng của tôi">
                    <i class="fa-solid fa-receipt fa-lg"></i>
                </a>
            </c:if>

            <!-- Tài khoản -->
            <c:choose>
                <c:when test="${sessionScope.currentUser != null}">
                    <a href="${pageContext.request.contextPath}/profile" class="username-display" style="text-decoration: none; display: flex; align-items: center; gap: 8px; color: var(--text-primary); font-weight: 500;">
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser.avatar}">
                                <img src="${sessionScope.currentUser.avatar}" alt="Avatar" style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover; border: 1px solid var(--accent);" onerror="this.src='https://cdn-icons-png.flaticon.com/512/149/149071.png'">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-regular fa-user"></i>
                            </c:otherwise>
                        </c:choose>
                            <%-- SỬA LỖI 2: Đổi fullname -> fullName cho đúng với Entity User (getFullName) --%>
                            ${sessionScope.currentUser.fullName}
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.85rem;">
                        Đăng Xuất
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="padding: 8px 16px; font-size: 0.9rem;">
                        Đăng Nhập
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
<main style="min-height: 70vh;">
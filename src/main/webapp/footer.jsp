<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
    </main>
    
    <footer>
        <div class="container footer-grid">
            <div>
                <a href="${pageContext.request.contextPath}/" class="logo" style="margin-bottom: 20px; display: inline-block;">
                    Fashion Shop
                </a>
                <p style="color: var(--text-secondary); font-size: 0.95rem; margin-bottom: 20px;">
                    Thương hiệu thời trang cao cấp mang phong cách tối giản, sang trọng và hiện đại. Kiến tạo xu hướng thời trang mới.
                </p>
                <div style="display: flex; gap: 15px; font-size: 1.2rem; color: var(--accent);">
                    <a href="#"><i class="fa-brands fa-facebook"></i></a>
                    <a href="#"><i class="fa-brands fa-instagram"></i></a>
                    <a href="#"><i class="fa-brands fa-tiktok"></i></a>
                    <a href="#"><i class="fa-brands fa-youtube"></i></a>
                </div>
            </div>
            
            <div>
                <h4 class="footer-title">Khám Phá</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/products?categoryId=1">Thời Trang Nam</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?categoryId=3">Thời Trang Nữ</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?sortBy=newest">Hàng Mới Về</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?sortBy=best_seller">Bán Chạy Nhất</a></li>
                </ul>
            </div>
            
            <div>
                <h4 class="footer-title">Hỗ Trợ</h4>
                <ul class="footer-links">
                    <li><a href="#">Hướng Dẫn Chọn Size</a></li>
                    <li><a href="#">Chính Sách Đổi Trả</a></li>
                    <li><a href="#">Chính Sách Vận Chuyển</a></li>
                    <li><a href="#">Liên Hệ Hỗ Trợ</a></li>
                </ul>
            </div>
            
            <div>
                <h4 class="footer-title">Đăng Ký Nhận Tin</h4>
                <p style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 16px;">
                    Đăng ký để nhận thông tin về sản phẩm mới và các chương trình khuyến mãi sớm nhất.
                </p>
                <div style="display: flex; gap: 10px;">
                    <input type="email" placeholder="Email của bạn..." class="form-control" style="flex: 1; padding: 8px 12px; font-size: 0.9rem;">
                    <button class="btn btn-primary" style="padding: 8px 16px; font-size: 0.9rem;">Gửi</button>
                </div>
            </div>
        </div>
    </footer>
</body>
</html>

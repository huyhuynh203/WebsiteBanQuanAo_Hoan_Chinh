<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="container" style="padding-top: 40px; padding-bottom: 60px;">
    <div style="text-align: center; margin-bottom: 36px;">
        <h2 style="font-size: 2.2rem; font-weight: 800; margin-bottom: 8px;">Thông Tin Cá Nhân</h2>
        <p style="color: var(--text-secondary); max-width: 500px; margin: 0 auto;">Xem, quản lý và cập nhật thông tin cá nhân của bạn</p>
    </div>

    <!-- Thông báo kết quả -->
    <c:if test="${param.success == 'update_ok'}">
        <div class="form-success" style="margin-bottom: 24px;">Cập nhật thông tin cá nhân thành công!</div>
    </c:if>
    <c:if test="${param.error == 'update_failed'}">
        <div class="form-error" style="margin-bottom: 24px;">Cập nhật thất bại. Vui lòng kiểm tra lại thông tin.</div>
    </c:if>
    <c:if test="${param.error == 'missing_fullname'}">
        <div class="form-error" style="margin-bottom: 24px;">Họ và tên không được để trống!</div>
    </c:if>

    <div class="cart-layout" style="grid-template-columns: 1fr 2fr; gap: 30px; align-items: start;">
        
        <!-- Cột Trái: Ảnh đại diện & Thông tin nhanh -->
        <div style="background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 32px; text-align: center; box-shadow: var(--shadow-md);">
            <div style="position: relative; width: 140px; height: 140px; margin: 0 auto 20px; border-radius: 50%; padding: 4px; background: linear-gradient(135deg, var(--accent), #d97706); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.2);">
                <img id="avatar-preview" src="${not empty sessionScope.currentUser.avatar ? sessionScope.currentUser.avatar : 'https://cdn-icons-png.flaticon.com/512/149/149071.png'}" 
                     alt="Avatar" style="width: 132px; height: 132px; border-radius: 50%; object-fit: cover; background-color: var(--bg-primary); display: block;" 
                     onerror="this.src='https://cdn-icons-png.flaticon.com/512/149/149071.png'">
            </div>
            
            <h3 style="font-size: 1.3rem; font-weight: 700; margin-bottom: 6px; color: var(--text-primary);">${sessionScope.currentUser.fullname}</h3>
            <p style="color: var(--accent); font-weight: 600; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px;">
                ${sessionScope.currentUser.role == 'ADMIN' ? 'Quản Trị Viên' : 'Khách Hàng'}
            </p>

            <div style="border-top: 1px solid var(--border-color); padding-top: 20px; text-align: left; font-size: 0.9rem; display: flex; flex-direction: column; gap: 12px; color: var(--text-secondary);">
                <div>
                    <i class="fa-regular fa-envelope" style="width: 20px; color: var(--accent);"></i> ${sessionScope.currentUser.email}
                </div>
                <div>
                    <i class="fa-solid fa-user-tag" style="width: 20px; color: var(--accent);"></i> @${sessionScope.currentUser.username}
                </div>
                <div>
                    <i class="fa-regular fa-calendar" style="width: 20px; color: var(--accent);"></i> Đăng ký: <fmt:formatDate value="${sessionScope.currentUser.createdAt}" pattern="dd/MM/yyyy"/>
                </div>
            </div>
        </div>

        <!-- Cột Phải: Form cập nhật thông tin -->
        <div style="background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 32px; box-shadow: var(--shadow-md);">
            <h3 style="font-size: 1.3rem; font-weight: 700; margin-bottom: 24px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; color: var(--text-primary);">
                Thông tin chi tiết
            </h3>

            <form action="${pageContext.request.contextPath}/profile/update" method="POST" enctype="multipart/form-data">
                <div class="form-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                    <div>
                        <label style="display: block; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px; font-weight: 600;">Tên tài khoản (Không thể đổi)</label>
                        <input type="text" value="${sessionScope.currentUser.username}" readonly 
                               style="width: 100%; padding: 12px; background-color: rgba(255,255,255,0.03); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-secondary); cursor: not-allowed; font-size: 0.95rem;">
                    </div>
                    <div>
                        <label style="display: block; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px; font-weight: 600;">Email (Không thể đổi)</label>
                        <input type="text" value="${sessionScope.currentUser.email}" readonly 
                               style="width: 100%; padding: 12px; background-color: rgba(255,255,255,0.03); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-secondary); cursor: not-allowed; font-size: 0.95rem;">
                    </div>
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px; font-weight: 600;">Họ và Tên</label>
                    <input type="text" name="fullname" value="${sessionScope.currentUser.fullname}" required 
                           style="width: 100%; padding: 12px; background-color: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-primary); font-size: 0.95rem;">
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px; font-weight: 600;">Số Điện Thoại</label>
                    <input type="text" name="phone" value="${sessionScope.currentUser.phone}" 
                           style="width: 100%; padding: 12px; background-color: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-primary); font-size: 0.95rem;">
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px; font-weight: 600;">Địa Chỉ Nhận Hàng</label>
                    <textarea name="address" rows="3" style="width: 100%; padding: 12px; background-color: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-primary); font-size: 0.95rem; resize: vertical;">${sessionScope.currentUser.address}</textarea>
                </div>

                <div style="margin-bottom: 28px;">
                    <label style="display: block; font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 8px; font-weight: 600;">Ảnh Đại Diện (Avatar)</label>
                    
                    <div style="display: flex; gap: 10px; margin-bottom: 12px;">
                        <button type="button" id="btn-tab-url" onclick="switchAvatarMode('url')" style="padding: 6px 14px; font-size: 0.8rem; border-radius: 6px; border: 1px solid var(--accent); background: var(--accent); color: #000; font-weight: 700; cursor: pointer;">Dán Link URL</button>
                        <button type="button" id="btn-tab-file" onclick="switchAvatarMode('file')" style="padding: 6px 14px; font-size: 0.8rem; border-radius: 6px; border: 1px solid var(--border-color); background: var(--bg-tertiary); color: var(--text-primary); font-weight: 600; cursor: pointer;">Tải Ảnh Từ Máy Tính</button>
                    </div>

                    <!-- Ô 1: Dán link URL -->
                    <div id="box-avatar-url">
                        <input type="text" id="avatar-input" name="avatar" value="${sessionScope.currentUser.avatar}" 
                               placeholder="Dán link ảnh đại diện từ bên ngoài (https://...)" 
                               oninput="updateAvatarPreview(this.value)"
                               style="width: 100%; padding: 12px; background-color: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-primary); font-size: 0.95rem;">
                        <p style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 6px;">Bạn có thể dán đường dẫn ảnh bất kỳ từ internet vào đây.</p>
                    </div>

                    <!-- Ô 2: Tải file từ máy tính -->
                    <div id="box-avatar-file" style="display: none;">
                        <input type="file" id="avatar-file-input" name="avatarFile" accept="image/*" 
                               onchange="previewAvatarFile(this)"
                               style="width: 100%; padding: 10px; background-color: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); color: var(--text-primary); font-size: 0.95rem;">
                        <p style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 6px;">Chọn file ảnh đại diện từ máy tính của bạn (JPG, PNG, WEBP...).</p>
                    </div>
                </div>

                <div style="text-align: right; border-top: 1px solid var(--border-color); padding-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="padding: 12px 30px; font-size: 0.95rem;">
                        <i class="fa-solid fa-save" style="margin-right: 6px;"></i> Lưu Thay Đổi
                    </button>
                </div>
            </form>
        </div>

    </div>
</div>

<script>
    function switchAvatarMode(mode) {
        if (mode === 'url') {
            document.getElementById('box-avatar-url').style.display = 'block';
            document.getElementById('box-avatar-file').style.display = 'none';
            document.getElementById('btn-tab-url').style.background = 'var(--accent)';
            document.getElementById('btn-tab-url').style.color = '#000';
            document.getElementById('btn-tab-file').style.background = 'var(--bg-tertiary)';
            document.getElementById('btn-tab-file').style.color = 'var(--text-primary)';
        } else {
            document.getElementById('box-avatar-url').style.display = 'none';
            document.getElementById('box-avatar-file').style.display = 'block';
            document.getElementById('btn-tab-file').style.background = 'var(--accent)';
            document.getElementById('btn-tab-file').style.color = '#000';
            document.getElementById('btn-tab-url').style.background = 'var(--bg-tertiary)';
            document.getElementById('btn-tab-url').style.color = 'var(--text-primary)';
        }
    }

    function updateAvatarPreview(url) {
        var preview = document.getElementById('avatar-preview');
        if (url && url.trim() !== '') {
            preview.src = url;
        } else {
            preview.src = 'https://cdn-icons-png.flaticon.com/512/149/149071.png';
        }
    }

    function previewAvatarFile(input) {
        var preview = document.getElementById('avatar-preview');
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
            }
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>

<%@ include file="/WEB-INF/views/footer.jsp" %>

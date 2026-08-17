package poly.java.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.Nationalized;

import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "Users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "UserID", nullable = false)
    private Integer id;

    // ĐÃ SỬA: Chuyển FetchType.LAZY thành FetchType.EAGER để luôn nạp Role cùng User
    @NotNull
    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "RoleID", nullable = false)
    private Role roleID;

    @Size(max = 100)
    @NotNull
    @Nationalized
    @Column(name = "FullName", nullable = false, length = 100)
    private String fullName;

    @Size(max = 100)
    @NotNull
    @Column(name = "Email", nullable = false, length = 100)
    private String email;

    @Size(max = 15)
    @Column(name = "Phone", length = 15)
    private String phone;

    @Size(max = 255)
    @NotNull
    @Column(name = "Password", nullable = false)
    private String password;

    @Column(name = "Gender")
    private Boolean gender;

    @Column(name = "DateOfBirth")
    private LocalDate dateOfBirth;

    @Size(max = 255)
    @Column(name = "Avatar")
    private String avatar;

    @ColumnDefault("1")
    @Column(name = "Status")
    private Boolean status;

    @ColumnDefault("getdate()")
    @Column(name = "CreatedAt")
    private Instant createdAt;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Role getRoleID() {
        return roleID;
    }

    public void setRoleID(Role roleID) {
        this.roleID = roleID;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Boolean getGender() {
        return gender;
    }

    public void setGender(Boolean gender) {
        this.gender = gender;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public Boolean getStatus() {
        return status;
    }

    public void setStatus(Boolean status) {
        this.status = status;
    }

    public java.util.Date getCreatedAt() {
        return createdAt != null ? java.util.Date.from(createdAt) : null;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public String getRole() {
        if (this.roleID != null) {
            return this.roleID.getRoleName();
        }
        return null;
    }

    public String getFullname() {
        return fullName;
    }

    public String getUsername() {
        if (email != null && email.contains("@")) {
            return email.split("@")[0];
        }
        return email != null ? email : "";
    }

    public String getAddress() {
        if (id != null) {
            try {
                poly.java.DAO.AddressDAO addressDAO = new poly.java.DAO.Impl.AddressDAOImpl();
                poly.java.Entity.Address addr = addressDAO.findDefaultAddress(id);
                if (addr != null && addr.getAddressDetail() != null) {
                    return addr.getAddressDetail();
                }
            } catch (Exception ignored) {}
        }
        return "";
    }
}
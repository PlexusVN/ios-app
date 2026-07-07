# Sensi Ultralock - iOS

Ứng dụng tối ưu hóa cấu hình Free Fire — bản iOS (SwiftUI).

---

## 🚀 Cách 1: Build + chạy trên iPhone thật bằng Xcode (không cần $99)

> **Yêu cầu:** Máy Mac + iPhone + Apple ID miễn phí

### Bước 1: Mở project

```bash
cd "D:\ADR - IOS APP\SensiUltralock"

# Cài XcodeGen (nếu chưa có)
brew install xcodegen

# Tạo file .xcodeproj
xcodegen generate

# Mở Xcode
open SensiUltralock.xcodeproj
```

### Bước 2: Cấu hình Signing

Trong Xcode:
1. Chọn **SensiUltralock** project (thanh bên trái)
2. Chọn **Target** → **SensiUltralock**
3. Chọn tab **Signing & Capabilities**
4. Tick **Automatically manage signing**
5. Ở mục **Team** → chọn **Add Account...**
   - Đăng nhập Apple ID của bạn (miễn phí)
   - Đóng lại và chọn team vừa thêm

### Bước 3: Chạy

1. Cắm iPhone vào máy Mac qua cáp USB
2. Trên thanh toolbar Xcode, chọn **iPhone** (thay vì Simulator)
3. Nhấn nút **▶ Run** (hoặc Cmd + R)

✅ App sẽ được cài vào iPhone và tự động mở.

> ⚠️ **Hết hạn sau 7 ngày:** Apple yêu cầu ký lại. Chỉ cần build lại lần nữa (Cmd + R) là app hoạt động tiếp.

---

## 🌐 Cách 2: Build trên GitHub Actions (không cần máy Mac)

> Dùng GitHub để build app từ xa, không cần Mac, không cần Xcode.

### Bước 1: Tạo repository trên GitHub

1. Vào https://github.com → **New repository**
   - Tên: `SensiUltralock` (hoặc tên khác)
   - Chọn **Public** hoặc **Private**
   - **KHÔNG** tick "Add README" hay ".gitignore"
   - Nhấn **Create repository**

### Bước 2: Upload code lên GitHub

Mở Terminal trên máy của bạn:

```bash
cd "D:\ADR - IOS APP\SensiUltralock"

git init
git add .
git commit -m "Initial commit - Sensi Ultralock iOS"

# Thay YOUR_USERNAME và YOUR_REPO bằng thông tin của bạn
git remote add origin https://github.com/YOUR_USERNAME/SensiUltralock.git
git branch -M main
git push -u origin main
```

> Nhập username + password (hoặc Personal Access Token) khi được hỏi.

### Bước 3: Xem build

1. Vào GitHub → repository của bạn
2. Chọn tab **Actions** (ở thanh trên cùng)
3. Sẽ thấy workflow `Build iOS App` đang chạy
4. Chờ khoảng **3-5 phút** cho build xong (dấu ✅ xanh)

### Bước 4: Tải file .app về

1. Trong tab **Actions**, click vào workflow run vừa hoàn thành
2. Kéo xuống **Artifacts**
3. Click **SensiUltralock-Unsigned** để tải file `.app` về

### Bước 5: Cài vào iPhone bằng AltStore

> **Yêu cầu:** Máy tính Windows/Mac + iPhone + Apple ID miễn phí

1. **Tải AltStore** từ https://altstore.io/
2. Cài AltStore lên máy tính:
   - **Windows**: Tải AltInstaller cho Windows
   - **Mac**: Tải AltServer cho macOS
3. Cắm iPhone vào máy tính
4. **Cài AltStore lên iPhone:**
   - Windows: Mở AltInstaller → chọn iPhone → Install AltStore
   - Mac: Mở AltServer (thanh menu) → chọn iPhone → Install AltStore
   - Đăng nhập Apple ID khi được hỏi

5. **Cài .app vào iPhone:**
   - Mở **AltStore** trên iPhone
   - Vào tab **My Apps**
   - Nhấn **+** ở góc trên
   - Chọn **SensiUltralock.app** vừa tải về
   - Đăng nhập Apple ID → app sẽ được cài

> ⚠️ **Hết hạn sau 7 ngày:** Mở AltStore → nhấn **Renew All** để gia hạn thêm 7 ngày (mỗi tuần làm 1 lần).

---

## 🛠️ Script build nhanh

```bash
./build.sh          # Mở Xcode
./build.sh unsigned # Build unsigned .app cho sideload
```

---

## So với Android

| Tính năng | Giống 100% |
|---|---|
| Auth Plexus API | ✅ |
| HWID (SHA-256) | ✅ |
| Auto-login + Keychain | ✅ |
| Background monitor 60s | ✅ |
| Login screen + grid | ✅ |
| 5 Basic + 3 Pro + 2 VIP features | ✅ |
| Custom neon toggle | ✅ |
| Circular gauge animation | ✅ |
| Advanced Tuner HUD (VIP) | ✅ |
| Admin contacts | ✅ |
| **Màu sắc** | **Tím → Vàng/Gold** ⭐ |

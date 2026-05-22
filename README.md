# AIS Package Store — LaunchDarkly Feature Flags Demo

Flutter Web App สำหรับ Demo ระบบ Feature Flag ครบทุกประเภทของ LaunchDarkly บน AIS Package Store

---

## 🚀 วิธีรันโปรเจกต์

```bash
# 1. ติดตั้ง dependencies
flutter pub get

# 2. รันเป็น Web (Chrome)
flutter run -d chrome

# 3. Build สำหรับ Production
flutter build web --release
```

---

## 🎯 Feature Flags ทั้ง 10 ประเภทที่ Demo

| # | ประเภท | Flag Key | ผลลัพธ์ |
|---|--------|----------|---------|
| 01 | Boolean | `show-promo-banner` | แสดง/ซ่อน Banner โปรโมชั่น |
| 02 | Boolean | `enable-ai-assistant` | เปิด/ปิด AI Chat Widget |
| 03 | Boolean | `show-new-navbar` | สลับ Navbar แบบเก่า/ใหม่ |
| 04 | String | `hero-banner-variant` | เปลี่ยน Hero Banner 3 แบบ (A/B/C) |
| 05 | String | `cta-button-text` | เปลี่ยนข้อความปุ่ม CTA |
| 06 | Number | `discount-percentage` | ส่วนลด 0/10/20/30% |
| 07 | Number | `free-data-gb` | โบนัสเน็ตฟรี 0/5/10/20 GB |
| 08 | JSON | `featured-packages-config` | Layout/จำนวนแพ็กเกจแนะนำ |
| 09 | JSON | `payment-methods-config` | ช่องทางชำระเงิน |
| 10 | JSON | `ai-model-config` | AI Model + Prompt + Temperature |
| 11 | User Targeting | `show-vip-benefits` | เปิดเฉพาะ user @ais.th / role=vip |
| 12 | User Targeting | `show-corporate-packages` | เปิดเฉพาะ role=corporate |
| 13 | % Rollout | `new-checkout-flow` | New Checkout เริ่มที่ 50% |
| 14 | % Rollout | `new-package-card-design` | New Card Design เริ่มที่ 25% |
| 15 | Kill Switch | `maintenance-mode` | ปิดระบบฉุกเฉิน < 200ms |
| 16 | Scheduled | `seasonal-promo` | โปรโมชั่นตามเวลา |
| 17 | A/B Test | `checkout-button-color` | สีปุ่ม Checkout (green/orange/blue/red) |

---

## 🔗 เชื่อมต่อ LaunchDarkly จริง

1. ไปที่ `Profile` ในแอป
2. ใส่ **Mobile SDK Key** จาก LaunchDarkly Dashboard
   - `app.launchdarkly.com → Account → Projects → Client-side ID`
3. กด "เชื่อมต่อ LaunchDarkly"

### สร้าง Flags ใน LaunchDarkly Dashboard

สร้าง Feature Flags ตาม Key เหล่านี้:

```
show-promo-banner          (Boolean)
enable-ai-assistant        (Boolean)
show-new-navbar            (Boolean)
maintenance-mode           (Boolean)
hero-banner-variant        (String: variant_a | variant_b | variant_c)
cta-button-text            (String: สมัครเลย | เลือกแพ็กเกจ | ...)
discount-percentage        (Number: 0 | 10 | 20 | 30)
free-data-gb               (Number: 0 | 5 | 10 | 20)
featured-packages-config   (JSON)
payment-methods-config     (JSON)
ai-model-config            (JSON)
show-vip-benefits          (Boolean + User Targeting)
show-corporate-packages    (Boolean + User Targeting)
new-checkout-flow          (Boolean + % Rollout)
new-package-card-design    (Boolean + % Rollout)
seasonal-promo             (Boolean + Scheduled Changes)
checkout-button-color      (String + Experimentation)
```

---

## 📱 หน้าจอในแอป

- **/** — Home: Hero Banner, Featured Packages, Quick Actions
- **/packages** — เลือกแพ็กเกจตาม Category
- **/packages/:id** — Package Detail
- **/cart** — ตะกร้าสินค้า
- **/checkout** — ชำระเงิน (Classic / New Flow)
- **/profile** — โปรไฟล์ + User Targeting Demo + LD Connection
- **/ld-demo** — LaunchDarkly Feature Flags Showcase ทั้ง 10 ประเภท
- **/success** — หน้าสำเร็จ

---

## 🎨 AIS Brand Colors

| Color | Hex | ใช้ที่ |
|-------|-----|--------|
| Nav Green | #00291D | Navbar |
| Primary Green | #003B2E | Header, Buttons |
| Lime Green | #AECC40 | Accent, CTA |
| Medium Green | #4A7C59 | Cards |

---

## 🔧 Technology Stack

- **Flutter 3.x** — Cross-platform Web App
- **LaunchDarkly Flutter Client SDK** — Feature Flags
- **Provider** — State Management
- **go_router** — Navigation
- **Google Fonts (Noto Sans Thai)** — Thai Language Support
- **fl_chart** — A/B Test Charts

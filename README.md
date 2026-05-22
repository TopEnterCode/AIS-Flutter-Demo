# AIS Package Store — LaunchDarkly Feature Flags Demo

Flutter Web App สำหรับ Demo ระบบ Feature Flag ครบทุกประเภทของ LaunchDarkly
บนธีม AIS Package Store — ใช้สำหรับนำเสนอลูกค้าหรือ Internal Workshop

---

## 📋 สารบัญ

- [Quick Start](#-quick-start)
- [Setup LaunchDarkly](#-setup-launchdarkly)
- [สร้าง Flags ด้วย Script](#-สร้าง-flags-ด้วย-script-อัตโนมัติ)
- [เชื่อมต่อแอปกับ LaunchDarkly](#-เชื่อมต่อแอปกับ-launchdarkly)
- [Feature Flags ทั้งหมด](#-feature-flags-ทั้งหมด)
- [Demo Script สำหรับลูกค้า](#-demo-script-สำหรับลูกค้า)
- [หน้าจอในแอป](#-หน้าจอในแอป)
- [Tech Stack](#-tech-stack)

---

## 🚀 Quick Start

```bash
# 1. ติดตั้ง dependencies
flutter pub get

# 2. รันเป็น Web (Chrome)
flutter run -d chrome

# 3. Build สำหรับ Production
flutter build web --release
```

> แอปรองรับ **Mock/Demo Mode** โดยไม่ต้องเชื่อม LaunchDarkly
> สามารถ toggle flags ได้จากหน้า `/ld-demo` ใน app เลย

---

## 🔧 Setup LaunchDarkly

### 1. สร้าง Project

1. ไปที่ [app.launchdarkly.com](https://app.launchdarkly.com)
2. **Create Project** → ตั้งชื่อ เช่น `AIS Package Store`
3. หลังสร้างเสร็จ ไปที่ **Account settings → Environments**
4. Copy **Client-side ID** ของ Environment `Test`
   - รูปแบบ: `6a0fe89372d0390ef8034f7c` (ไม่มี prefix)
   - **ไม่ใช่** SDK key (`sdk-...`) และ **ไม่ใช่** Mobile key (`mob-...`)

### 2. สร้าง Personal Access Token (สำหรับ Script)

1. **Account settings → Authorization → Access tokens**
2. กด **+ Token** → ตั้งชื่อ เช่น `ais-demo-setup` → Role: **Writer**
3. Copy token ทันที (แสดงครั้งเดียว)
   - รูปแบบ: `api-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

---

## 🤖 สร้าง Flags ด้วย Script อัตโนมัติ

แทนที่จะสร้าง Flag ทีละอันใน Dashboard ให้ใช้ Script นี้สร้างครบ 17 Flags ในครั้งเดียว

### 1. แก้ไข Config ในไฟล์ Script

เปิดไฟล์ `scripts/create_ld_flags.py` แก้ 2 บรรทัด:

```python
API_TOKEN   = "api-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Personal Access Token
PROJECT_KEY = "default"   # Project key (ดูได้ที่ Settings → Projects)
```

> **หา Project Key**: LaunchDarkly → Settings → Projects → คอลัมน์ **Key**
> ค่า default คือ `default` ถ้าไม่ได้เปลี่ยนชื่อตอนสร้าง

### 2. รัน Script

```bash
python scripts/create_ld_flags.py
```

### 3. ผลที่ควรเห็น

```
============================================================
  LaunchDarkly Flag Setup — AIS Package Store Demo
============================================================

🔍  ตรวจสอบ project 'default'...
✅  Project: AIS Package Store (key: default)

📋  สร้าง 17 flags...

  ✅  [boolean     ]  show-promo-banner
  ✅  [boolean     ]  enable-ai-assistant
  ✅  [boolean     ]  maintenance-mode
  ...
  ✅  [multivariate]  ai-model-config

────────────────────────────────────────────────────────────
  ✅ สร้างสำเร็จ : 17
  ⚠️  มีอยู่แล้ว : 0
  ❌ ผิดพลาด    : 0
────────────────────────────────────────────────────────────

🎉  เสร็จแล้ว!
```

> Script มี Auto-retry เมื่อ Rate Limit (5s → 10s → 20s → 40s)
> ถ้า run ซ้ำ flags ที่มีอยู่แล้วจะ skip อัตโนมัติ (⚠️)

---

## 🔗 เชื่อมต่อแอปกับ LaunchDarkly

### วิธีที่ 1 — ใส่ผ่าน UI (ทดสอบ Runtime)

1. เปิดแอป `flutter run -d chrome`
2. คลิก tab **Profile** (icon รูปคน มุมขวาสุด)
3. เลื่อนลงหา section **"LaunchDarkly Connection"**
4. วาง **Client-side ID** แล้วกด **Connect**
5. สถานะเปลี่ยนเป็น ✅ เชื่อมต่อแล้ว

### วิธีที่ 2 — ใส่ใน Code (ถาวร)

เปิด `lib/main.dart` เพิ่ม `sdkKey`:

```dart
final ldService = await LDService.create(
  sdkKey: 'YOUR_CLIENT_SIDE_ID_HERE',   // ← ใส่ตรงนี้
  initialContext: LDContextFactory.defaultContext,
);
```

> **สำคัญ**: SDK v4.x ตรวจแพลตฟอร์มอัตโนมัติ
> - **Flutter Web (Chrome)** → ใช้ **Client-side ID** (`6a0f...`)
> - **Flutter Mobile (iOS/Android)** → ใช้ **Mobile key** (`mob-...`)

---

## 🎯 Feature Flags ทั้งหมด

| # | ประเภท | Flag Key | ผลใน App |
|---|--------|----------|----------|
| 01 | Boolean | `show-promo-banner` | แสดง/ซ่อน Banner โปรโมชั่น |
| 02 | Boolean | `enable-ai-assistant` | เปิด/ปิด AI Chat Widget |
| 03 | Boolean | `show-new-navbar` | สลับ Navbar เก่า/ใหม่ |
| 04 | Boolean | `maintenance-mode` | **Kill Switch** — ปิดระบบฉุกเฉิน |
| 05 | Boolean | `show-vip-benefits` | User Targeting — เฉพาะ VIP |
| 06 | Boolean | `show-corporate-packages` | User Targeting — เฉพาะองค์กร |
| 07 | Boolean | `new-checkout-flow` | Rollout — Checkout flow ใหม่ |
| 08 | Boolean | `new-package-card-design` | Rollout — Card design ใหม่ |
| 09 | Boolean | `seasonal-promo` | Scheduled — โปรโมชั่นตามเวลา |
| 10 | String | `hero-banner-variant` | A/B/C — Hero Banner 3 ดีไซน์ |
| 11 | String | `cta-button-text` | A/B — ข้อความปุ่มสมัคร |
| 12 | String | `checkout-button-color` | Experiment — สีปุ่ม Checkout |
| 13 | Number | `discount-percentage` | ส่วนลด 0 / 10 / 20 / 30% |
| 14 | Number | `free-data-gb` | โบนัสเน็ต 0 / 5 / 10 / 20 GB |
| 15 | JSON | `featured-packages-config` | Layout + จำนวนแพ็กเกจแนะนำ |
| 16 | JSON | `payment-methods-config` | ช่องทางชำระเงิน |
| 17 | JSON | `ai-model-config` | AI Model + Prompt + Temperature |

---

## 🎬 Demo Script สำหรับลูกค้า

> เปิด 2 หน้าต่างคู่กัน: **แอป (ซ้าย)** + **LD Dashboard (ขวา)**

### Scene 1 — Kill Switch (3 นาที)
**จุดขาย**: ปิดระบบ Production ได้ใน < 1 วินาที ไม่ต้อง Deploy

```
LD Dashboard → Flag: maintenance-mode → Toggle ON
```
→ หน้า Maintenance ขึ้นทันที

```
Toggle กลับ OFF
```
→ แอปกลับมาปกติ

> 💬 *"ถ้าพบ Bug ตี 2 ไม่ต้องโทรหา Dev รอ Deploy — กด Toggle เดียว ปิดได้ทันที"*

---

### Scene 2 — Boolean Flags (3 นาที)
**จุดขาย**: เปิด/ปิด Feature โดยไม่ต้อง Release ใหม่

```
show-promo-banner  → OFF  → Banner โปรโมชั่นหายไป
enable-ai-assistant → ON  → ปุ่ม AI โผล่มุมขวาล่าง
show-new-navbar    → ON   → Navbar เปลี่ยนรูปแบบ
```

> 💬 *"ทีม Marketing ปิด Banner เองได้ โดยไม่ง้อ Dev"*

---

### Scene 3 — A/B Test (5 นาที)
**จุดขาย**: ทดสอบ Copy/Design โดยไม่ต้อง Code ใหม่

```
cta-button-text       → "รับสิทธิ์ทันที"    → ปุ่มสมัครเปลี่ยนทันที
hero-banner-variant   → variant_b / variant_c → Banner เปลี่ยนดีไซน์
checkout-button-color → orange / blue / red   → สีปุ่มเปลี่ยน
```

> 💬 *"ทีม Marketing ทดสอบ Conversion ได้เองทุก วัน ไม่ต้องรอ Sprint"*

---

### Scene 4 — User Targeting (7 นาที)
**จุดขาย**: คนละกลุ่ม เห็นคนละอย่าง — Real Personalization

```
Profile → Email: john@gmail.com   → ไม่เห็น VIP section
Profile → Email: staff@ais.th     → เห็น VIP + Corporate packages
Profile → Role: corporate         → เห็น Corporate packages
```

> 💬 *"ลูกค้า VIP กับลูกค้าทั่วไปเห็นหน้าเดียวกัน แต่เนื้อหาต่างกัน"*

---

### Scene 5 — Number Flag + Dynamic Pricing (3 นาที)
**จุดขาย**: ปรับราคา/โปรโมชั่นแบบ Real-time

```
discount-percentage → 0 → 10 → 20 → 30    → ราคาในแอปลดลงทันที
free-data-gb        → 0 → 10 → 20          → "รับ 20GB ฟรี" โผล่ขึ้น
```

> 💬 *"Flash Sale ตีสิบทุ่ม เปิดส่วนลด 30% ได้เลย ไม่ต้องรอ Dev"*

---

### Scene 6 — Percentage Rollout (5 นาที)
**จุดขาย**: ค่อยๆ ปล่อย Feature — ลด Risk

```
new-checkout-flow → Add Rule: Percentage Rollout 10%
```
→ อธิบาย: "10% เห็น Checkout ใหม่ ถ้าไม่มี Bug → เพิ่มเป็น 50% → 100%"

> 💬 *"Bug กระทบแค่ 10% ของ User ไม่ใช่ทุกคน — ลด Risk การ Release"*

---

### Scene 7 — JSON Config (5 นาที)
**จุดขาย**: เปลี่ยน Layout/Config ทั้งหน้าด้วย JSON เดียว

```
featured-packages-config → list layout   → หน้าแพ็กเกจเปลี่ยน layout
payment-methods-config   → เปิด truemoney, linepay → ช่องทางชำระเพิ่มขึ้น
```

> 💬 *"ทีม Ops เปลี่ยน Business Logic ได้เอง โดยไม่แตะ Code"*

---

### Scene 8 — AI Config (3 นาที)
**จุดขาย**: สลับ AI Model / Prompt แบบ Real-time

```
enable-ai-assistant → ON
ai-model-config → Haiku (เร็ว ถูก) / Sonnet (สมดุล) / Opus (Premium)
```
→ ถามแอป: *"แนะนำแพ็กเกจอินเทอร์เน็ตให้หน่อย"*

> 💬 *"เปลี่ยน AI Model โดยไม่ Redeploy — ควบคุม Cost และ Quality แบบ Dynamic"*

---

### Key Message สรุป

| Feature | Value Proposition |
|---------|-------------------|
| Kill Switch | ลด MTTR จาก ชั่วโมง → วินาที |
| Feature Flag | Deploy ได้ทุกวัน โดยไม่เสี่ยง |
| A/B Test | ทีม Marketing ทำ Experiment เองได้ |
| User Targeting | Real Personalization ไม่ต้อง Hardcode |
| % Rollout | ลด Risk — ปล่อย Feature แบบ Incremental |
| JSON Config | เปลี่ยน Business Logic โดยไม่ต้อง Code |
| AI Config | ควบคุม AI Cost/Quality แบบ Dynamic |

---

## 📱 หน้าจอในแอป

| Route | หน้าจอ | Feature Flags ที่ใช้ |
|-------|--------|---------------------|
| `/` | Home | `show-promo-banner`, `featured-packages-config`, `seasonal-promo`, `discount-percentage`, `enable-ai-assistant` |
| `/packages` | เลือกแพ็กเกจ | `cta-button-text`, `new-package-card-design` |
| `/packages/:id` | Package Detail | `show-vip-benefits`, `show-corporate-packages` |
| `/cart` | ตะกร้าสินค้า | — |
| `/checkout` | ชำระเงิน | `new-checkout-flow`, `payment-methods-config`, `checkout-button-color` |
| `/profile` | โปรไฟล์ + LD Connection | User context, LD SDK Key |
| `/ld-demo` | Flag Showcase (Demo Panel) | แสดง Flags ทั้ง 17 รายการ พร้อม Toggle |
| `/success` | สำเร็จ | — |

---

## 🛠 Tech Stack

| Library | Version | ใช้ทำอะไร |
|---------|---------|-----------|
| Flutter | 3.x | Cross-platform Web App |
| launchdarkly_flutter_client_sdk | **4.16.0** | Feature Flags (Web + Mobile) |
| provider | 6.x | State Management |
| go_router | 14.x | Navigation |
| google_fonts | 6.x | Noto Sans Thai |
| fl_chart | 0.68 | A/B Test Charts |
| shared_preferences | 2.x | บันทึก SDK Key |

---

## 📁 โครงสร้างโปรเจกต์

```
lib/
├── main.dart                    # Entry point + LDService.create()
├── app.dart                     # Router + App setup
├── constants/
│   └── flag_keys.dart           # Flag key constants ทั้งหมด
├── services/
│   └── ld_service.dart          # LaunchDarkly SDK wrapper (v4.x)
├── screens/
│   ├── home_screen.dart         # หน้าหลัก
│   ├── packages_screen.dart     # เลือกแพ็กเกจ
│   ├── package_detail_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── profile_screen.dart      # LD Connection + User Targeting
│   ├── ld_demo_screen.dart      # Demo Panel — Flags ทั้งหมด
│   └── success_screen.dart
├── widgets/
├── models/
├── providers/
├── data/
└── theme/
scripts/
└── create_ld_flags.py           # Auto-create 17 flags via LD REST API
```

---

## 🎨 AIS Brand Colors

| Color | Hex | ใช้ที่ |
|-------|-----|--------|
| Nav Green | `#00291D` | Navbar |
| Primary Green | `#003B2E` | Header, Buttons |
| Lime Green | `#AECC40` | Accent, CTA |
| Medium Green | `#4A7C59` | Cards |
| LD Blue | `#405BFF` | LaunchDarkly accent |

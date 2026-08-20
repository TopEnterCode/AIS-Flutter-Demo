# AIS Package Store — LaunchDarkly Demo

ตัวอย่างแอป Flutter ของ AIS สำหรับสาธิตการใช้ LaunchDarkly Feature Flags กับ
ทั้ง package store เดิมและ use case การชำระเงิน mPAY

โปรเจกต์นี้เป็น Flutter application เดิม ไม่ใช่แอปแยกหรือ backend demo

## Quick start

ต้องมี Flutter/Dart ที่รองรับโปรเจกต์นี้ และ Python 3 สำหรับ flag setup script

```bash
# ติดตั้ง dependencies
flutter pub get

# รันบน Chrome
flutter run -d chrome

# ตรวจโค้ด
flutter analyze

# รัน tests
flutter test

# Build production web
flutter build web --release
```

คำสั่งเดิมข้างต้นยังใช้ได้ทั้งหมดครับ การเพิ่ม mPAY demo ไม่ได้เปลี่ยน
architecture หรือคำสั่งรันแอปเดิม

### Windows: ถ้า `flutter` ไม่อยู่ใน PATH

Repository นี้มี Flutter SDK แบบ local อยู่แล้วที่ `.tools/flutter` ให้ใช้คำสั่ง
PowerShell ชุดนี้แทน:

```powershell
.\.tools\flutter\bin\flutter.bat pub get
.\.tools\flutter\bin\flutter.bat run -d chrome
.\.tools\flutter\bin\flutter.bat analyze
.\.tools\flutter\bin\flutter.bat test
.\.tools\flutter\bin\flutter.bat build web --release
```

หรือเพิ่ม `D:\Work\LaunchDarkly\LAB\AIS-Flutter-Demo\.tools\flutter\bin`
เข้า Windows PATH แล้วเปิด terminal ใหม่ จากนั้นจึงใช้คำสั่ง `flutter` แบบสั้นได้

## LaunchDarkly credentials

โปรเจกต์นี้มี credentials สองส่วนที่ใช้คนละวัตถุประสงค์:

### 1. API token สำหรับสร้าง flags

ไฟล์ `scripts/create_ld_flags.py` อ่าน token จาก `.env` ที่ root ของโปรเจกต์:

```dotenv
LD_ACCESS_TOKEN=api-your-launchdarkly-writer-token
```

สคริปต์โหลด `.env` ให้อัตโนมัติ และจะไม่เขียนทับ environment variable ที่ตั้งไว้
จาก shell ภายนอก

ห้าม commit `.env` หรือส่ง API token เข้า repository โดย `.env` ถูกใส่ไว้ใน
`.gitignore` แล้ว

### 2. Client-side ID / Mobile key สำหรับแอป Flutter

เปิดแอปแล้วไปที่:

`Profile` → `LaunchDarkly Connection` → ใส่ credential → `Connect`

- Flutter Web ใช้ Client-side ID
- Android/iOS ใช้ Mobile key

แอปจะเชื่อมต่ออัตโนมัติตอนเปิดใหม่ โดยใช้ credential ที่บันทึกไว้ก่อน หากยังไม่มี
ค่าที่บันทึกไว้จะใช้ Client-side ID ของโปรเจกต์เป็นค่าเริ่มต้น สามารถ override ได้ด้วย
`--dart-define=LD_CLIENT_SIDE_ID=...` โดยไม่ต้องกด Connect ทุกครั้ง

## สร้าง LaunchDarkly flags ด้วย script

ตั้งค่า project key ให้ตรงกับ LaunchDarkly project ใน
`scripts/create_ld_flags.py` หากจำเป็น:

```python
PROJECT_KEY = "AIS-Flutter"
```

จากนั้นรัน:

```bash
python scripts/create_ld_flags.py
```

สคริปต์จะตรวจ project ก่อน แล้วสร้าง flags ทั้งหมด 19 รายการ:

- flags เดิม 17 รายการ ถ้ามีอยู่แล้วจะแสดง `มีอยู่แล้ว` และ skip
- `mpay-api-v2` สร้างถ้ายังไม่มี
- `mpay-connector-v2` สร้างถ้ายังไม่มี
- `payment-flow-v2` สร้างถ้ายังไม่มี

สคริปต์เปิด client-side availability สำหรับทั้ง Client-side ID และ Mobile key
ไว้ใน payload แล้ว

คำสั่งนี้เป็น idempotent ในระดับการสร้าง: การรันซ้ำจะไม่สร้าง flag ซ้ำ แต่จะ
ไม่แก้ไข targeting rules ของ flag ที่มีอยู่แล้ว

## mPAY Demo

เปิดจาก Home → **mPAY Demo** หรือไปที่ route:

```text
/launchdarkly-mpay-demo
```

ฟีเจอร์อยู่ภายใต้:

```text
lib/features/launchdarkly_mpay_demo/
```

ใช้ Provider, GoRouter, `LDService` และ AIS theme เดิมของแอป

### Flags

| Flag | Type | Variations | Fallback |
|---|---|---|---|
| `mpay-api-v2` | Boolean | `false` = API V1, `true` = API V2 | `false` |
| `mpay-connector-v2` | Boolean | `false` = Connector V1, `true` = Connector V2 | `false` |
| `payment-flow-v2` | Boolean | `false` = Payment V1, `true` = Payment V2 | `false` |

### Suggested targeting rules

ตั้ง rule ของทั้งสาม flag ให้เหมือนกันตามลำดับ:

1. `userType` is `internal` → `true`
2. `merchantId` is `MERCHANT-BETA` → `true`
3. Percentage rollout ของ context ที่เหลือ → `true`
4. Fallthrough → `false` (ปิดทั้งสาม V2 flags)

การ rollout ใช้ evaluation จาก LaunchDarkly โดยตรง แอปไม่สุ่มผลเอง

### Synthetic demo contexts

| Identity | Key | `userType` | `merchantId` |
|---|---|---|---|
| Internal Tester | `employee-001` | `internal` | `MPAY-INTERNAL` |
| Beta Merchant | `merchant-001` | `merchant` | `MERCHANT-BETA` |
| Normal Customer A | `customer-001` | `customer` | `MERCHANT-001` |
| Normal Customer B | `customer-002` | `customer` | `MERCHANT-002` |

หน้า demo มี synthetic population `customer-001` ถึง `customer-020` สำหรับ
ตรวจ progressive rollout ด้วย stable context keys

### Backend Connector API rollout

- **API V1 + Connector V1**: stable integration สำหรับ payment processing
- **API V2 + Connector V2**: integration ชุดใหม่สำหรับ bank capability หรือ API
  contract ที่ V1 รองรับได้ไม่ดี

API V1/V2 และ Connector V1/V2 ถูก deploy อยู่ในแอปเดียวกันแล้ว การเปลี่ยน flag ไม่ต้อง build
APK/IPA ใหม่

### Kill switch demo

1. เลือก context ที่ได้ Payment V2 + API V2 + Connector V2
2. เปิด **Simulate Connector API V2 failure** ในหน้า demo
3. ทำ payment จนถึง Processing เพื่อแสดง connector failure
4. ปิดทั้งสาม V2 flags ใน LaunchDarkly
5. แอปจะแสดง **Emergency fallback: API V1 + Connector V1 active** โดยไม่ต้อง rebuild

toggle จำลองนี้เป็น local business/application failure เท่านั้น ไม่ได้แก้ค่า
LaunchDarkly flag

### Offline fallback

หาก LaunchDarkly initialize ไม่สำเร็จ, SDK unavailable หรือ evaluation ล้มเหลว:

- ทั้งสาม V2 flags ใช้ fallback `false`
- แอปแสดง `LaunchDarkly unavailable — Fallback: API V1 + Connector V1`
- แอปไม่ crash และไม่สุ่ม rollout เอง

รายละเอียดเพิ่มเติมอยู่ที่ [docs/launchdarkly_mpay_demo.md](docs/launchdarkly_mpay_demo.md)

## Presenter flow

1. Normal Customer → API V1 + Connector V1
2. Internal Tester → API V2 + Connector V2 จาก internal targeting
3. Beta Merchant → API V2 + Connector V2 จาก merchant targeting
4. Simulate Connector API V2 failure
5. Turn all three V2 flags OFF
6. แสดง immediate fallback ไป API V1 + Connector V1

## Existing LaunchDarkly demo

หน้า demo เดิมยังอยู่ที่:

```text
/ld-demo
```

ใช้สาธิต flags ประเภท boolean, string, number, JSON, targeting, rollout และ
kill switch ของ package store เดิม ส่วน mPAY ใช้หน้าใหม่แยกที่
`/launchdarkly-mpay-demo`

## Testing and verification

```bash
flutter analyze
flutter test
flutter build web --release
```

Tests ของ mPAY อยู่ที่:

```text
test/launchdarkly_mpay_demo_test.dart
```

ครอบคลุม:

- `false` → API/Connector V1
- `true` → API/Connector V2
- evaluation failure/missing value → fallback API/Connector V1
- internal context attributes
- merchant context attributes

## Project structure

```text
lib/
├── main.dart
├── app.dart
├── constants/
├── services/
│   └── ld_service.dart
├── features/
│   └── launchdarkly_mpay_demo/
│       ├── domain/
│       ├── models/
│       ├── presentation/
│       └── services/
├── screens/
├── providers/
├── widgets/
└── theme/
scripts/
└── create_ld_flags.py
docs/
└── launchdarkly_mpay_demo.md
test/
└── launchdarkly_mpay_demo_test.dart
```

## Main dependencies

- Flutter
- `launchdarkly_flutter_client_sdk` 4.x
- Provider
- GoRouter
- Shared Preferences
- Google Fonts
- fl_chart

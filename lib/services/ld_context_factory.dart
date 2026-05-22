// LaunchDarkly Context Factory
// Best practice: สร้าง LDContext แบบมาตรฐาน พร้อม Targeting personas สำหรับ Demo
//
// LD Context ที่ดีควรมี:
//  - kind: 'user' (หรือ 'organization', 'device' สำหรับ multi-context)
//  - key: unique identifier ที่ไม่เปลี่ยนแปลง
//  - attributes ที่ใช้ใน Targeting Rules

import 'ld_service.dart';

// ============================================================
//  Data class สำหรับ context ของ User
//  ใช้แทน LDContext จริงใน app layer เพื่อ decouple จาก SDK
// ============================================================
class LDContextFactory {
  // Default context สำหรับ demo ที่ยังไม่ login
  static LDUserContext get defaultContext => LDUserContext(
        key: 'demo-user-001',
        name: 'Demo User',
        email: 'demo@example.com',
        role: 'user',
        plan: 'free',
        country: 'TH',
      );

  // ────────────────────────────────────────────────────────
  //  Single-Kind Context: user
  // ────────────────────────────────────────────────────────
  // ใน LD Dashboard → Targeting Rules → user.email, user.role ฯลฯ
  static LDUserContext createUser({
    required String key,
    required String name,
    required String email,
    String role = 'user',
    String plan = 'free',
    String country = 'TH',
    bool betaTester = false,
    String? organizationKey,
    String? organizationName,
    String? organizationPlan,
  }) {
    return LDUserContext(
      key: key,
      name: name,
      email: email,
      role: role,
      plan: plan,
      country: country,
      betaTester: betaTester,
      organizationKey: organizationKey,
      organizationName: organizationName,
      organizationPlan: organizationPlan,
    );
  }

  // ────────────────────────────────────────────────────────
  //  Multi-Kind Context: user + organization
  // ────────────────────────────────────────────────────────
  // ใน LD Dashboard Targeting Rules สามารถ target ทั้ง
  //   - user.email ends with "@ais.th"  AND
  //   - organization.plan = "enterprise"
  // ได้พร้อมกัน
  static LDUserContext createMultiContext({
    required String userKey,
    required String name,
    required String email,
    String role = 'user',
    String plan = 'free',
    required String orgKey,
    required String orgName,
    String orgPlan = 'basic',
    String country = 'TH',
    bool betaTester = false,
  }) {
    return LDUserContext(
      key: userKey,
      name: name,
      email: email,
      role: role,
      plan: plan,
      country: country,
      betaTester: betaTester,
      organizationKey: orgKey,
      organizationName: orgName,
      organizationPlan: orgPlan,
    );
  }

  // ────────────────────────────────────────────────────────
  //  Targeting Personas — ใช้ใน Demo
  //  แต่ละ Persona แสดงให้เห็นว่า Targeting Rules ใน LD
  //  ส่ง flag values ต่างกันอย่างไร
  // ────────────────────────────────────────────────────────
  static List<LDTargetingPersona> get personas => [
        LDTargetingPersona(
          id: 'general',
          label: '👤 ลูกค้าทั่วไป',
          description: 'User ปกติ ได้รับค่า Default Variation',
          targetingRule: 'Fallthrough → default values',
          context: createUser(
            key: 'user-general-001',
            name: 'สมชาย ใจดี',
            email: 'somchai@gmail.com',
            role: 'user',
            plan: 'free',
            country: 'TH',
          ),
          expectedFlags: const {
            'show-vip-benefits': false,
            'show-corporate-packages': false,
            'discount-percentage': 0.0,
            'hero-banner-variant': 'variant_a',
          },
        ),
        LDTargetingPersona(
          id: 'vip',
          label: '⭐ VIP Customer',
          description: 'role = "vip" → เปิด VIP Benefits + ส่วนลด 20%',
          targetingRule: 'Rule: user.role = "vip" → serve true',
          context: createUser(
            key: 'user-vip-001',
            name: 'วิภา เงินทอง',
            email: 'vip.customer@gmail.com',
            role: 'vip',
            plan: 'premium',
            country: 'TH',
          ),
          expectedFlags: const {
            'show-vip-benefits': true,
            'show-corporate-packages': false,
            'discount-percentage': 20.0,
            'hero-banner-variant': 'variant_b',
          },
        ),
        LDTargetingPersona(
          id: 'ais_staff',
          label: '👑 AIS Staff',
          description: 'email ends with @ais.th → ได้รับสิทธิ์ทุกอย่าง',
          targetingRule: 'Rule: user.email endsWith "@ais.th" → serve true',
          context: createUser(
            key: 'staff-ais-001',
            name: 'ก้องเกียรติ จิตใส',
            email: 'kongkiat@ais.th',
            role: 'user',
            plan: 'staff',
            country: 'TH',
          ),
          expectedFlags: const {
            'show-vip-benefits': true,
            'show-corporate-packages': true,
            'discount-percentage': 30.0,
            'hero-banner-variant': 'variant_c',
            'enable-ai-assistant': true,
          },
        ),
        LDTargetingPersona(
          id: 'corporate',
          label: '🏢 Corporate',
          description: 'role = "corporate" → เห็น Corporate Packages',
          targetingRule: 'Rule: user.role in ["corporate", "enterprise"]',
          context: createMultiContext(
            userKey: 'user-corp-001',
            name: 'ปิยะ บริษัทดี',
            email: 'manager@acme-corp.co.th',
            role: 'corporate',
            plan: 'enterprise',
            orgKey: 'org-acme-001',
            orgName: 'ACME Corporation',
            orgPlan: 'enterprise',
            country: 'TH',
          ),
          expectedFlags: const {
            'show-corporate-packages': true,
            'show-vip-benefits': false,
            'checkout-button-color': 'blue',
          },
        ),
        LDTargetingPersona(
          id: 'beta',
          label: '🧪 Beta Tester',
          description: 'betaTester = true → เห็นฟีเจอร์ใหม่ก่อนใคร',
          targetingRule: 'Rule: user.betaTester = true → serve true',
          context: createUser(
            key: 'beta-user-001',
            name: 'ปัญญา ชอบทดสอบ',
            email: 'beta@example.com',
            role: 'user',
            plan: 'free',
            country: 'TH',
            betaTester: true,
          ),
          expectedFlags: const {
            'new-checkout-flow': true,
            'new-package-card-design': true,
            'hero-banner-variant': 'variant_b',
          },
        ),
        LDTargetingPersona(
          id: 'international',
          label: '🌏 International User',
          description: 'country = "US" → แสดง Roaming ก่อน',
          targetingRule: 'Rule: user.country != "TH" → variant_b',
          context: createUser(
            key: 'intl-user-001',
            name: 'John Smith',
            email: 'john.smith@gmail.com',
            role: 'user',
            plan: 'free',
            country: 'US',
          ),
          expectedFlags: const {
            'hero-banner-variant': 'variant_b',
            'show-vip-benefits': false,
          },
        ),
      ];
}

// Persona data class สำหรับแสดงใน Demo UI
class LDTargetingPersona {
  final String id;
  final String label;
  final String description;
  final String targetingRule;
  final LDUserContext context;
  final Map<String, dynamic> expectedFlags;

  const LDTargetingPersona({
    required this.id,
    required this.label,
    required this.description,
    required this.targetingRule,
    required this.context,
    required this.expectedFlags,
  });
}

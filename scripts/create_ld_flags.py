#!/usr/bin/env python3
"""
=============================================================
  สร้าง LaunchDarkly Feature Flags ทั้งหมดสำหรับ AIS Package Store
  รัน: python scripts/create_ld_flags.py
=============================================================

ก่อน run ต้องทำ 2 อย่าง:
  1. หา Personal Access Token:
       LaunchDarkly > คลิก icon รูปคน (บนขวา) > Account settings
       > Authorization > Access tokens > + Token
       > Role: Writer > Copy token

  2. หา Project Key:
       LaunchDarkly > คลิก icon รูปเฟือง (sidebar) > Projects
       > ดูคอลัมน์ Key (เช่น "default" หรือ "ais-package-store")

  แล้วแก้ 2 บรรทัดด้านล่างนี้
"""

import json
import urllib.request
import urllib.error
import sys
import time

# ============================================================
#  CONFIG — แก้ 2 ค่านี้ก่อน run
# ============================================================
API_TOKEN   = "api-1eabbfce-098f-4cae-aa1c-d166afa13821"
PROJECT_KEY = "AIS-Flutter"   # หรือ key ของ project ที่สร้าง

CLIENT_SIDE_ID = "6a0fe89372d0390ef8034f7c"   # จากรูป (ใช้ใน Flutter app)

BASE_URL = "https://app.launchdarkly.com/api/v2"

# ============================================================
#  FLAG DEFINITIONS — ครบทุก Flag ที่แอปใช้
# ============================================================
FLAGS = [

    # ─── 1. BOOLEAN FLAGS ───────────────────────────────────
    {
        "name": "Show Promo Banner",
        "key": "show-promo-banner",
        "kind": "boolean",
        "description": "เปิด/ปิดแบนเนอร์โปรโมชั่นบนหน้าหลัก",
        "tags": ["boolean-flag", "ais-demo"],
        "variations": [
            {"value": True,  "name": "On"},
            {"value": False, "name": "Off"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": True,   # ค่าเริ่มต้นใน Test env: เปิด
    },
    {
        "name": "Enable AI Assistant",
        "key": "enable-ai-assistant",
        "kind": "boolean",
        "description": "แสดง/ซ่อน AI Chat Assistant ในแอป",
        "tags": ["boolean-flag", "ais-demo", "ai"],
        "variations": [
            {"value": True,  "name": "On"},
            {"value": False, "name": "Off"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "Maintenance Mode",
        "key": "maintenance-mode",
        "kind": "boolean",
        "description": "Kill Switch — ปิดระบบฉุกเฉินทันทีเมื่อพบปัญหา",
        "tags": ["boolean-flag", "kill-switch", "ais-demo"],
        "variations": [
            {"value": True,  "name": "Maintenance On"},
            {"value": False, "name": "Normal"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "Show New Navbar",
        "key": "show-new-navbar",
        "kind": "boolean",
        "description": "ทดสอบ Navigation Bar รูปแบบใหม่",
        "tags": ["boolean-flag", "ais-demo", "ui"],
        "variations": [
            {"value": True,  "name": "New Navbar"},
            {"value": False, "name": "Old Navbar"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "Show VIP Benefits",
        "key": "show-vip-benefits",
        "kind": "boolean",
        "description": "แสดงแพ็กเกจและสิทธิพิเศษสำหรับลูกค้า VIP",
        "tags": ["boolean-flag", "user-targeting", "ais-demo"],
        "variations": [
            {"value": True,  "name": "Show"},
            {"value": False, "name": "Hide"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "Show Corporate Packages",
        "key": "show-corporate-packages",
        "kind": "boolean",
        "description": "แสดงแพ็กเกจ Corporate สำหรับลูกค้าธุรกิจ",
        "tags": ["boolean-flag", "user-targeting", "ais-demo"],
        "variations": [
            {"value": True,  "name": "Show"},
            {"value": False, "name": "Hide"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "New Checkout Flow",
        "key": "new-checkout-flow",
        "kind": "boolean",
        "description": "ทยอยปล่อย Checkout Flow ใหม่แบบ Percentage Rollout",
        "tags": ["boolean-flag", "rollout", "ais-demo"],
        "variations": [
            {"value": True,  "name": "New Flow"},
            {"value": False, "name": "Old Flow"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "New Package Card Design",
        "key": "new-package-card-design",
        "kind": "boolean",
        "description": "ทยอยปล่อย Package Card Design ใหม่",
        "tags": ["boolean-flag", "rollout", "ais-demo"],
        "variations": [
            {"value": True,  "name": "New Design"},
            {"value": False, "name": "Old Design"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },
    {
        "name": "Seasonal Promo",
        "key": "seasonal-promo",
        "kind": "boolean",
        "description": "เปิด/ปิดโปรโมชั่นตามเวลาที่ตั้งไว้อัตโนมัติ (Scheduled Changes)",
        "tags": ["boolean-flag", "scheduled", "ais-demo"],
        "variations": [
            {"value": True,  "name": "Active"},
            {"value": False, "name": "Inactive"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 1},
        "env_on": False,
    },

    # ─── 2. MULTIVARIATE STRING FLAGS ───────────────────────
    {
        "name": "Hero Banner Variant",
        "key": "hero-banner-variant",
        "kind": "multivariate",
        "description": "เลือกดีไซน์ Hero Banner บนหน้าหลัก — A/B/C Test",
        "tags": ["string-flag", "ab-test", "ais-demo"],
        "variations": [
            {"value": "variant_a", "name": "Variant A (Default)"},
            {"value": "variant_b", "name": "Variant B"},
            {"value": "variant_c", "name": "Variant C"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },
    {
        "name": "CTA Button Text",
        "key": "cta-button-text",
        "kind": "multivariate",
        "description": "ข้อความปุ่มสมัครแพ็กเกจ — A/B Testing",
        "tags": ["string-flag", "ab-test", "ais-demo"],
        "variations": [
            {"value": "สมัครเลย",       "name": "สมัครเลย (Default)"},
            {"value": "เลือกแพ็กเกจ",   "name": "เลือกแพ็กเกจ"},
            {"value": "ใช้งานได้ทันที", "name": "ใช้งานได้ทันที"},
            {"value": "รับสิทธิ์ทันที", "name": "รับสิทธิ์ทันที"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },
    {
        "name": "Checkout Button Color",
        "key": "checkout-button-color",
        "kind": "multivariate",
        "description": "ทดสอบสีปุ่ม Checkout ว่าสีไหน Conversion ดีกว่า",
        "tags": ["string-flag", "experimentation", "ais-demo"],
        "variations": [
            {"value": "green",  "name": "Green (Default)"},
            {"value": "orange", "name": "Orange"},
            {"value": "blue",   "name": "Blue"},
            {"value": "red",    "name": "Red"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },

    # ─── 3. MULTIVARIATE NUMBER FLAGS ───────────────────────
    {
        "name": "Discount Percentage",
        "key": "discount-percentage",
        "kind": "multivariate",
        "description": "เปอร์เซ็นต์ส่วนลดสำหรับแพ็กเกจ — ปรับ Real-time ไม่ต้อง Deploy",
        "tags": ["number-flag", "ais-demo"],
        "variations": [
            {"value": 0,  "name": "No Discount"},
            {"value": 10, "name": "10% Off"},
            {"value": 20, "name": "20% Off"},
            {"value": 30, "name": "30% Off"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },
    {
        "name": "Free Data GB",
        "key": "free-data-gb",
        "kind": "multivariate",
        "description": "จำนวน GB โบนัสที่ได้รับเมื่อสมัครแพ็กเกจ",
        "tags": ["number-flag", "ais-demo"],
        "variations": [
            {"value": 0,  "name": "No Bonus"},
            {"value": 5,  "name": "+5 GB"},
            {"value": 10, "name": "+10 GB"},
            {"value": 20, "name": "+20 GB"},
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },

    # ─── 4. JSON FLAGS ───────────────────────────────────────
    {
        "name": "Featured Packages Config",
        "key": "featured-packages-config",
        "kind": "multivariate",
        "description": "กำหนดแพ็กเกจแนะนำและรูปแบบการแสดงผล (JSON)",
        "tags": ["json-flag", "ais-demo"],
        "variations": [
            {
                "value": {"layout": "grid", "count": 4, "highlight": "surf_5g_299", "showPriceFirst": True},
                "name": "Grid Layout (Default)",
            },
            {
                "value": {"layout": "list", "count": 6, "highlight": "bundle_599", "showPriceFirst": False},
                "name": "List Layout",
            },
            {
                "value": {"layout": "carousel", "count": 8, "highlight": "privilege_899", "showPriceFirst": True},
                "name": "Carousel Layout",
            },
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },
    {
        "name": "Payment Methods Config",
        "key": "payment-methods-config",
        "kind": "multivariate",
        "description": "กำหนดช่องทางการชำระเงินที่แสดงในหน้า Checkout (JSON)",
        "tags": ["json-flag", "ais-demo"],
        "variations": [
            {
                "value": {
                    "creditCard": True, "promptpay": True,
                    "truemoney": False, "linepay": False,
                    "installment": False, "crypto": False,
                },
                "name": "Basic (Card + PromptPay)",
            },
            {
                "value": {
                    "creditCard": True, "promptpay": True,
                    "truemoney": True,  "linepay": True,
                    "installment": True, "crypto": False,
                },
                "name": "Extended (All Thai payment)",
            },
            {
                "value": {
                    "creditCard": True, "promptpay": True,
                    "truemoney": True,  "linepay": True,
                    "installment": True, "crypto": True,
                },
                "name": "Full (All including Crypto)",
            },
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },
    {
        "name": "AI Model Config",
        "key": "ai-model-config",
        "kind": "multivariate",
        "description": "ปรับ Model และ Prompt ของ AI Assistant แบบ Real-time (JSON)",
        "tags": ["json-flag", "ai", "ais-demo"],
        "variations": [
            {
                "value": {
                    "model": "claude-sonnet-4-6",
                    "temperature": 0.7,
                    "maxTokens": 1000,
                    "systemPrompt": "คุณคือ AIS Assistant ผู้ช่วยอัจฉริยะของ AIS ช่วยแนะนำแพ็กเกจที่เหมาะสมสำหรับลูกค้า ตอบเป็นภาษาไทยและเป็นกันเอง",
                    "fallbackModel": "claude-haiku-4-5",
                },
                "name": "Sonnet (Default)",
            },
            {
                "value": {
                    "model": "claude-haiku-4-5",
                    "temperature": 0.5,
                    "maxTokens": 500,
                    "systemPrompt": "คุณคือ AIS Assistant ตอบสั้น กระชับ เป็นภาษาไทย",
                    "fallbackModel": "claude-haiku-4-5",
                },
                "name": "Haiku (Fast & Cheap)",
            },
            {
                "value": {
                    "model": "claude-opus-4-7",
                    "temperature": 0.9,
                    "maxTokens": 2000,
                    "systemPrompt": "คุณคือ AIS Premium Assistant ผู้ช่วยระดับ Premium ให้คำแนะนำเชิงลึกเกี่ยวกับแพ็กเกจ AIS",
                    "fallbackModel": "claude-sonnet-4-6",
                },
                "name": "Opus (Premium Quality)",
            },
        ],
        "defaults": {"onVariation": 0, "offVariation": 0},
        "env_on": False,
    },
]


# ============================================================
#  API HELPERS
# ============================================================

def api_request(method, path, body=None, max_retries=4):
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode("utf-8") if body else None
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": API_TOKEN,
            "Content-Type": "application/json",
            "LD-API-Version": "20240415",
        },
        method=method,
    )
    for attempt in range(max_retries):
        try:
            with urllib.request.urlopen(req) as resp:
                return resp.status, json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            body_text = e.read().decode("utf-8")
            try:
                result = json.loads(body_text)
            except Exception:
                result = {"message": body_text}

            # Rate limit — wait แล้ว retry ด้วย exponential backoff
            if e.code == 429 and attempt < max_retries - 1:
                wait = 5 * (2 ** attempt)   # 5s, 10s, 20s, 40s
                print(f"      ⏳ rate limit — รอ {wait}s แล้ว retry ({attempt+1}/{max_retries-1})...")
                time.sleep(wait)
                continue

            return e.code, result


def create_flag(flag):
    payload = {
        "name":        flag["name"],
        "key":         flag["key"],
        "kind":        flag["kind"],
        "description": flag.get("description", ""),
        "tags":        flag.get("tags", []),
        "variations":  flag["variations"],
        "defaults":    flag["defaults"],
        "temporary":   False,
        "clientSideAvailability": {
            "usingEnvironmentId": True,   # Client-side ID (Flutter Web)
            "usingMobileKey":     True,   # Mobile key (Flutter iOS/Android)
        },
    }
    return api_request("POST", f"/flags/{PROJECT_KEY}", payload)


def enable_flag_in_env(flag_key, env_key="test"):
    """เปิด targeting=on สำหรับ flag ในสิ่งแวดล้อมที่ระบุ"""
    patch = [{"op": "replace", "path": f"/environments/{env_key}/on", "value": True}]
    return api_request("PATCH", f"/flags/{PROJECT_KEY}/{flag_key}", patch)


def get_project():
    return api_request("GET", f"/projects/{PROJECT_KEY}")


# ============================================================
#  MAIN
# ============================================================

def main():
    print("=" * 60)
    print("  LaunchDarkly Flag Setup — AIS Package Store Demo")
    print("=" * 60)

    # Validate config
    if API_TOKEN.startswith("api-xxxx"):
        print("\n❌  ERROR: ยังไม่ได้ใส่ API_TOKEN!")
        print("   แก้ค่า API_TOKEN ในไฟล์นี้ก่อน run")
        print("   วิธีหา: LaunchDarkly > Account settings > Authorization > Access tokens")
        sys.exit(1)

    # Verify project exists
    print(f"\n🔍  ตรวจสอบ project '{PROJECT_KEY}'...")
    status, result = get_project()
    if status != 200:
        print(f"❌  Project '{PROJECT_KEY}' ไม่พบ! (HTTP {status})")
        print(f"   {result.get('message', result)}")
        print("   วิธีหา Project Key: LaunchDarkly > Settings > Projects")
        sys.exit(1)
    print(f"✅  Project: {result.get('name')} (key: {PROJECT_KEY})")

    # Create flags
    print(f"\n📋  สร้าง {len(FLAGS)} flags...\n")
    created = 0
    skipped = 0
    failed  = 0

    for flag in FLAGS:
        status, result = create_flag(flag)
        time.sleep(1.5)  # ป้องกัน rate limit (~10 req/15s)

        if status in (200, 201):
            print(f"  ✅  [{flag['kind']:12s}]  {flag['key']}")
            created += 1
        elif status == 409:
            print(f"  ⚠️   [{flag['kind']:12s}]  {flag['key']}  (มีอยู่แล้ว)")
            skipped += 1
        else:
            msg = result.get("message", str(result))
            print(f"  ❌  [{flag['kind']:12s}]  {flag['key']}  → {msg}")
            failed += 1

    # Summary
    print("\n" + "─" * 60)
    print(f"  ✅ สร้างสำเร็จ : {created}")
    print(f"  ⚠️  มีอยู่แล้ว : {skipped}")
    print(f"  ❌ ผิดพลาด    : {failed}")
    print("─" * 60)

    if failed == 0:
        print("\n🎉  เสร็จแล้ว! เปิด LaunchDarkly Dashboard ดู flags ได้เลย")
        print(f"\n📱  ใส่ Client-side ID นี้ในแอป Flutter:")
        print(f"     {CLIENT_SIDE_ID}")
        print(f"\n     (หน้า Profile > SDK Key field)")
    else:
        print("\n⚠️  มีบางอย่างผิดพลาด ตรวจสอบ error ด้านบน")
        sys.exit(1)


if __name__ == "__main__":
    main()

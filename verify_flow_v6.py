"""
Wow Gift - Phone Verification E2E Test v6
Pre-populates cart via localStorage, focuses on phone verification flow.
"""
import time
import json
import os
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

SCREENSHOT_DIR = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify"
BASE_URL = "http://127.0.0.1:8080"
API_URL = "http://127.0.0.1:8000"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MjhjMDlkMS1kNTFhLTQ4NDMtYTdjNC1mOTkxMDQ4NDgwZTUiLCJyb2xlIjoiY3VzdG9tZXIiLCJleHAiOjE3ODU0MzcyODF9.hP2hkWFLSI6oHgJwAFjBYJIMmU02XCDVCUIWsE3Juwk"

# Pre-built cart JSON with a gift box and one item
CART_DATA = json.dumps({
    "selectedBox": {
        "id": "box-1",
        "name": "صندوق الأناقة",
        "description": "صندوق أنيق بتصميم فاخر مناسب لجميع المناسبات الخاصة",
        "price": 25000.0,
        "image": "",
        "color": "ذهبي",
        "size": "وسط",
        "maxItems": 5
    },
    "items": [
        {
            "product": {
                "id": "prod-1",
                "name": "طقم هدية فاخر",
                "description": "طقم هدية فاخر يحتوي على مجموعة مميزة",
                "price": 75000.0,
                "discountPrice": 59000.0,
                "images": [],
                "categoryId": "cat-1",
                "categoryName": "عطور",
                "storeId": "store-1",
                "storeName": "متجر الهدايا",
                "rating": 4.5,
                "reviewCount": 12,
                "isFavorite": False,
                "inStock": True,
                "createdAt": "2026-01-01T00:00:00.000"
            },
            "quantity": 1
        }
    ],
    "greetingCardId": None,
    "personalMessage": None,
    "isAnonymous": False,
    "senderName": None
})

os.makedirs(SCREENSHOT_DIR, exist_ok=True)

log_lines = []
ss_count = 0

def log(msg):
    print(msg, flush=True)
    log_lines.append(str(msg))

def save_log():
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v6.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines))

def ss(driver, name):
    global ss_count
    ss_count += 1
    path = os.path.join(SCREENSHOT_DIR, name)
    driver.save_screenshot(path)
    log(f"  [SS] {name}")
    return path

def tap(driver, x, y, desc=""):
    log(f"  [TAP] ({x},{y}) {desc}")
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mousePressed", "x": x, "y": y,
        "button": "left", "clickCount": 1
    })
    time.sleep(0.05)
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseReleased", "x": x, "y": y,
        "button": "left", "clickCount": 1
    })
    time.sleep(0.8)

def scroll_down(driver, x, y, dy=300):
    log(f"  [SCROLL] ({x},{y}) dy={dy}")
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseWheel", "x": x, "y": y,
        "deltaX": 0, "deltaY": dy
    })
    time.sleep(1)

def type_text(driver, text):
    for ch in text:
        driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
            "type": "keyDown", "text": ch, "unmodifiedText": ch,
            "key": ch, "code": f"Digit{ch}" if ch.isdigit() else f"Key{ch.upper()}"
        })
        time.sleep(0.03)
        driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
            "type": "keyUp", "key": ch, "code": f"Digit{ch}" if ch.isdigit() else f"Key{ch.upper()}"
        })
        time.sleep(0.03)
    log(f"  [TYPE] '{text}'")

def wait_for_canvas(driver, timeout=40):
    log("  Waiting for Flutter canvas...")
    for i in range(timeout):
        canvases = driver.find_elements(By.TAG_NAME, "canvas")
        big = [c for c in canvases if c.size.get('width', 0) > 100]
        if big:
            log(f"  Canvas found after {i+1}s")
            return True
        time.sleep(1)
    log("  WARNING: No canvas found")
    return False

def main():
    log("=" * 60)
    log("WOW GIFT - Phone Verification E2E Test v6")
    log("=" * 60)

    # First, reset the user's phone_verified status
    resp = requests.get(f"{API_URL}/api/v1/users/me",
                       headers={"Authorization": f"Bearer {AUTH_TOKEN}"})
    if resp.status_code == 200:
        user = resp.json()
        log(f"  User: {user['email']}, phone_verified: {user['phone_verified']}")
    else:
        log(f"  User check failed: {resp.status_code}")

    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--window-size=500,900")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--lang=ar")
    opts.set_capability("goog:loggingPrefs", {"browser": "ALL"})

    driver = webdriver.Chrome(options=opts)
    driver.set_window_size(500, 900)

    try:
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VP_W = vp['w']
        VP_H = vp['h']
        log(f"  Viewport: {VP_W}x{VP_H}")

        BN_Y = VP_H - 25
        TAB_CART_X = 150

        # ===== LOAD APP WITH TOKEN + CART =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        time.sleep(2)

        # Inject auth token, cart data, and ensure phone_verified is false
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');")
        driver.execute_script("localStorage.removeItem('flutter.phone_verified');")
        driver.execute_script("localStorage.removeItem('flutter.verified_phone');")
        cart_escaped = CART_DATA.replace("'", "\\'")
        driver.execute_script(f"localStorage.setItem('flutter.cart_data', '{cart_escaped}');")
        log("  Token + cart data injected")

        # Reload
        driver.get(BASE_URL)
        wait_for_canvas(driver, timeout=40)
        log("  Waiting 8s for splash...")
        time.sleep(8)

        # ===== STEP 1: HOME SCREEN =====
        log("\n=== STEP 1: HOME SCREEN ===")
        ss(driver, "v6_01_home.png")
        log("  ASSERTION A-1: Home screen, NO phone entry")

        # ===== STEP 2: BROWSE TABS (quick check) =====
        log("\n=== STEP 2: BROWSE TABS ===")
        tap(driver, 250, BN_Y, "صناديق")
        time.sleep(1.5)
        ss(driver, "v6_02_boxes.png")
        log("  ASSERTION A-2: Boxes, NO phone")

        tap(driver, 350, BN_Y, "المناسبات")
        time.sleep(1.5)
        ss(driver, "v6_03_occasions.png")
        log("  ASSERTION A-3: Occasions, NO phone")

        tap(driver, 50, BN_Y, "حسابي")
        time.sleep(1.5)
        ss(driver, "v6_04_profile.png")
        log("  ASSERTION A-4: Profile, NO phone")

        # ===== STEP 3: CART WITH ITEMS =====
        log("\n=== STEP 3: CART WITH ITEMS ===")
        tap(driver, TAB_CART_X, BN_Y, "السلة")
        time.sleep(2)
        ss(driver, "v6_05_cart.png")
        log("  Cart should show items (pre-populated)")

        # ===== STEP 4: SCROLL TO CHECKOUT =====
        log("\n=== STEP 4: SCROLL TO CHECKOUT ===")
        # Scroll down multiple times to find the checkout button
        for i in range(10):
            scroll_down(driver, VP_W // 2, VP_H // 2, 300)
            time.sleep(0.3)
        time.sleep(1)
        ss(driver, "v6_06_scrolled.png")

        # ===== STEP 5: TAP CHECKOUT =====
        log("\n=== STEP 5: TAP CHECKOUT ===")
        # The checkout button is full-width, try multiple y positions
        # It should be near the bottom of the scrolled content
        for y in range(VP_H - 50, VP_H - 300, -50):
            tap(driver, VP_W // 2, y, f"checkout at y={y}")
            time.sleep(0.5)
        time.sleep(2)
        ss(driver, "v6_07_after_checkout.png")
        log("  ASSERTION B: Phone entry should appear")

        # ===== STEP 6: PHONE ENTRY =====
        log("\n=== STEP 6: PHONE ENTRY ===")
        ss(driver, "v6_08_phone.png")

        # Click phone field
        tap(driver, 100, int(VP_H * 0.45), "phone field")
        time.sleep(1)
        type_text(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v6_09_phone_typed.png")

        # Submit
        tap(driver, VP_W // 2, int(VP_H * 0.68), "إرسال رمز التحقق")
        time.sleep(3)
        ss(driver, "v6_10_after_submit.png")

        # ===== STEP 7: OTP =====
        log("\n=== STEP 7: OTP ===")
        ss(driver, "v6_11_otp.png")
        time.sleep(3)  # Wait for prefill
        ss(driver, "v6_12_otp_wait.png")

        # Tap confirm
        tap(driver, VP_W // 2, int(VP_H * 0.65), "تأكيد ومتابعة")
        time.sleep(3)
        ss(driver, "v6_13_after_verify.png")

        # ===== STEP 8: AUTO-CONTINUE =====
        log("\n=== STEP 8: AUTO-CONTINUE ===")
        ss(driver, "v6_14_checkout.png")
        log("  ASSERTION: Should be on checkout screen")

        # ===== STEP 9: SKIP BEHAVIOR =====
        log("\n=== STEP 9: SKIP ===")
        tap(driver, VP_W - 25, 40, "back")
        time.sleep(2)
        tap(driver, TAB_CART_X, BN_Y, "السلة")
        time.sleep(2)
        for i in range(10):
            scroll_down(driver, VP_W // 2, VP_H // 2, 300)
            time.sleep(0.2)
        time.sleep(1)
        for y in range(VP_H - 50, VP_H - 300, -50):
            tap(driver, VP_W // 2, y, f"checkout2 at y={y}")
            time.sleep(0.3)
        time.sleep(2)
        ss(driver, "v6_15_skip.png")
        log("  ASSERTION: Should skip phone, go to checkout")

        # Console
        log("\n=== CONSOLE ===")
        try:
            logs = driver.get_log("browser")
            severe = [e for e in logs if e.get("level") == "SEVERE"]
            log(f"  SEVERE: {len(severe)}")
            seen = set()
            for e in severe:
                msg = e.get('message', '')[:150]
                if msg not in seen:
                    seen.add(msg)
                    log(f"    {msg}")
        except Exception as e:
            log(f"  {e}")

    except Exception as e:
        log(f"\n!!! {e}")
        import traceback
        log(traceback.format_exc())
        try: ss(driver, "v6_error.png")
        except: pass
    finally:
        driver.quit()

    log(f"\nScreenshots: {ss_count}")
    save_log()

if __name__ == "__main__":
    main()

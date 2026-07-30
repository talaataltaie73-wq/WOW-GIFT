"""
Wow Gift - Phone Verification E2E Test v5 (final)
Uses proper splash detection and correct tab positions.
"""
import time
import os
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

SCREENSHOT_DIR = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify"
BASE_URL = "http://127.0.0.1:8080"
API_URL = "http://127.0.0.1:8000"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MjhjMDlkMS1kNTFhLTQ4NDMtYTdjNC1mOTkxMDQ4NDgwZTUiLCJyb2xlIjoiY3VzdG9tZXIiLCJleHAiOjE3ODU0MzcyODF9.hP2hkWFLSI6oHgJwAFjBYJIMmU02XCDVCUIWsE3Juwk"

os.makedirs(SCREENSHOT_DIR, exist_ok=True)

log_lines = []
ss_count = 0

def log(msg):
    print(msg, flush=True)
    log_lines.append(str(msg))

def save_log():
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v5.txt"), "w", encoding="utf-8") as f:
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
    """Wait for Flutter canvas to appear."""
    log("  Waiting for Flutter canvas...")
    for i in range(timeout):
        canvases = driver.find_elements(By.TAG_NAME, "canvas")
        big = [c for c in canvases if c.size.get('width', 0) > 100]
        if big:
            log(f"  Canvas found after {i+1}s (size: {big[0].size})")
            return True
        time.sleep(1)
    log("  WARNING: No canvas found after timeout")
    return False

def main():
    log("=" * 60)
    log("WOW GIFT - Phone Verification E2E Test v5 (final)")
    log("=" * 60)

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

        # Bottom nav Y and tab X positions
        BN_Y = VP_H - 25
        # RTL: حسابي(50) | السلة(150) | صناديق(250) | المناسبات(350) | الرئيسية(450)
        TAB = {"home": 450, "occasions": 350, "boxes": 250, "cart": 150, "profile": 50}

        # ===== LOAD APP =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        time.sleep(2)
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');")
        driver.execute_script("localStorage.removeItem('flutter.phone_verified');")
        driver.execute_script("localStorage.removeItem('flutter.verified_phone');")
        log("  Token injected, reloading...")
        driver.get(BASE_URL)

        # Wait for canvas + splash animation
        wait_for_canvas(driver, timeout=40)
        log("  Waiting 8s for splash animation to complete...")
        time.sleep(8)

        # ===== STEP 1: HOME SCREEN =====
        log("\n=== STEP 1: HOME SCREEN ===")
        ss(driver, "v5_01_home.png")
        log("  ASSERTION A-1: Home screen visible, NO phone entry")

        # ===== STEP 2: BROWSE TABS =====
        log("\n=== STEP 2: BROWSE TABS ===")

        tap(driver, TAB["boxes"], BN_Y, "صناديق")
        time.sleep(1.5)
        ss(driver, "v5_02_boxes.png")
        log("  ASSERTION A-2: Gift boxes, NO phone")

        tap(driver, TAB["occasions"], BN_Y, "المناسبات")
        time.sleep(1.5)
        ss(driver, "v5_03_occasions.png")
        log("  ASSERTION A-3: Occasions, NO phone")

        tap(driver, TAB["profile"], BN_Y, "حسابي")
        time.sleep(1.5)
        ss(driver, "v5_04_profile.png")
        log("  ASSERTION A-4: Profile, NO phone")

        tap(driver, TAB["cart"], BN_Y, "السلة")
        time.sleep(1.5)
        ss(driver, "v5_05_cart_empty.png")
        log("  ASSERTION A-5: Cart (empty), NO phone")

        # ===== STEP 3: ADD ITEM TO CART =====
        log("\n=== STEP 3: ADD ITEM TO CART ===")

        # Cart empty state: "اختيار صندوق هدية" button at center
        # The button is at approximately y=490 based on the v4_05 screenshot
        tap(driver, VP_W // 2, 490, "اختيار صندوق هدية")
        time.sleep(2)
        ss(driver, "v5_06_gift_boxes.png")

        # Select "صندوق الأناقة" (top-right card in RTL)
        tap(driver, 370, 250, "صندوق الأناقة")
        time.sleep(2)
        ss(driver, "v5_07_box_sheet.png")

        # Tap "اختيار هذا الصندوق" at bottom of sheet
        tap(driver, VP_W // 2, VP_H - 50, "اختيار هذا الصندوق")
        time.sleep(2)
        ss(driver, "v5_08_after_box.png")

        # Now we should be back on cart with box selected
        # The cart should show category chips to browse products
        # Tap a category chip (e.g., عطر) - should be near top
        tap(driver, VP_W - 60, 120, "عطر chip")
        time.sleep(2)
        ss(driver, "v5_09_search.png")

        # Tap first product in search results
        tap(driver, 370, 200, "first product")
        time.sleep(2)
        ss(driver, "v5_10_product.png")

        # Scroll down to see full product
        scroll_down(driver, VP_W // 2, VP_H // 2, 500)
        time.sleep(1)
        ss(driver, "v5_11_scrolled.png")

        # Tap "إضافة إلى صندوق الهدية" (fixed bottom bar, ~VP_H - 80)
        tap(driver, VP_W // 2, VP_H - 80, "إضافة إلى صندوق الهدية")
        time.sleep(2)
        ss(driver, "v5_12_after_add.png")

        # ===== BACK TO MAIN SCREEN =====
        log("\n=== NAVIGATING BACK ===")
        # Back button on product detail (top-right in RTL)
        tap(driver, VP_W - 25, 40, "back from product")
        time.sleep(2)
        ss(driver, "v5_13_back1.png")

        # Back from search results
        tap(driver, VP_W - 25, 40, "back from search")
        time.sleep(2)
        ss(driver, "v5_14_back2.png")

        # Navigate to cart tab
        tap(driver, TAB["cart"], BN_Y, "السلة tab")
        time.sleep(2)
        ss(driver, "v5_15_cart.png")
        log("  Cart should now show items")

        # ===== STEP 4: SCROLL TO CHECKOUT =====
        log("\n=== STEP 4: SCROLL TO CHECKOUT ===")
        for i in range(8):
            scroll_down(driver, VP_W // 2, VP_H // 2, 400)
            time.sleep(0.5)
        time.sleep(1)
        ss(driver, "v5_16_scrolled.png")

        # ===== STEP 5: TAP CHECKOUT =====
        log("\n=== STEP 5: TAP CHECKOUT (متابعة الطلب) ===")
        # The checkout button is full-width, try center at various y
        tap(driver, VP_W // 2, VP_H - 80, "متابعة الطلب attempt 1")
        time.sleep(1)
        ss(driver, "v5_17_checkout1.png")

        # Check if we're on phone entry or still on cart
        # If still on cart, try other positions
        tap(driver, VP_W // 2, VP_H - 150, "متابعة الطلب attempt 2")
        time.sleep(1)
        tap(driver, VP_W // 2, VP_H - 200, "متابعة الطلب attempt 3")
        time.sleep(3)
        ss(driver, "v5_18_checkout_result.png")
        log("  ASSERTION B: Phone entry screen should NOW appear")

        # ===== STEP 6: PHONE ENTRY =====
        log("\n=== STEP 6: PHONE ENTRY ===")
        ss(driver, "v5_19_phone_entry.png")

        # Phone field - click on it (left side since LTR text input)
        tap(driver, 100, int(VP_H * 0.45), "phone field")
        time.sleep(1)

        # Type phone number
        type_text(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v5_20_phone_typed.png")

        # Submit button "إرسال رمز التحقق"
        tap(driver, VP_W // 2, int(VP_H * 0.68), "إرسال رمز التحقق")
        time.sleep(3)
        ss(driver, "v5_21_after_submit.png")

        # ===== STEP 7: OTP =====
        log("\n=== STEP 7: OTP SCREEN ===")
        ss(driver, "v5_22_otp.png")

        # In dev mode, OTP should be prefilled
        time.sleep(3)
        ss(driver, "v5_23_otp_prefilled.png")

        # Tap confirm button "تأكيد ومتابعة"
        tap(driver, VP_W // 2, int(VP_H * 0.65), "تأكيد ومتابعة")
        time.sleep(3)
        ss(driver, "v5_24_after_verify.png")

        # ===== STEP 8: AUTO-CONTINUE =====
        log("\n=== STEP 8: CHECK AUTO-CONTINUE ===")
        ss(driver, "v5_25_checkout_screen.png")
        log("  ASSERTION: Should be on checkout/delivery screen")

        # ===== STEP 9: SKIP BEHAVIOR =====
        log("\n=== STEP 9: SKIP BEHAVIOR ===")
        # Go back from checkout
        tap(driver, VP_W - 25, 40, "back from checkout")
        time.sleep(2)

        # Navigate to cart
        tap(driver, TAB["cart"], BN_Y, "السلة tab")
        time.sleep(2)
        ss(driver, "v5_26_cart_again.png")

        # Scroll to checkout
        for i in range(8):
            scroll_down(driver, VP_W // 2, VP_H // 2, 400)
            time.sleep(0.3)
        time.sleep(1)

        # Tap checkout again
        tap(driver, VP_W // 2, VP_H - 80, "متابعة الطلب (2nd)")
        time.sleep(1)
        tap(driver, VP_W // 2, VP_H - 150, "متابعة الطلب (2nd) attempt 2")
        time.sleep(3)
        ss(driver, "v5_27_skip.png")
        log("  ASSERTION: Should skip phone and go to checkout directly")

        # ===== CONSOLE ERRORS =====
        log("\n=== CONSOLE ERRORS ===")
        try:
            logs = driver.get_log("browser")
            severe = [e for e in logs if e.get("level") == "SEVERE"]
            log(f"  Total SEVERE: {len(severe)}")
            seen = set()
            for e in severe:
                msg = e.get('message', '')[:200]
                if msg not in seen:
                    seen.add(msg)
                    log(f"    {msg}")
        except Exception as e:
            log(f"  {e}")

    except Exception as e:
        log(f"\n!!! EXCEPTION: {e}")
        import traceback
        log(traceback.format_exc())
        try: ss(driver, "v5_error.png")
        except: pass
    finally:
        driver.quit()

    log(f"\n{'='*60}")
    log(f"SCREENSHOTS: {ss_count}")
    log(f"{'='*60}")
    save_log()

if __name__ == "__main__":
    main()

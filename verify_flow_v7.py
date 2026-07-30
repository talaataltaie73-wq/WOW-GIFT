"""
Wow Gift - Phone Verification E2E Test v7 (final)
Proper navigation stack handling.
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

os.makedirs(SCREENSHOT_DIR, exist_ok=True)

log_lines = []
ss_count = 0

def log(msg):
    print(msg, flush=True)
    log_lines.append(str(msg))

def save_log():
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v7.txt"), "w", encoding="utf-8") as f:
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
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseWheel", "x": x, "y": y,
        "deltaX": 0, "deltaY": dy
    })
    time.sleep(0.5)

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

def main():
    log("=" * 60)
    log("WOW GIFT - Phone Verification E2E Test v7")
    log("=" * 60)

    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--window-size=500,900")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.set_capability("goog:loggingPrefs", {"browser": "ALL"})

    driver = webdriver.Chrome(options=opts)
    driver.set_window_size(500, 900)

    try:
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VP_W = vp['w']
        VP_H = vp['h']
        log(f"  Viewport: {VP_W}x{VP_H}")

        BN_Y = VP_H - 25  # Bottom nav Y
        # Tab X positions (RTL): حسابي(50) | السلة(150) | صناديق(250) | المناسبات(350) | الرئيسية(450)

        # ===== LOAD APP =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        time.sleep(2)
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');")
        driver.execute_script("localStorage.removeItem('flutter.phone_verified');")
        driver.execute_script("localStorage.removeItem('flutter.verified_phone');")
        driver.get(BASE_URL)

        # Wait for Flutter to load (canvas detection + splash)
        log("  Waiting for Flutter...")
        for i in range(40):
            canvases = driver.find_elements(By.TAG_NAME, "canvas")
            if any(c.size.get('width', 0) > 100 for c in canvases):
                log(f"  Canvas found at {i+1}s")
                break
            time.sleep(1)
        log("  Waiting 8s for splash animation...")
        time.sleep(8)

        # ===== STEP 1: HOME SCREEN =====
        log("\n=== STEP 1: HOME SCREEN ===")
        ss(driver, "v7_01_home.png")

        # ===== STEP 2: BROWSE TABS (Assertion A) =====
        log("\n=== STEP 2: BROWSE TABS ===")
        tap(driver, 250, BN_Y, "صناديق tab")
        time.sleep(1)
        ss(driver, "v7_02_boxes.png")

        tap(driver, 350, BN_Y, "المناسبات tab")
        time.sleep(1)
        ss(driver, "v7_03_occasions.png")

        tap(driver, 50, BN_Y, "حسابي tab")
        time.sleep(1)
        ss(driver, "v7_04_profile.png")

        # ===== STEP 3: CART (EMPTY) =====
        log("\n=== STEP 3: CART (EMPTY) ===")
        tap(driver, 150, BN_Y, "السلة tab")
        time.sleep(1.5)
        ss(driver, "v7_05_cart_empty.png")
        log("  ASSERTION A-5: Cart empty, NO phone entry")

        # ===== STEP 4: CHOOSE BOX =====
        log("\n=== STEP 4: CHOOSE BOX ===")
        # "اختيار صندوق هدية" button at center (~y=490)
        tap(driver, VP_W // 2, 490, "اختيار صندوق هدية")
        time.sleep(2)
        ss(driver, "v7_06_boxes_selection.png")

        # Select "صندوق الأناقة" (top-right card)
        tap(driver, 370, 250, "صندوق الأناقة")
        time.sleep(2)
        ss(driver, "v7_07_box_sheet.png")

        # Tap "اختيار هذا الصندوق" at bottom of sheet
        tap(driver, VP_W // 2, VP_H - 50, "اختيار هذا الصندوق")
        time.sleep(2)
        ss(driver, "v7_08_after_box.png")

        # ===== STEP 5: SEARCH FOR PRODUCT =====
        log("\n=== STEP 5: SEARCH FOR PRODUCT ===")
        # After selecting box, we should be on search/browse screen
        # Tap "عطر" chip
        tap(driver, 440, 120, "عطر chip")
        time.sleep(2)
        ss(driver, "v7_09_search.png")

        # Tap first product in results
        tap(driver, 370, 250, "first product")
        time.sleep(2)
        ss(driver, "v7_10_product.png")

        # ===== STEP 6: ADD TO CART =====
        log("\n=== STEP 6: ADD TO CART ===")
        # "إضافة إلى صندوق الهدية" button in fixed bottom bar
        tap(driver, VP_W // 2, VP_H - 80, "إضافة إلى صندوق الهدية")
        time.sleep(2)
        ss(driver, "v7_11_after_add.png")

        # ===== STEP 7: NAVIGATE BACK TO CART =====
        log("\n=== STEP 7: NAVIGATE BACK ===")
        # Navigation stack: Cart(empty) → GiftBoxes → Search → ProductDetail
        # Need to go back 3 times to reach Cart tab

        # Back from ProductDetail → Search
        tap(driver, VP_W - 25, 40, "back from product")
        time.sleep(1.5)
        ss(driver, "v7_12_back_to_search.png")

        # Back from Search → GiftBoxes
        tap(driver, VP_W - 25, 40, "back from search")
        time.sleep(1.5)
        ss(driver, "v7_13_back_to_boxes.png")

        # Back from GiftBoxes → Cart
        tap(driver, VP_W - 25, 40, "back from boxes")
        time.sleep(1.5)
        ss(driver, "v7_14_back_to_cart.png")
        log("  Cart should now show items")

        # ===== STEP 8: SCROLL TO CHECKOUT =====
        log("\n=== STEP 8: SCROLL TO CHECKOUT ===")
        for i in range(8):
            scroll_down(driver, VP_W // 2, VP_H // 2, 400)
        time.sleep(1)
        ss(driver, "v7_15_cart_scrolled.png")

        # ===== STEP 9: TAP CHECKOUT =====
        log("\n=== STEP 9: TAP CHECKOUT ===")
        # The "متابعة الطلب" button should be visible after scrolling
        # Try clicking at various y positions
        tap(driver, VP_W // 2, VP_H - 80, "checkout attempt 1")
        time.sleep(1)
        ss(driver, "v7_16_checkout1.png")

        # If still on cart, try scrolling more and clicking
        tap(driver, VP_W // 2, VP_H - 150, "checkout attempt 2")
        time.sleep(1)
        tap(driver, VP_W // 2, VP_H - 200, "checkout attempt 3")
        time.sleep(2)
        ss(driver, "v7_17_checkout_result.png")
        log("  ASSERTION B: Phone entry should appear NOW")

        # ===== STEP 10: PHONE ENTRY =====
        log("\n=== STEP 10: PHONE ENTRY ===")
        ss(driver, "v7_18_phone.png")

        # Phone field
        tap(driver, 100, int(VP_H * 0.45), "phone field")
        time.sleep(1)
        type_text(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v7_19_phone_typed.png")

        # Submit
        tap(driver, VP_W // 2, int(VP_H * 0.68), "إرسال رمز التحقق")
        time.sleep(3)
        ss(driver, "v7_20_after_submit.png")

        # ===== STEP 11: OTP =====
        log("\n=== STEP 11: OTP ===")
        ss(driver, "v7_21_otp.png")
        time.sleep(3)
        ss(driver, "v7_22_otp_wait.png")

        # Confirm
        tap(driver, VP_W // 2, int(VP_H * 0.65), "تأكيد ومتابعة")
        time.sleep(3)
        ss(driver, "v7_23_after_verify.png")

        # ===== STEP 12: AUTO-CONTINUE =====
        log("\n=== STEP 12: AUTO-CONTINUE ===")
        ss(driver, "v7_24_checkout.png")

        # ===== STEP 13: SKIP BEHAVIOR =====
        log("\n=== STEP 13: SKIP ===")
        tap(driver, VP_W - 25, 40, "back from checkout")
        time.sleep(2)
        tap(driver, 150, BN_Y, "السلة tab")
        time.sleep(2)
        for i in range(8):
            scroll_down(driver, VP_W // 2, VP_H // 2, 400)
        time.sleep(1)
        tap(driver, VP_W // 2, VP_H - 80, "checkout 2nd")
        time.sleep(1)
        tap(driver, VP_W // 2, VP_H - 150, "checkout 2nd attempt 2")
        time.sleep(2)
        ss(driver, "v7_25_skip.png")
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
        try: ss(driver, "v7_error.png")
        except: pass
    finally:
        driver.quit()

    log(f"\nScreenshots: {ss_count}")
    save_log()

if __name__ == "__main__":
    main()

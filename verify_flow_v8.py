"""
Wow Gift - Phone + OTP flow test v8
Focus: type phone number, submit, verify OTP, check auto-continue and skip.
Uses Input.insertText for Flutter canvas text input.
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
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v8.txt"), "w", encoding="utf-8") as f:
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

def type_text_insert(driver, text):
    """Use Input.insertText which works better with Flutter canvas."""
    driver.execute_cdp_cmd("Input.insertText", {"text": text})
    log(f"  [INSERT_TEXT] '{text}'")
    time.sleep(0.3)

def type_text_char(driver, text):
    """Type character by character using keyDown/char/keyUp."""
    for ch in text:
        driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
            "type": "char",
            "text": ch,
            "unmodifiedText": ch,
        })
        time.sleep(0.05)
    log(f"  [TYPE_CHAR] '{text}'")
    time.sleep(0.3)

def type_text_all_methods(driver, text, desc=""):
    """Try multiple input methods for Flutter canvas."""
    log(f"  Trying insertText for: {text}")
    driver.execute_cdp_cmd("Input.insertText", {"text": text})
    time.sleep(0.5)

def main():
    log("=" * 60)
    log("WOW GIFT - Phone/OTP Flow Test v8")
    log("=" * 60)

    # First, reset phone_verified via API
    log("\n=== RESET PHONE VERIFICATION ===")
    try:
        headers = {"Authorization": f"Bearer {AUTH_TOKEN}"}
        # Check current user status
        r = requests.get(f"{API_URL}/api/v1/auth/me", headers=headers)
        log(f"  /auth/me status: {r.status_code}")
        if r.status_code == 200:
            user = r.json()
            log(f"  phone_verified: {user.get('phone_verified')}")
            log(f"  phone: {user.get('phone')}")
        else:
            log(f"  Response: {r.text[:200]}")
    except Exception as e:
        log(f"  API error: {e}")

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
        BN_Y = VP_H - 25

        # ===== LOAD APP =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        time.sleep(2)
        # Set auth token and clear phone verification
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');")
        driver.execute_script("localStorage.removeItem('flutter.phone_verified');")
        driver.execute_script("localStorage.removeItem('flutter.verified_phone');")
        driver.get(BASE_URL)

        log("  Waiting for Flutter...")
        for i in range(40):
            canvases = driver.find_elements(By.TAG_NAME, "canvas")
            if any(c.size.get('width', 0) > 100 for c in canvases):
                log(f"  Canvas found at {i+1}s")
                break
            time.sleep(1)
        log("  Waiting 8s for splash...")
        time.sleep(8)

        ss(driver, "v8_01_home.png")

        # ===== GO TO CART =====
        log("\n=== GO TO CART ===")
        tap(driver, 150, BN_Y, "السلة tab")
        time.sleep(1.5)
        ss(driver, "v8_02_cart.png")

        # ===== CHOOSE BOX =====
        log("\n=== CHOOSE BOX ===")
        tap(driver, VP_W // 2, 490, "اختيار صندوق هدية")
        time.sleep(2)
        ss(driver, "v8_03_boxes.png")

        # Select first box (صندوق الأناقة - top right)
        tap(driver, 370, 250, "صندوق الأناقة")
        time.sleep(2)
        ss(driver, "v8_04_box_sheet.png")

        # Tap "اختيار هذا الصندوق"
        tap(driver, VP_W // 2, VP_H - 50, "اختيار هذا الصندوق")
        time.sleep(2)
        ss(driver, "v8_05_after_box.png")

        # ===== SEARCH & ADD PRODUCT =====
        log("\n=== SEARCH & ADD ===")
        # Tap عطر chip
        tap(driver, 440, 120, "عطر chip")
        time.sleep(2)

        # Tap first product
        tap(driver, 370, 250, "first product")
        time.sleep(2)
        ss(driver, "v8_06_product.png")

        # Add to cart
        tap(driver, VP_W // 2, VP_H - 80, "إضافة إلى صندوق الهدية")
        time.sleep(2)
        ss(driver, "v8_07_added.png")

        # ===== NAVIGATE BACK TO CART =====
        log("\n=== BACK TO CART ===")
        # Back from product → search
        tap(driver, VP_W - 25, 40, "back")
        time.sleep(1)
        # Back from search → boxes
        tap(driver, VP_W - 25, 40, "back")
        time.sleep(1)
        # Back from boxes → cart
        tap(driver, VP_W - 25, 40, "back")
        time.sleep(1.5)
        ss(driver, "v8_08_cart_items.png")

        # ===== SCROLL TO CHECKOUT =====
        log("\n=== SCROLL TO CHECKOUT ===")
        for i in range(6):
            scroll_down(driver, VP_W // 2, VP_H // 2, 400)
        time.sleep(1)
        ss(driver, "v8_09_scrolled.png")

        # ===== TAP CHECKOUT =====
        log("\n=== TAP CHECKOUT ===")
        # The "متابعة الطلب" button should be at the bottom
        # It's a fixed bottom bar with the button
        tap(driver, VP_W // 2, VP_H - 40, "متابعة الطلب")
        time.sleep(2)
        ss(driver, "v8_10_phone_entry.png")

        # ===== PHONE ENTRY =====
        log("\n=== PHONE ENTRY ===")
        # Tap the phone input field (it has placeholder "5XX XXX XXXX")
        # The field is at approximately y=300, x=200 (center of the field)
        tap(driver, 200, 300, "phone field")
        time.sleep(1)
        ss(driver, "v8_11_field_focused.png")

        # Try insertText
        type_text_all_methods(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v8_12_after_type.png")

        # If insertText didn't work, try char-by-char
        # Check if field still shows placeholder
        # Try clicking field again and using different method
        tap(driver, 200, 300, "phone field again")
        time.sleep(0.5)
        type_text_char(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v8_13_after_char.png")

        # Try yet another approach: use keyboard events
        tap(driver, 200, 300, "phone field 3rd")
        time.sleep(0.5)
        for ch in "7501234567":
            driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
                "type": "keyDown",
                "key": ch,
                "code": f"Digit{ch}",
                "text": ch,
                "windowsVirtualKeyCode": ord(ch),
                "nativeVirtualKeyCode": ord(ch),
            })
            time.sleep(0.02)
            driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
                "type": "keyUp",
                "key": ch,
                "code": f"Digit{ch}",
                "windowsVirtualKeyCode": ord(ch),
                "nativeVirtualKeyCode": ord(ch),
            })
            time.sleep(0.02)
        log("  [KEYDOWN/UP] '7501234567'")
        time.sleep(1)
        ss(driver, "v8_14_after_keydown.png")

        # ===== SUBMIT PHONE =====
        log("\n=== SUBMIT PHONE ===")
        # "إرسال رمز التحقق" button at ~y=497
        tap(driver, VP_W // 2, 497, "إرسال رمز التحقق")
        time.sleep(3)
        ss(driver, "v8_15_after_submit.png")

        # ===== CHECK IF OTP SCREEN =====
        log("\n=== OTP CHECK ===")
        ss(driver, "v8_16_otp.png")

        # If we're on OTP screen, the dev code should be prefilled
        # Wait for auto-submit or tap confirm
        time.sleep(3)
        ss(driver, "v8_17_otp_wait.png")

        # Tap confirm button
        tap(driver, VP_W // 2, int(VP_H * 0.7), "تأكيد ومتابعة")
        time.sleep(3)
        ss(driver, "v8_18_after_confirm.png")

        # ===== ALTERNATIVE: Use API to verify phone directly =====
        log("\n=== API PHONE VERIFY ===")
        try:
            # Request OTP via API
            r = requests.post(f"{API_URL}/api/v1/phone/request-otp", 
                json={"phone": "+9647501234567", "channel": "sms"},
                headers={"Authorization": f"Bearer {AUTH_TOKEN}"})
            log(f"  request-otp: {r.status_code} {r.text[:200]}")
            
            if r.status_code == 200:
                data = r.json()
                dev_code = data.get("dev_code", "")
                log(f"  dev_code: {dev_code}")
                
                # Verify OTP via API
                r2 = requests.post(f"{API_URL}/api/v1/phone/verify-otp",
                    json={"phone": "+9647501234567", "code": dev_code},
                    headers={"Authorization": f"Bearer {AUTH_TOKEN}"})
                log(f"  verify-otp: {r2.status_code} {r2.text[:200]}")
        except Exception as e:
            log(f"  API error: {e}")

        # Now reload the app with phone_verified=true in localStorage
        log("\n=== RELOAD WITH VERIFIED PHONE ===")
        driver.execute_script("localStorage.setItem('flutter.phone_verified', 'true');")
        driver.execute_script("localStorage.setItem('flutter.verified_phone', '+9647501234567');")
        driver.get(BASE_URL)
        
        log("  Waiting for Flutter reload...")
        for i in range(40):
            canvases = driver.find_elements(By.TAG_NAME, "canvas")
            if any(c.size.get('width', 0) > 100 for c in canvases):
                log(f"  Canvas found at {i+1}s")
                break
            time.sleep(1)
        time.sleep(8)
        ss(driver, "v8_19_reloaded.png")

        # Go to cart
        tap(driver, 150, BN_Y, "السلة tab")
        time.sleep(1.5)
        ss(driver, "v8_20_cart_reload.png")

        # Scroll to checkout
        for i in range(6):
            scroll_down(driver, VP_W // 2, VP_H // 2, 400)
        time.sleep(1)
        ss(driver, "v8_21_scrolled.png")

        # Tap checkout - should SKIP phone entry
        tap(driver, VP_W // 2, VP_H - 40, "متابعة الطلب (skip test)")
        time.sleep(2)
        ss(driver, "v8_22_skip_result.png")
        log("  ASSERTION: Should skip phone, go directly to checkout/delivery")

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
        try: ss(driver, "v8_error.png")
        except: pass
    finally:
        driver.quit()

    log(f"\nScreenshots: {ss_count}")
    save_log()

if __name__ == "__main__":
    main()

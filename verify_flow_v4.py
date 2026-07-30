"""
Wow Gift - Phone Verification E2E Test v4
Fixed tab positions and splash wait.
"""
import time
import json
import os
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

SCREENSHOT_DIR = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify"
BASE_URL = "http://127.0.0.1:8080"
API_URL = "http://127.0.0.1:8000"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MjhjMDlkMS1kNTFhLTQ4NDMtYTdjNC1mOTkxMDQ4NDgwZTUiLCJyb2xlIjoiY3VzdG9tZXIiLCJleHAiOjE3ODU0MzcyODF9.hP2hkWFLSI6oHgJwAFjBYJIMmU02XCDVCUIWsE3Juwk"

os.makedirs(SCREENSHOT_DIR, exist_ok=True)

log_lines = []
ss_count = 0

def log(msg):
    print(msg)
    log_lines.append(msg)

def save_log():
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v4.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines))

def ss(driver, name):
    global ss_count
    ss_count += 1
    path = os.path.join(SCREENSHOT_DIR, name)
    driver.save_screenshot(path)
    log(f"  [SS] {name}")
    return path

def cdp_click(driver, x, y):
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mousePressed", "x": x, "y": y, "button": "left",
        "clickCount": 1, "pointerType": "mouse"
    })
    time.sleep(0.05)
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseReleased", "x": x, "y": y, "button": "left",
        "clickCount": 1, "pointerType": "mouse"
    })
    log(f"  [CLICK] ({x},{y})")

def cdp_scroll(driver, x, y, dy):
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseWheel", "x": x, "y": y,
        "deltaX": 0, "deltaY": dy, "pointerType": "mouse"
    })
    log(f"  [SCROLL] ({x},{y}) dy={dy}")

def cdp_type(driver, text):
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
    log("WOW GIFT - Phone Verification E2E Test v4")
    log("=" * 60)

    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--window-size=500,900")
    opts.add_argument("--force-device-scale-factor=1")
    opts.add_argument("--disable-web-security")
    opts.add_argument("--allow-insecure-localhost")

    driver = webdriver.Chrome(options=opts)

    try:
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VP_W = vp['w']
        VP_H = vp['h']
        log(f"  Viewport: {VP_W}x{VP_H}")

        # Bottom nav: 5 tabs, each 100px wide in 500px viewport
        # RTL order: الرئيسية(450) | صناديق(350) | المناسبات(250) | السلة(150) | حسابي(50)
        BN_Y = VP_H - 25
        TAB_HOME_X = 450
        TAB_BOXES_X = 350
        TAB_OCCASIONS_X = 250
        TAB_CART_X = 150
        TAB_PROFILE_X = 50

        # ===== LOAD APP =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        time.sleep(1)
        driver.execute_script(f"""
            localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');
            localStorage.setItem('flutter.phone_verified', 'false');
        """)
        log("  Token injected, reloading...")
        driver.get(BASE_URL)

        # Wait for Flutter bootstrap + splash animation
        # Flutter web takes ~22s to bootstrap, splash is ~4s animation
        log("  Waiting 30s for Flutter bootstrap + splash...")
        time.sleep(30)

        # ===== STEP 1: HOME SCREEN =====
        log("\n=== STEP 1: HOME SCREEN ===")
        ss(driver, "v4_01_home.png")

        # ===== STEP 2: BROWSE TABS =====
        log("\n=== STEP 2: BROWSE TABS ===")

        cdp_click(driver, TAB_BOXES_X, BN_Y)
        time.sleep(2)
        ss(driver, "v4_02_boxes.png")

        cdp_click(driver, TAB_OCCASIONS_X, BN_Y)
        time.sleep(2)
        ss(driver, "v4_03_occasions.png")

        cdp_click(driver, TAB_PROFILE_X, BN_Y)
        time.sleep(2)
        ss(driver, "v4_04_profile.png")

        cdp_click(driver, TAB_CART_X, BN_Y)
        time.sleep(2)
        ss(driver, "v4_05_cart_empty.png")

        # ===== STEP 3: ADD ITEM =====
        log("\n=== STEP 3: ADD ITEM ===")

        # Cart empty state has "اختيار صندوق هدية" button
        # It should be a large button in the center area
        cdp_click(driver, VP_W // 2, VP_H // 2 + 30)
        time.sleep(2)
        ss(driver, "v4_06_choose_box.png")

        # Select "صندوق الأناقة" (first box, top-right in RTL)
        cdp_click(driver, 370, 300)
        time.sleep(2)
        ss(driver, "v4_07_box_detail.png")

        # Bottom sheet should appear with "اختيار هذا الصندوق"
        # Tap it at the bottom of the screen
        cdp_click(driver, VP_W // 2, VP_H - 50)
        time.sleep(2)
        ss(driver, "v4_08_after_box.png")

        # Now we should be back on cart with box selected
        # Need to add products - tap a category chip or browse
        # Look for category chips near the top of the cart
        cdp_click(driver, VP_W - 60, 120)
        time.sleep(2)
        ss(driver, "v4_09_search.png")

        # Tap first product
        cdp_click(driver, 370, 250)
        time.sleep(2)
        ss(driver, "v4_10_product.png")

        # Tap "إضافة إلى صندوق الهدية" (fixed bottom bar)
        cdp_click(driver, VP_W // 2, VP_H - 80)
        time.sleep(2)
        ss(driver, "v4_11_after_add.png")

        # ===== BACK TO CART =====
        log("\n=== BACK TO CART ===")
        # Back button (top-right in RTL, → arrow)
        cdp_click(driver, VP_W - 25, 40)
        time.sleep(2)
        ss(driver, "v4_12_back1.png")

        # Another back if needed
        cdp_click(driver, VP_W - 25, 40)
        time.sleep(2)
        ss(driver, "v4_13_back2.png")

        # Tap cart tab
        cdp_click(driver, TAB_CART_X, BN_Y)
        time.sleep(2)
        ss(driver, "v4_14_cart.png")

        # ===== SCROLL TO CHECKOUT =====
        log("\n=== SCROLL TO CHECKOUT ===")
        for i in range(6):
            cdp_scroll(driver, VP_W // 2, VP_H // 2, 500)
            time.sleep(0.5)
        time.sleep(1)
        ss(driver, "v4_15_scrolled.png")

        # ===== TAP CHECKOUT =====
        log("\n=== TAP CHECKOUT ===")
        # Try clicking at various y positions to find the button
        for y_pos in [VP_H - 60, VP_H - 100, VP_H - 150, VP_H - 200]:
            cdp_click(driver, VP_W // 2, y_pos)
            time.sleep(1)
        time.sleep(2)
        ss(driver, "v4_16_after_checkout.png")

        # ===== PHONE ENTRY =====
        log("\n=== PHONE ENTRY ===")
        ss(driver, "v4_17_phone.png")

        # Click phone field (center area)
        cdp_click(driver, VP_W // 2 - 80, int(VP_H * 0.45))
        time.sleep(1)
        cdp_type(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v4_18_phone_typed.png")

        # Submit
        cdp_click(driver, VP_W // 2, int(VP_H * 0.68))
        time.sleep(3)
        ss(driver, "v4_19_after_submit.png")

        # ===== OTP =====
        log("\n=== OTP ===")
        ss(driver, "v4_20_otp.png")
        time.sleep(2)
        ss(driver, "v4_21_otp_wait.png")

        # Tap confirm
        cdp_click(driver, VP_W // 2, int(VP_H * 0.65))
        time.sleep(3)
        ss(driver, "v4_22_after_verify.png")

        # ===== AUTO-CONTINUE =====
        log("\n=== AUTO-CONTINUE ===")
        ss(driver, "v4_23_checkout.png")

        # ===== SKIP BEHAVIOR =====
        log("\n=== SKIP BEHAVIOR ===")
        cdp_click(driver, VP_W - 25, 40)
        time.sleep(2)
        cdp_click(driver, TAB_CART_X, BN_Y)
        time.sleep(2)
        for i in range(6):
            cdp_scroll(driver, VP_W // 2, VP_H // 2, 500)
            time.sleep(0.3)
        time.sleep(1)
        cdp_click(driver, VP_W // 2, VP_H - 100)
        time.sleep(3)
        ss(driver, "v4_24_skip.png")

        # Console errors
        log("\n=== CONSOLE ===")
        try:
            logs = driver.get_log("browser")
            severe = [e for e in logs if e.get("level") == "SEVERE"]
            log(f"  SEVERE: {len(severe)}")
            for e in severe[:10]:
                log(f"    {e.get('message','')[:150]}")
        except Exception as e:
            log(f"  {e}")

    except Exception as e:
        log(f"\n!!! {e}")
        import traceback
        log(traceback.format_exc())
        try: ss(driver, "v4_error.png")
        except: pass
    finally:
        driver.quit()

    log(f"\nScreenshots: {ss_count}")
    save_log()

if __name__ == "__main__":
    main()

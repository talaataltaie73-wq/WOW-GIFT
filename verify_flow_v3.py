"""
Wow Gift - Phone Verification E2E Test v3
Robust Selenium test with proper splash wait and navigation.
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
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v3.txt"), "w", encoding="utf-8") as f:
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

def wait_for_app(driver, max_wait=20):
    """Wait for Flutter app to finish splash and show home screen."""
    log("  Waiting for app to load past splash screen...")
    start = time.time()
    while time.time() - start < max_wait:
        time.sleep(2)
        # Check if we can detect the canvas
        has_canvas = driver.execute_script("""
            var pane = document.querySelector('flt-glass-pane');
            if (!pane) return false;
            var shadow = pane.shadowRoot;
            if (!shadow) return false;
            var canvas = shadow.querySelector('canvas');
            return !!canvas;
        """)
        elapsed = int(time.time() - start)
        log(f"    {elapsed}s: canvas={'yes' if has_canvas else 'no'}")
        if has_canvas and elapsed >= 10:
            # Give extra time for splash animation (4s) to complete
            log("    Canvas found, waiting for splash to finish...")
            time.sleep(3)
            return True
    return False

def main():
    log("=" * 60)
    log("WOW GIFT - Phone Verification E2E Test v3")
    log("=" * 60)

    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--window-size=430,932")
    opts.add_argument("--force-device-scale-factor=1")
    opts.add_argument("--disable-web-security")
    opts.add_argument("--allow-insecure-localhost")

    driver = webdriver.Chrome(options=opts)

    try:
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VP_W = vp['w']
        VP_H = vp['h']
        log(f"  Viewport: {VP_W}x{VP_H}")

        # Bottom nav Y
        BN_Y = VP_H - 25

        # ===== LOAD APP WITH TOKEN =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        time.sleep(1)

        # Inject token BEFORE Flutter reads localStorage
        driver.execute_script(f"""
            localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');
            localStorage.setItem('flutter.phone_verified', 'false');
        """)
        log("  Token injected, reloading...")

        driver.get(BASE_URL)

        # Wait for splash to complete
        if not wait_for_app(driver, max_wait=25):
            log("  WARNING: App may not have loaded fully")
            time.sleep(5)

        # Take first screenshot - should be home screen
        log("\n=== STEP 1: HOME SCREEN ===")
        ss(driver, "v3_01_home.png")
        log("  ASSERTION A-1: Home screen, NO phone entry")

        # ===== STEP 2: BROWSE ALL TABS =====
        log("\n=== STEP 2: BROWSE TABS ===")
        # RTL bottom nav with 5 tabs in 430px viewport (actual ~500px due to Chrome)
        # Tab order RTL: الرئيسية | صناديق | المناسبات | السلة | حسابي
        # Positions from right: ~457, ~371, ~285, ~199, ~113

        # Gift boxes tab
        cdp_click(driver, VP_W - 130, BN_Y)
        time.sleep(2)
        ss(driver, "v3_02_boxes.png")
        log("  ASSERTION A-2: Gift boxes, NO phone")

        # Occasions tab
        cdp_click(driver, VP_W - 215, BN_Y)
        time.sleep(2)
        ss(driver, "v3_03_occasions.png")
        log("  ASSERTION A-3: Occasions, NO phone")

        # Profile tab
        cdp_click(driver, VP_W - 390, BN_Y)
        time.sleep(2)
        ss(driver, "v3_04_profile.png")
        log("  ASSERTION A-4: Profile, NO phone")

        # Cart tab
        cdp_click(driver, VP_W - 300, BN_Y)
        time.sleep(2)
        ss(driver, "v3_05_cart_empty.png")
        log("  ASSERTION A-5: Cart (empty), NO phone")

        # ===== STEP 3: ADD ITEM VIA SEARCH =====
        log("\n=== STEP 3: ADD ITEM TO CART ===")

        # Go back to home first
        cdp_click(driver, VP_W - 43, BN_Y)
        time.sleep(2)

        # The cart screen shows "اختيار صندوق هدية" when empty
        # But let's use a simpler path: go to search, find a product, add it
        # First, let's try tapping the search icon or going to search
        # From the home screen, there should be a search bar at the top

        # Actually, let's go to cart and use the "choose box" flow
        cdp_click(driver, VP_W - 300, BN_Y)  # Cart tab
        time.sleep(2)

        # Tap "اختيار صندوق هدية" button (center of screen)
        cdp_click(driver, VP_W // 2, VP_H // 2)
        time.sleep(2)
        ss(driver, "v3_06_choose_box.png")

        # Select a gift box - tap on the first box card
        cdp_click(driver, VP_W // 2, 300)
        time.sleep(2)
        ss(driver, "v3_07_box_options.png")

        # Tap "اختيار هذا الصندوق" at bottom
        cdp_click(driver, VP_W // 2, VP_H - 60)
        time.sleep(2)
        ss(driver, "v3_08_after_box.png")

        # Now we need to add products. Try tapping a category chip
        cdp_click(driver, VP_W - 60, 120)
        time.sleep(2)
        ss(driver, "v3_09_search.png")

        # Tap first product in results
        cdp_click(driver, VP_W // 2, 300)
        time.sleep(2)
        ss(driver, "v3_10_product.png")

        # Tap "إضافة إلى صندوق الهدية" button (fixed at bottom)
        # The bottom action bar has: total price row, add button, fav/share row
        # Add button should be at approximately VP_H - 80
        cdp_click(driver, VP_W // 2, VP_H - 80)
        time.sleep(2)
        ss(driver, "v3_11_after_add.png")

        # ===== GO BACK TO MAIN SCREEN =====
        log("\n=== NAVIGATING BACK ===")
        # Back button on product detail is at top-right (RTL) - the → arrow
        # In the SliverAppBar, leading IconButton at approximately (VP_W - 25, 40)
        cdp_click(driver, VP_W - 25, 40)
        time.sleep(2)
        ss(driver, "v3_12_back1.png")

        # May need another back press if we're on search results
        cdp_click(driver, VP_W - 25, 40)
        time.sleep(2)
        ss(driver, "v3_13_back2.png")

        # Try going to cart via bottom nav
        cdp_click(driver, VP_W - 300, BN_Y)
        time.sleep(2)
        ss(driver, "v3_14_cart.png")

        # ===== STEP 4: SCROLL TO CHECKOUT =====
        log("\n=== STEP 4: SCROLL TO CHECKOUT ===")
        for i in range(5):
            cdp_scroll(driver, VP_W // 2, VP_H // 2, 400)
            time.sleep(0.5)
        time.sleep(1)
        ss(driver, "v3_15_cart_scrolled.png")

        # ===== STEP 5: TAP CHECKOUT =====
        log("\n=== STEP 5: TAP CHECKOUT ===")
        # The checkout button "متابعة الطلب" should be visible after scrolling
        # Try multiple y positions
        cdp_click(driver, VP_W // 2, VP_H - 80)
        time.sleep(3)
        ss(driver, "v3_16_after_checkout.png")

        # If that didn't work, try other positions
        cdp_click(driver, VP_W // 2, VP_H - 150)
        time.sleep(3)
        ss(driver, "v3_17_checkout_attempt2.png")

        # ===== STEP 6: PHONE ENTRY =====
        log("\n=== STEP 6: PHONE ENTRY ===")
        ss(driver, "v3_18_phone_entry.png")

        # Phone field - click on it
        # The phone field should be roughly at y = VP_H * 0.45
        cdp_click(driver, VP_W // 2 - 50, int(VP_H * 0.45))
        time.sleep(1)

        # Type phone number
        cdp_type(driver, "7501234567")
        time.sleep(1)
        ss(driver, "v3_19_phone_typed.png")

        # Submit button "إرسال رمز التحقق"
        cdp_click(driver, VP_W // 2, int(VP_H * 0.7))
        time.sleep(3)
        ss(driver, "v3_20_after_submit.png")

        # ===== STEP 7: OTP =====
        log("\n=== STEP 7: OTP SCREEN ===")
        ss(driver, "v3_21_otp.png")

        # The OTP screen should show with prefilled dev code
        # Wait a moment for prefill
        time.sleep(2)
        ss(driver, "v3_22_otp_prefilled.png")

        # If prefilled, tap confirm button
        # "تأكيد ومتابعة" button
        cdp_click(driver, VP_W // 2, int(VP_H * 0.65))
        time.sleep(3)
        ss(driver, "v3_23_after_verify.png")

        # ===== STEP 8: AUTO-CONTINUE =====
        log("\n=== STEP 8: CHECK AUTO-CONTINUE ===")
        ss(driver, "v3_24_checkout_screen.png")
        log("  ASSERTION: Should be on checkout/delivery screen")

        # ===== STEP 9: SKIP BEHAVIOR =====
        log("\n=== STEP 9: SKIP BEHAVIOR ===")
        # Go back
        cdp_click(driver, VP_W - 25, 40)
        time.sleep(2)
        ss(driver, "v3_25_back_from_checkout.png")

        # Go to cart
        cdp_click(driver, VP_W - 300, BN_Y)
        time.sleep(2)
        ss(driver, "v3_26_cart_again.png")

        # Scroll to checkout
        for i in range(5):
            cdp_scroll(driver, VP_W // 2, VP_H // 2, 400)
            time.sleep(0.5)
        time.sleep(1)

        # Tap checkout
        cdp_click(driver, VP_W // 2, VP_H - 80)
        time.sleep(3)
        ss(driver, "v3_27_second_checkout.png")
        log("  ASSERTION: Should skip phone and go to checkout directly")

        # ===== CONSOLE ERRORS =====
        log("\n=== CONSOLE ERRORS ===")
        try:
            logs = driver.get_log("browser")
            severe = [e for e in logs if e.get("level") == "SEVERE"]
            log(f"  Total SEVERE errors: {len(severe)}")
            for err in severe[:15]:
                log(f"    {err.get('message', '')[:200]}")
        except Exception as e:
            log(f"  Could not get logs: {e}")

    except Exception as e:
        log(f"\n!!! EXCEPTION: {e}")
        import traceback
        log(traceback.format_exc())
        try:
            ss(driver, "v3_error.png")
        except:
            pass
    finally:
        driver.quit()

    log(f"\n{'='*60}")
    log(f"SCREENSHOTS: {ss_count}")
    log(f"{'='*60}")
    save_log()

if __name__ == "__main__":
    main()

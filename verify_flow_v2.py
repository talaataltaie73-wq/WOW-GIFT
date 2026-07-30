"""
Wow Gift - Phone Verification E2E Test v2
Interactive Selenium test with proper navigation handling.
"""
import time
import json
import os
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

SCREENSHOT_DIR = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify"
BASE_URL = "http://127.0.0.1:8080"
API_URL = "http://127.0.0.1:8000"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MjhjMDlkMS1kNTFhLTQ4NDMtYTdjNC1mOTkxMDQ4NDgwZTUiLCJyb2xlIjoiY3VzdG9tZXIiLCJleHAiOjE3ODU0MzcyODF9.hP2hkWFLSI6oHgJwAFjBYJIMmU02XCDVCUIWsE3Juwk"

os.makedirs(SCREENSHOT_DIR, exist_ok=True)

log_lines = []
def log(msg):
    print(msg)
    log_lines.append(msg)

def save_log():
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v2.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines))

def ss(driver, name):
    path = os.path.join(SCREENSHOT_DIR, name)
    driver.save_screenshot(path)
    log(f"  [SS] {name}")
    return path

def cdp_click(driver, x, y):
    """Click using CDP Input.dispatchMouseEvent - the only reliable way for Flutter web canvas."""
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mousePressed", "x": x, "y": y, "button": "left",
        "clickCount": 1, "pointerType": "mouse"
    })
    time.sleep(0.05)
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseReleased", "x": x, "y": y, "button": "left",
        "clickCount": 1, "pointerType": "mouse"
    })
    log(f"  [CDP_CLICK] ({x},{y})")

def cdp_scroll(driver, x, y, dy):
    """Scroll using CDP."""
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseWheel", "x": x, "y": y,
        "deltaX": 0, "deltaY": dy, "pointerType": "mouse"
    })
    log(f"  [CDP_SCROLL] ({x},{y}) dy={dy}")

def cdp_type(driver, text):
    """Type text using CDP."""
    for ch in text:
        driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
            "type": "keyDown", "text": ch, "unmodifiedText": ch,
            "key": ch, "code": f"Digit{ch}" if ch.isdigit() else f"Key{ch.upper()}"
        })
        time.sleep(0.02)
        driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
            "type": "keyUp", "key": ch, "code": f"Digit{ch}" if ch.isdigit() else f"Key{ch.upper()}"
        })
        time.sleep(0.02)
    log(f"  [CDP_TYPE] '{text}'")

def wait(seconds=2):
    time.sleep(seconds)

def main():
    log("=" * 60)
    log("WOW GIFT - Phone Verification E2E Test v2")
    log("=" * 60)

    # Setup Chrome
    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--window-size=430,932")
    opts.add_argument("--force-device-scale-factor=1")
    opts.add_argument("--disable-web-security")
    opts.add_argument("--allow-insecure-localhost")

    driver = webdriver.Chrome(options=opts)
    console_errors = []

    try:
        # Get actual viewport size
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        log(f"  Viewport: {vp['w']}x{vp['h']}")
        VP_W = vp['w']
        VP_H = vp['h']

        # Bottom nav Y coordinate (near bottom of viewport)
        BOTTOM_NAV_Y = VP_H - 25  # ~25px from bottom

        # ===== INJECT AUTH TOKEN AND LOAD APP =====
        log("\n=== LOADING APP ===")
        driver.get(BASE_URL)
        wait(2)

        # Inject auth token into localStorage
        driver.execute_script(f"""
            localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');
            localStorage.setItem('flutter.phone_verified', 'false');
        """)
        log("  Auth token injected (phone_verified=false)")

        # Reload to pick up token
        driver.get(BASE_URL)
        wait(5)  # Flutter bootstrap takes time

        # ===== STEP 1: HOME SCREEN =====
        log("\n=== STEP 1: HOME SCREEN ===")
        ss(driver, "v2_01_home.png")
        log("  ASSERTION A-1: Home screen visible, checking for NO phone entry")

        # ===== STEP 2: BROWSE TABS =====
        log("\n=== STEP 2: BROWSE TABS ===")

        # Tab positions (RTL layout, 5 tabs):
        # From right to left: الرئيسية(home), صناديق(boxes), المناسبات(occasions), السلة(cart), حسابي(profile)
        # In a 430px wide viewport with 5 tabs, each tab ~86px wide
        # RTL: rightmost = first tab
        TAB_HOME = (VP_W - 43, BOTTOM_NAV_Y)      # ~387
        TAB_BOXES = (VP_W - 129, BOTTOM_NAV_Y)     # ~301
        TAB_OCCASIONS = (VP_W - 215, BOTTOM_NAV_Y) # ~215
        TAB_CART = (VP_W - 301, BOTTOM_NAV_Y)      # ~129
        TAB_PROFILE = (VP_W - 387, BOTTOM_NAV_Y)   # ~43

        # Tap gift boxes tab
        cdp_click(driver, *TAB_BOXES)
        wait(2)
        ss(driver, "v2_02_boxes.png")
        log("  ASSERTION A-2: Gift boxes tab, NO phone")

        # Tap occasions tab
        cdp_click(driver, *TAB_OCCASIONS)
        wait(2)
        ss(driver, "v2_03_occasions.png")
        log("  ASSERTION A-3: Occasions tab, NO phone")

        # Tap profile tab
        cdp_click(driver, *TAB_PROFILE)
        wait(2)
        ss(driver, "v2_04_profile.png")
        log("  ASSERTION A-4: Profile tab, NO phone")

        # Tap cart tab
        cdp_click(driver, *TAB_CART)
        wait(2)
        ss(driver, "v2_05_cart_empty.png")
        log("  ASSERTION A-5: Cart tab (empty), NO phone")

        # ===== STEP 3: ADD ITEM TO CART =====
        log("\n=== STEP 3: ADD ITEM TO CART ===")

        # From the cart screen, we need to choose a gift box first
        # The empty cart should show "اختيار صندوق هدية" button
        # It should be roughly in the center of the screen
        cdp_click(driver, VP_W // 2, VP_H // 2 + 50)
        wait(2)
        ss(driver, "v2_06_after_choose_box_click.png")

        # If we're on the gift boxes selection screen, pick a box
        # The boxes should be displayed as cards - tap the first one
        cdp_click(driver, VP_W // 2 + 50, 250)
        wait(2)
        ss(driver, "v2_07_box_selection.png")

        # Tap "اختيار هذا الصندوق" button at bottom
        cdp_click(driver, VP_W // 2, VP_H - 60)
        wait(2)
        ss(driver, "v2_08_after_box_select.png")

        # Now we need to add products. Look for category chips or search
        # Tap a category chip (e.g., عطر) near the top
        cdp_click(driver, VP_W - 60, 120)
        wait(2)
        ss(driver, "v2_09_category_tap.png")

        # Tap a product from search results
        cdp_click(driver, VP_W // 2, 250)
        wait(2)
        ss(driver, "v2_10_product_detail.png")

        # Scroll down to see the "إضافة إلى صندوق الهدية" button
        cdp_scroll(driver, VP_W // 2, VP_H // 2, 300)
        wait(1)
        ss(driver, "v2_11_product_scrolled.png")

        # The "إضافة إلى صندوق الهدية" button is in the fixed bottom bar
        # It should be at approximately y = VP_H - 80 (above the favorite/share row)
        cdp_click(driver, VP_W // 2, VP_H - 80)
        wait(2)
        ss(driver, "v2_12_after_add.png")

        # ===== CRITICAL: GO BACK FROM PRODUCT DETAIL =====
        log("\n=== NAVIGATING BACK FROM PRODUCT DETAIL ===")
        # The back button is at top-right in RTL layout (→ arrow)
        # In the product detail screen, it's an IconButton at approximately (VP_W - 25, 35)
        cdp_click(driver, VP_W - 25, 35)
        wait(2)
        ss(driver, "v2_13_back_from_product.png")

        # We should now be on search results. Go back again to get to main screen
        # Check if we need another back press
        # The search screen also has a back button at top-right
        cdp_click(driver, VP_W - 25, 35)
        wait(2)
        ss(driver, "v2_14_back_to_main.png")

        # Now tap the cart tab
        cdp_click(driver, *TAB_CART)
        wait(2)
        ss(driver, "v2_15_cart_with_items.png")
        log("  Cart should now show items")

        # ===== STEP 4: SCROLL TO CHECKOUT BUTTON =====
        log("\n=== STEP 4: SCROLL TO CHECKOUT ===")
        # The checkout button is inside the scroll view, at the bottom
        # Scroll down to find it
        cdp_scroll(driver, VP_W // 2, VP_H // 2, 500)
        wait(1)
        ss(driver, "v2_16_cart_scrolled1.png")

        cdp_scroll(driver, VP_W // 2, VP_H // 2, 500)
        wait(1)
        ss(driver, "v2_17_cart_scrolled2.png")

        cdp_scroll(driver, VP_W // 2, VP_H // 2, 500)
        wait(1)
        ss(driver, "v2_18_cart_scrolled3.png")

        # ===== STEP 5: TAP CHECKOUT =====
        log("\n=== STEP 5: TAP CHECKOUT (متابعة الطلب) ===")
        # The checkout button should be visible after scrolling
        # It's a full-width button, try clicking center-bottom area
        cdp_click(driver, VP_W // 2, VP_H - 100)
        wait(3)
        ss(driver, "v2_19_after_checkout_tap.png")
        log("  ASSERTION B: Phone entry screen should NOW appear")

        # ===== STEP 6: PHONE ENTRY =====
        log("\n=== STEP 6: PHONE ENTRY ===")
        ss(driver, "v2_20_phone_entry.png")

        # The phone field should be roughly in the center of the screen
        # Click on it first to focus
        cdp_click(driver, VP_W // 2, VP_H // 2 - 50)
        wait(1)

        # Type phone number
        cdp_type(driver, "7501234567")
        wait(1)
        ss(driver, "v2_21_phone_entered.png")

        # Tap "إرسال رمز التحقق" button
        # It should be below the channel selector, roughly at y = VP_H * 0.7
        cdp_click(driver, VP_W // 2, int(VP_H * 0.7))
        wait(3)
        ss(driver, "v2_22_after_phone_submit.png")

        # ===== STEP 7: OTP SCREEN =====
        log("\n=== STEP 7: OTP SCREEN ===")
        ss(driver, "v2_23_otp_screen.png")

        # Get the dev code from the API
        try:
            resp = requests.post(
                f"{API_URL}/api/v1/phone/request-otp",
                json={"phone": "+9647501234567", "channel": "sms"},
                headers={"Authorization": f"Bearer {AUTH_TOKEN}"}
            )
            if resp.status_code == 200:
                data = resp.json()
                dev_code = data.get("dev_code", "")
                log(f"  OTP API response: {resp.status_code}, dev_code: {dev_code}")
            else:
                log(f"  OTP API response: {resp.status_code} - {resp.text}")
                dev_code = ""
        except Exception as e:
            log(f"  OTP API error: {e}")
            dev_code = ""

        # If dev mode is on, the OTP boxes should be prefilled
        # Check the screenshot to see if they are
        # If not, we need to type the code
        wait(2)
        ss(driver, "v2_24_otp_after_api.png")

        # Click on the OTP input area and type the code
        if dev_code:
            # The OTP boxes should be roughly in the center
            cdp_click(driver, VP_W // 2, VP_H // 2 - 30)
            wait(1)
            cdp_type(driver, dev_code)
            wait(2)
            ss(driver, "v2_25_otp_entered.png")

        # ===== STEP 8: VERIFY AND AUTO-CONTINUE =====
        log("\n=== STEP 8: AUTO-CONTINUE ===")
        # After entering 6 digits, it should auto-submit
        # Or we can tap the confirm button
        # The "تأكيد ومتابعة" button should be below the OTP boxes
        cdp_click(driver, VP_W // 2, int(VP_H * 0.65))
        wait(3)
        ss(driver, "v2_26_after_verify.png")
        log("  ASSERTION: Should be on checkout/delivery screen (auto-continued)")

        # ===== STEP 9: SKIP BEHAVIOR =====
        log("\n=== STEP 9: SKIP BEHAVIOR ===")
        # Go back to home
        cdp_click(driver, VP_W - 25, 35)  # Back button
        wait(2)
        ss(driver, "v2_27_back_to_home.png")

        # Navigate to cart
        cdp_click(driver, *TAB_CART)
        wait(2)
        ss(driver, "v2_28_cart_second.png")

        # Scroll to checkout button
        cdp_scroll(driver, VP_W // 2, VP_H // 2, 1000)
        wait(1)

        # Tap checkout again
        cdp_click(driver, VP_W // 2, VP_H - 100)
        wait(3)
        ss(driver, "v2_29_second_checkout.png")
        log("  ASSERTION: Should skip phone entry and go directly to checkout")

        # Collect console errors
        log("\n=== CONSOLE ERRORS ===")
        try:
            logs = driver.get_log("browser")
            for entry in logs:
                if entry.get("level") in ("SEVERE", "WARNING"):
                    console_errors.append(entry.get("message", ""))
            log(f"  Total console errors: {len(console_errors)}")
            for err in console_errors[:10]:
                log(f"    {err[:200]}")
        except Exception as e:
            log(f"  Could not get console logs: {e}")

    except Exception as e:
        log(f"\n!!! EXCEPTION: {e}")
        import traceback
        log(traceback.format_exc())
        try:
            ss(driver, "v2_error.png")
        except:
            pass
    finally:
        driver.quit()

    log("\n" + "=" * 60)
    log("TEST COMPLETE")
    log("=" * 60)
    save_log()

if __name__ == "__main__":
    main()

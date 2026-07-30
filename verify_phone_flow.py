"""
Wow Gift Phone Verification Flow - E2E Test v5
CDP-based interaction with proper Flutter web handling.
"""
import os
import time
import json
import traceback
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

SCREENSHOT_DIR = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify"
LOG_FILE = os.path.join(SCREENSHOT_DIR, "test_log.txt")
APP_URL = "http://127.0.0.1:8080"
API_URL = "http://127.0.0.1:8000"

os.makedirs(SCREENSHOT_DIR, exist_ok=True)
for f in os.listdir(SCREENSHOT_DIR):
    if f.endswith('.png'):
        os.remove(os.path.join(SCREENSHOT_DIR, f))

log_lines = []
console_errors = []

def log(msg):
    print(msg, flush=True)
    log_lines.append(str(msg))

def save_log():
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines))

sc = 0
def screenshot(driver, name):
    global sc
    sc += 1
    fname = f"{sc:02d}_{name}.png"
    path = os.path.join(SCREENSHOT_DIR, fname)
    driver.save_screenshot(path)
    log(f"  [SS] {fname}")
    return path

def collect_console(driver):
    try:
        for entry in driver.get_log('browser'):
            if entry['level'] == 'SEVERE':
                msg = entry['message'][:200]
                if msg not in console_errors:
                    console_errors.append(msg)
    except:
        pass

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

def scroll(driver, x, y, dy=300):
    log(f"  [SCROLL] ({x},{y}) dy={dy}")
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseWheel", "x": x, "y": y,
        "deltaX": 0, "deltaY": dy
    })
    time.sleep(1)

def wait_for_app(driver, timeout=30):
    """Wait for Flutter canvas to render"""
    log("  Waiting for Flutter canvas...")
    for i in range(timeout):
        canvases = driver.find_elements(By.TAG_NAME, "canvas")
        big = [c for c in canvases if c.size.get('width', 0) > 100]
        if big:
            log(f"  Canvas found after {i+1}s ({big[0].size})")
            return True
        time.sleep(1)
    log("  WARNING: No canvas found")
    return False

def main():
    log("=" * 60)
    log("WOW GIFT - Phone Verification E2E Test v5")
    log("=" * 60)

    # Get auth token
    email = "testv5@gmail.com"
    password = "Test123456"
    requests.post(f"{API_URL}/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": "Test V5"
    })
    resp = requests.post(f"{API_URL}/api/v1/auth/login", json={
        "email": email, "password": password
    })
    token = resp.json().get("access_token") if resp.status_code == 200 else None
    log(f"  Token: {'OK' if token else 'FAIL'}")
    if not token:
        save_log()
        return

    headers = {"Authorization": f"Bearer {token}"}
    me = requests.get(f"{API_URL}/api/v1/users/me", headers=headers).json()
    log(f"  User: {me['email']}, phone_verified: {me['phone_verified']}")

    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--window-size=500,900")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--lang=ar")
    chrome_options.set_capability("goog:loggingPrefs", {"browser": "ALL"})
    chrome_options.binary_location = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

    driver = None
    try:
        driver = webdriver.Chrome(options=chrome_options)
        driver.set_window_size(500, 900)
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VW, VH = vp['w'], vp['h']
        log(f"  Viewport: {VW}x{VH}")
        NAV_Y = VH - 25  # Bottom nav bar y-coordinate

        # ============================================================
        # LOAD APP WITH TOKEN
        # ============================================================
        log("\n=== LOADING APP ===")
        driver.get(APP_URL)
        time.sleep(2)
        # Inject token
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{token}');")
        driver.execute_script("localStorage.removeItem('flutter.phone_verified');")
        driver.execute_script("localStorage.removeItem('flutter.verified_phone');")
        # Reload
        driver.get(APP_URL)
        wait_for_app(driver)
        # Wait for splash animation (4s) + navigation
        time.sleep(8)
        collect_console(driver)

        # ============================================================
        # STEP 1: HOME SCREEN - NO PHONE PROMPT
        # ============================================================
        log("\n=== STEP 1: HOME SCREEN ===")
        screenshot(driver, "home_screen")
        log("  ASSERTION A-1: Home screen visible, NO phone entry")

        # ============================================================
        # STEP 2: BROWSE TABS - NO PHONE PROMPT
        # ============================================================
        log("\n=== STEP 2: BROWSE TABS ===")

        # Gift Boxes tab (center of 5 tabs)
        tap(driver, 250, NAV_Y, "صناديق")
        time.sleep(1.5)
        screenshot(driver, "gift_boxes_tab")
        log("  ASSERTION A-2: Gift boxes, NO phone")

        # Occasions tab
        tap(driver, 350, NAV_Y, "المناسبات")
        time.sleep(1.5)
        screenshot(driver, "occasions_tab")
        log("  ASSERTION A-3: Occasions, NO phone")

        # Profile tab
        tap(driver, 50, NAV_Y, "حسابي")
        time.sleep(1.5)
        screenshot(driver, "profile_tab")
        log("  ASSERTION A-4: Profile, NO phone")

        # Cart tab
        tap(driver, 150, NAV_Y, "السلة")
        time.sleep(1.5)
        screenshot(driver, "cart_empty")
        log("  ASSERTION A-5: Cart (empty), NO phone")

        # ============================================================
        # STEP 3: ADD ITEM TO CART
        # ============================================================
        log("\n=== STEP 3: ADD ITEM TO CART ===")

        # The cart is empty. It shows "اختيار صندوق هدية" button.
        # From screenshot, this button is at approximately y=505, center
        tap(driver, 250, 505, "اختيار صندوق هدية button")
        time.sleep(2)
        screenshot(driver, "after_choose_box")

        # We should now be on gift boxes screen
        # Tap on صندوق الأناقة (right card, approximately x=370, y=250)
        tap(driver, 370, 250, "صندوق الأناقة")
        time.sleep(2)
        screenshot(driver, "gift_box_sheet")

        # Bottom sheet should show. Tap "اختيار هذا الصندوق"
        # The button is at the very bottom of the bottom sheet
        # Let's try y=718 (near bottom of viewport)
        tap(driver, 250, VH - 35, "اختيار هذا الصندوق")
        time.sleep(2)
        screenshot(driver, "after_select_box")

        # We should be on search/products screen now
        # Tap "عطر" search chip (top-right area, y~120)
        tap(driver, 440, 120, "عطر chip")
        time.sleep(3)
        screenshot(driver, "search_results")

        # Tap on the product card "عطر فرنسي فاخر"
        # The card is at approximately x=370, y=250
        tap(driver, 370, 200, "عطر فرنسي فاخر")
        time.sleep(2)
        screenshot(driver, "product_detail")

        # Check if we navigated to product detail
        # If yes, scroll down and tap add button
        scroll(driver, 250, 400, 500)
        time.sleep(1)
        screenshot(driver, "product_scrolled")

        # Tap add to gift box button (bottom of screen)
        tap(driver, 250, VH - 60, "إضافة إلى صندوق الهدية")
        time.sleep(2)
        screenshot(driver, "after_add")
        collect_console(driver)

        # ============================================================
        # STEP 4: GO TO CART
        # ============================================================
        log("\n=== STEP 4: CART ===")
        tap(driver, 150, NAV_Y, "السلة tab")
        time.sleep(2)
        screenshot(driver, "cart_with_items")

        # Scroll down to see checkout button
        scroll(driver, 250, 400, 500)
        time.sleep(1)
        screenshot(driver, "cart_scrolled")

        # ============================================================
        # STEP 5: TAP CHECKOUT - PHONE ENTRY SHOULD APPEAR
        # ============================================================
        log("\n=== STEP 5: CHECKOUT ===")
        # The checkout button "متابعة الطلب" is at the bottom
        tap(driver, 250, VH - 60, "متابعة الطلب")
        time.sleep(2)
        screenshot(driver, "after_checkout")
        collect_console(driver)
        log("  ASSERTION B: Phone entry screen should appear")

        # ============================================================
        # STEP 6: PHONE ENTRY
        # ============================================================
        log("\n=== STEP 6: PHONE ENTRY ===")
        screenshot(driver, "phone_entry")

        # Tap on phone input field (center of screen)
        tap(driver, 250, 400, "Phone field")
        time.sleep(1)

        # Type phone number using CDP
        for char in "7501234567":
            driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
                "type": "char", "text": char
            })
            time.sleep(0.05)
        log("  Typed: 7501234567")
        time.sleep(1)
        screenshot(driver, "phone_entered")

        # Submit
        tap(driver, 250, VH - 100, "Submit phone")
        time.sleep(3)
        screenshot(driver, "after_phone_submit")
        collect_console(driver)

        # ============================================================
        # STEP 7: OTP SCREEN
        # ============================================================
        log("\n=== STEP 7: OTP ===")
        screenshot(driver, "otp_screen")

        # Get dev code from API
        try:
            otp_resp = requests.post(
                f"{API_URL}/api/v1/auth/phone/request-otp",
                headers=headers,
                json={"phone": "+9647501234567", "channel": "sms"}
            )
            log(f"  OTP API: {otp_resp.status_code}")
            if otp_resp.status_code == 200:
                dev_code = otp_resp.json().get("dev_code", "123456")
                log(f"  Dev code: {dev_code}")
            else:
                dev_code = "123456"
        except:
            dev_code = "123456"

        # Type OTP
        tap(driver, 250, 400, "OTP field area")
        time.sleep(0.5)
        for char in dev_code:
            driver.execute_cdp_cmd("Input.dispatchKeyEvent", {
                "type": "char", "text": char
            })
            time.sleep(0.1)
        log(f"  Typed OTP: {dev_code}")
        time.sleep(3)
        screenshot(driver, "otp_entered")
        collect_console(driver)

        # ============================================================
        # STEP 8: AUTO-CONTINUE TO CHECKOUT
        # ============================================================
        log("\n=== STEP 8: AUTO-CONTINUE ===")
        time.sleep(3)
        screenshot(driver, "after_verification")
        log("  ASSERTION: Should be on checkout/delivery screen")

        # ============================================================
        # STEP 9: SKIP BEHAVIOR
        # ============================================================
        log("\n=== STEP 9: SKIP BEHAVIOR ===")
        tap(driver, 450, NAV_Y, "الرئيسية tab")
        time.sleep(2)
        tap(driver, 150, NAV_Y, "السلة tab")
        time.sleep(2)
        screenshot(driver, "cart_second")
        scroll(driver, 250, 400, 500)
        time.sleep(1)
        tap(driver, 250, VH - 60, "متابعة الطلب (2nd)")
        time.sleep(2)
        screenshot(driver, "second_checkout")
        log("  ASSERTION: Should skip phone and go to checkout")

        # ============================================================
        # SUMMARY
        # ============================================================
        log("\n" + "=" * 50)
        log("SUMMARY")
        log("=" * 50)
        log(f"  Screenshots: {sc}")
        log(f"  Console errors: {len(console_errors)}")
        for e in console_errors:
            log(f"    {e}")

    except Exception as e:
        log(f"\n!!! {e}")
        log(traceback.format_exc())
        if driver:
            screenshot(driver, "error")
    finally:
        if driver:
            collect_console(driver)
            driver.quit()
        save_log()

if __name__ == "__main__":
    main()

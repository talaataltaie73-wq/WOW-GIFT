"""
Wow Gift - Final verification test v9
Tests:
1. Checkout with unverified phone → phone entry appears (already proven in v7)
2. Checkout with verified phone → phone entry SKIPPED
3. Correct checkout button Y coordinate (625, not 709)
"""
import time
import json
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

SCREENSHOT_DIR = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify"
BASE_URL = "http://127.0.0.1:8080"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MjhjMDlkMS1kNTFhLTQ4NDMtYTdjNC1mOTkxMDQ4NDgwZTUiLCJyb2xlIjoiY3VzdG9tZXIiLCJleHAiOjE3ODU0MzcyODF9.hP2hkWFLSI6oHgJwAFjBYJIMmU02XCDVCUIWsE3Juwk"

os.makedirs(SCREENSHOT_DIR, exist_ok=True)
log_lines = []
ss_count = 0

def log(msg):
    print(msg, flush=True)
    log_lines.append(str(msg))

def save_log():
    with open(os.path.join(SCREENSHOT_DIR, "test_log_v9.txt"), "w", encoding="utf-8") as f:
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

def wait_for_flutter(driver, max_wait=40):
    for i in range(max_wait):
        canvases = driver.find_elements(By.TAG_NAME, "canvas")
        if any(c.size.get('width', 0) > 100 for c in canvases):
            log(f"  Canvas found at {i+1}s")
            return True
        time.sleep(1)
    log("  Canvas NOT found after timeout")
    return False

def add_item_to_cart(driver, VP_W, VP_H, BN_Y):
    """Full flow: cart → choose box → search → add product → back to cart"""
    log("\n--- ADD ITEM TO CART ---")
    
    # Go to cart
    tap(driver, 150, BN_Y, "السلة tab")
    time.sleep(1.5)
    
    # Choose box
    tap(driver, VP_W // 2, 490, "اختيار صندوق هدية")
    time.sleep(2)
    
    # Select box (صندوق الأناقة)
    tap(driver, 370, 250, "صندوق الأناقة")
    time.sleep(2)
    
    # Confirm box
    tap(driver, VP_W // 2, VP_H - 50, "اختيار هذا الصندوق")
    time.sleep(2)
    
    # Search for product
    tap(driver, 440, 120, "عطر chip")
    time.sleep(2)
    
    # Open product
    tap(driver, 370, 250, "first product")
    time.sleep(2)
    
    # Add to cart
    tap(driver, VP_W // 2, VP_H - 80, "إضافة إلى صندوق الهدية")
    time.sleep(2)
    
    # Navigate back: product → search → boxes → cart
    tap(driver, VP_W - 25, 40, "back")
    time.sleep(1)
    tap(driver, VP_W - 25, 40, "back")
    time.sleep(1)
    tap(driver, VP_W - 25, 40, "back")
    time.sleep(1.5)
    
    log("--- ITEM ADDED ---")

def scroll_to_checkout(driver, VP_W, VP_H):
    """Scroll cart to reveal checkout button"""
    for i in range(6):
        scroll_down(driver, VP_W // 2, VP_H // 2, 400)
    time.sleep(1)

def main():
    log("=" * 60)
    log("WOW GIFT - Final Verification Test v9")
    log("=" * 60)

    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--window-size=500,900")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.set_capability("goog:loggingPrefs", {"browser": "ALL"})

    # ===== TEST 1: UNVERIFIED → PHONE ENTRY =====
    log("\n" + "=" * 40)
    log("TEST 1: UNVERIFIED USER → CHECKOUT")
    log("=" * 40)
    
    driver = webdriver.Chrome(options=opts)
    driver.set_window_size(500, 900)
    
    try:
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VP_W, VP_H = vp['w'], vp['h']
        BN_Y = VP_H - 25
        log(f"  Viewport: {VP_W}x{VP_H}, BN_Y: {BN_Y}")

        # Load with unverified phone
        driver.get(BASE_URL)
        time.sleep(2)
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');")
        driver.execute_script("localStorage.removeItem('flutter.phone_verified');")
        driver.execute_script("localStorage.removeItem('flutter.verified_phone');")
        driver.get(BASE_URL)
        
        wait_for_flutter(driver)
        time.sleep(8)
        ss(driver, "v9_01_home.png")

        # Add item to cart
        add_item_to_cart(driver, VP_W, VP_H, BN_Y)
        ss(driver, "v9_02_cart_items.png")

        # Scroll to checkout
        scroll_to_checkout(driver, VP_W, VP_H)
        ss(driver, "v9_03_scrolled.png")

        # Tap checkout button - the green button is at ~y=625 based on v7_15/v8_09
        tap(driver, VP_W // 2, 625, "متابعة الطلب")
        time.sleep(2)
        ss(driver, "v9_04_after_checkout.png")
        log("  EXPECTED: Phone entry screen")

        # If we didn't get phone entry, try different Y
        tap(driver, VP_W // 2, 640, "متابعة الطلب attempt 2")
        time.sleep(2)
        ss(driver, "v9_05_checkout2.png")

    except Exception as e:
        log(f"  ERROR: {e}")
        import traceback
        log(traceback.format_exc())
        try: ss(driver, "v9_error1.png")
        except: pass
    finally:
        driver.quit()

    # ===== TEST 2: VERIFIED → SKIP PHONE =====
    log("\n" + "=" * 40)
    log("TEST 2: VERIFIED USER → CHECKOUT (SKIP)")
    log("=" * 40)
    
    driver = webdriver.Chrome(options=opts)
    driver.set_window_size(500, 900)
    
    try:
        vp = driver.execute_script("return {w: window.innerWidth, h: window.innerHeight}")
        VP_W, VP_H = vp['w'], vp['h']
        BN_Y = VP_H - 25

        # Load with VERIFIED phone
        driver.get(BASE_URL)
        time.sleep(2)
        driver.execute_script(f"localStorage.setItem('flutter.auth_token', '{AUTH_TOKEN}');")
        driver.execute_script("localStorage.setItem('flutter.phone_verified', 'true');")
        driver.execute_script("localStorage.setItem('flutter.verified_phone', '+9647501234567');")
        driver.get(BASE_URL)
        
        wait_for_flutter(driver)
        time.sleep(8)
        ss(driver, "v9_06_home_verified.png")

        # Add item to cart
        add_item_to_cart(driver, VP_W, VP_H, BN_Y)
        ss(driver, "v9_07_cart_items.png")

        # Scroll to checkout
        scroll_to_checkout(driver, VP_W, VP_H)
        ss(driver, "v9_08_scrolled.png")

        # Tap checkout
        tap(driver, VP_W // 2, 625, "متابعة الطلب (verified)")
        time.sleep(2)
        ss(driver, "v9_09_skip_result.png")
        log("  EXPECTED: Checkout/delivery screen (NOT phone entry)")

        # Try different Y if needed
        tap(driver, VP_W // 2, 640, "متابعة الطلب attempt 2")
        time.sleep(2)
        ss(driver, "v9_10_skip2.png")

    except Exception as e:
        log(f"  ERROR: {e}")
        import traceback
        log(traceback.format_exc())
        try: ss(driver, "v9_error2.png")
        except: pass
    finally:
        driver.quit()

    # Console
    log(f"\nScreenshots: {ss_count}")
    save_log()

if __name__ == "__main__":
    main()

"""Take a screenshot of the Wow Gift home screen and capture console logs."""
import time
import json
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

options = Options()
options.add_argument("--headless=new")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--window-size=430,932")
options.set_capability("goog:loggingPrefs", {"browser": "ALL"})

driver = webdriver.Chrome(options=options)
try:
    driver.get("http://127.0.0.1:8080/")
    # Wait for Flutter to load
    time.sleep(15)
    
    # Take screenshot
    screenshot_path = r"C:\Users\HP\Projects\wow-gift\verdent-design\stage2\screenshots\verify\final_home.png"
    driver.save_screenshot(screenshot_path)
    print(f"Screenshot saved to: {screenshot_path}")
    
    # Get console logs
    logs = driver.get_log("browser")
    print("\n=== BROWSER CONSOLE LOGS ===")
    for entry in logs:
        print(f"[{entry['level']}] {entry['message']}")
    
    if not logs:
        print("(no console logs)")
    
    # Check for 404s specifically
    print("\n=== 404 CHECK ===")
    has_404 = False
    for entry in logs:
        if "404" in entry["message"] and "picsum" not in entry["message"]:
            has_404 = True
            print(f"FOUND 404: {entry['message']}")
    if not has_404:
        print("No 404 errors found (excluding picsum.photos)")
        
finally:
    driver.quit()

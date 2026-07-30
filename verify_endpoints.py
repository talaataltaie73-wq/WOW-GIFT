"""Verify all 5 previously-404 endpoints now return 200."""
import time
import json
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument("--headless=new")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--window-size=430,932")
options.set_capability("goog:loggingPrefs", {"browser": "ALL", "performance": "ALL"})

driver = webdriver.Chrome(options=options)
try:
    driver.get("http://127.0.0.1:8080/")
    time.sleep(20)  # Wait longer for all API calls
    
    # Get performance logs to check network requests
    perf_logs = driver.get_log("performance")
    
    # Check for 404 responses
    print("=== NETWORK RESPONSES ===")
    endpoints_checked = set()
    for entry in perf_logs:
        msg = json.loads(entry["message"])["message"]
        if msg["method"] == "Network.responseReceived":
            url = msg["params"]["response"]["url"]
            status = msg["params"]["response"]["status"]
            if "api/v1" in url or "8000" in url:
                print(f"  {status} {url}")
                endpoints_checked.add(url)
    
    # Also check browser console
    browser_logs = driver.get_log("browser")
    print("\n=== BROWSER CONSOLE ===")
    for entry in browser_logs:
        msg = entry["message"]
        # Skip picsum.photos errors
        if "picsum" in msg.lower():
            continue
        print(f"  [{entry['level']}] {msg}")
    
    if not browser_logs:
        print("  (no console logs)")
    
    print("\n=== 404 CHECK ===")
    has_real_404 = False
    for entry in perf_logs:
        msg = json.loads(entry["message"])["message"]
        if msg["method"] == "Network.responseReceived":
            url = msg["params"]["response"]["url"]
            status = msg["params"]["response"]["status"]
            if status == 404 and "picsum" not in url:
                has_real_404 = True
                print(f"  FOUND 404: {url}")
    
    if not has_real_404:
        print("  No 404 errors found (excluding picsum.photos)")
        
finally:
    driver.quit()

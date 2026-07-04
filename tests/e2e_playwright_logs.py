from playwright.sync_api import sync_playwright
import json
import time

BASE = "http://127.0.0.1:8000"
OUT = "tests/playwright_capture.json"


def capture_flow():
    data = {"console": [], "requests": [], "responses": [], "events": []}
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        page.on("console", lambda msg: data["console"].append({
            "type": msg.type,
            "text": msg.text,
            "location": msg.location,
        }))

        page.on("request", lambda req: data["requests"].append({
            "url": req.url,
            "method": req.method,
            "resourceType": req.resource_type,
            "timestamp": time.time(),
        }))

        page.on("response", lambda res: data["responses"].append({
            "url": res.url,
            "status": res.status,
            "ok": res.ok,
            "timestamp": time.time(),
        }))

        def note(evt):
            data["events"].append({"note": evt, "time": time.time()})

        # User login flow
        note('navigate: login')
        page.goto(f"{BASE}/login.html")
        page.wait_for_selector('#login-form', timeout=5000)
        page.fill('#email', 'user@example.com')
        page.fill('#password', 'userpass123')
        note('submit: user login')
        page.click('form#login-form button[type=submit]')
        page.wait_for_url('**/user-dashboard.html', timeout=5000)
        note('landed: user-dashboard')

        # Access control attempt
        note('navigate: admin-dashboard as user')
        page.goto(f"{BASE}/admin-dashboard.html")
        page.wait_for_url('**/user-dashboard.html', timeout=5000)
        note('redirected-back-to-user')

        # Sign out
        note('click sign-out')
        page.click('#sign-out-button')
        page.wait_for_url('**/login.html', timeout=5000)
        note('signed-out')

        # Admin login flow
        note('navigate: login for admin')
        page.goto(f"{BASE}/login.html")
        page.fill('#email', 'admin@example.com')
        page.fill('#password', 'adminpass123')
        note('submit: admin login')
        page.click('form#login-form button[type=submit]')
        page.wait_for_url('**/admin-dashboard.html', timeout=5000)
        note('landed: admin-dashboard')

        # Access user dashboard as admin
        note('navigate: user-dashboard as admin')
        page.goto(f"{BASE}/user-dashboard.html")
        page.wait_for_url('**/admin-dashboard.html', timeout=5000)
        note('redirected-back-to-admin')

        browser.close()

    with open(OUT, 'w') as f:
        json.dump(data, f, indent=2)

    print('Capture written to', OUT)
    print('console messages:', len(data['console']))
    print('requests:', len(data['requests']))
    print('responses:', len(data['responses']))


if __name__ == '__main__':
    capture_flow()

from playwright.sync_api import sync_playwright

BASE = "http://127.0.0.1:8000"


def test_login_and_access():
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        # Login as user
        page.goto(f"{BASE}/login.html")
        page.fill('#email', 'user@example.com')
        page.fill('#password', 'userpass123')
        page.click('form#login-form button[type=submit]')
        page.wait_for_url('**/user-dashboard.html', timeout=5000)
        print('USER_LOGIN_OK')

        # Try access admin page - should redirect back to user dashboard
        page.goto(f"{BASE}/admin-dashboard.html")
        page.wait_for_url('**/user-dashboard.html', timeout=5000)
        print('USER_ACCESS_CONTROL_OK')

        # Sign out
        try:
            page.click('#sign-out-button')
            page.wait_for_url('**/login.html', timeout=5000)
            print('USER_SIGNOUT_OK')
        except Exception:
            print('USER_SIGNOUT_FAILED')

        # Login as admin
        page.goto(f"{BASE}/login.html")
        page.fill('#email', 'admin@example.com')
        page.fill('#password', 'adminpass123')
        page.click('form#login-form button[type=submit]')
        page.wait_for_url('**/admin-dashboard.html', timeout=5000)
        print('ADMIN_LOGIN_OK')

        # Try access user dashboard - should redirect back to admin dashboard
        page.goto(f"{BASE}/user-dashboard.html")
        page.wait_for_url('**/admin-dashboard.html', timeout=5000)
        print('ADMIN_ACCESS_CONTROL_OK')

        # Sign out
        try:
            page.click('#sign-out-button')
            page.wait_for_url('**/login.html', timeout=5000)
            print('ADMIN_SIGNOUT_OK')
        except Exception:
            print('ADMIN_SIGNOUT_FAILED')

        browser.close()


if __name__ == '__main__':
    test_login_and_access()

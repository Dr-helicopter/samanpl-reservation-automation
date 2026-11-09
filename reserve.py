from urllib.parse import urljoin
from playwright.sync_api import sync_playwright
from password import *


def select_seat(popup):
	popup.wait_for_load_state()
	button = popup.get_by_text(seat)
	print(button.get_attribute("id"), button.count())
	button.click()
	popup.locator("#btnReserve").click()
	print(popup.url)


if __name__ == "__main__":
	with sync_playwright() as p:
		browser = p.chromium.launch(headless=False)   # headless=True hides the window
		page = browser.new_page()

		page.goto("https://107112.samanpl.ir/")

		# press the thing
		itm = page.locator(".mdi.mdi-login").first
		try:
			itm.wait_for(state="visible")
		except:
			print("login issue")
			exit(5)
		itm.click()

		# fill out fourm
		page.locator("#UName").fill(uname)
		page.locator("#Passwordfield").fill(pword)

		rme = page.locator("#RememberMe")
		if rme.is_checked():
			page.locator('label[for="RememberMe"]').click()
		# login
		page.locator("#loginButton").click()

		# get to the reserve
		page.locator("#ReserveButton").click()

		# switch page
		link = page.locator('a.btn.btn-info[href*="/Home/ReserveService"]')
		link.wait_for(state="attached", timeout=10000)
		href = link.get_attribute("href")
		print(href)
		page.goto(urljoin(page.url, href))

		page.locator("#StartDate1").click()

		# click tomorrow
		cells = page.locator('td[data-day][data-number]:not([disabled])')
		print(cells.count)
		cells.nth(1).click()

		# get the days buttons
		buttons = page.locator("#HourSelect button")
		buttons.first.wait_for()

		with page.expect_popup() as popup:
			for i in [2, 3, 4]:
				buttons.nth(i).click()
				select_seat(popup.value)

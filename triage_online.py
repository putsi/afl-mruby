#!/usr/bin/python
from bs4 import BeautifulSoup
import urllib
import requests
import sys

if len(sys.argv) < 2:
    print "Give testcase path as command line param!"
    sys.exit(1)
testcase = sys.argv[1]

url = "https://www.mruby.science:443/runs"
headers = {"Content-Type": "application/x-www-form-urlencoded", "Connection": "close"}
response = requests.get(url, headers=headers)
cookies = response.cookies
token = BeautifulSoup(response.text, "html.parser").find("input", {"name":"authenticity_token"}).get('value')

print "Running testcase: {}".format(testcase)
with open(testcase, 'r') as tc:
    source = tc.read().replace('\n', '')
    data = {"utf8": "\x2713", "authenticity_token": token, "run[source]": source, "commit": "Run"}
    response = requests.post(url, headers=headers, data=data, cookies=cookies)
    soup = BeautifulSoup(response.text, "html.parser")
    try:
        result = soup.find_all('code')[0]
        print "Result: " + result.get_text().replace('\n', '').encode('utf-8').strip()
    except IndexError:
        print "NO RESULT, positive crash?"
    quotas = soup.find_all('dd')
    try:
        print "Memory: " + quotas[0].get_text()
    except IndexError:
        print "NO MEMORY, positive crash?"
    try:
        print "Instructions: " + quotas[1].get_text()
    except IndexError:
        print "NO INSTRUCTIONS, positive crash?"
print "\n"


import requests
url = 'http://127.0.0.1:3500/eth/v1/config/spec'
response = requests.get(url)
response_json = response.json()
data = response_json["data"]

for item in data:
    print(item + ": " + data[item])
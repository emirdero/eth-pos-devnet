import requests

for i in range(1, 100):
    url = 'http://127.0.0.1:3500/eth/v2/beacon/blocks/' + str(i)

    response = requests.get(url)

    # Print the response
    response_json = response.json()
    print(response_json)

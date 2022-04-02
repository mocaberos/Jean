# WAF(nginx+naxsi)

Listen on port 1191 and forward to the URL set in the PROXY_PASS environment variable.

Malicious requests are blocked by Naxsi.

# Usage
Placed in front of the application to forward client requests

# Run on local
```shell
$ docker-compose up
```
### Normal request
http://127.0.0.1:1191

### Malicious requests (This requests will blocked by Naxsi)
http://127.0.0.1:1191?id=1'+or+1=1/*

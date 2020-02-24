# check_curl
Monitor a HTTP/HTTPS endpoint using CURL.

## Setup
You need to have curl installed, on systems using apt, use:
```
apt install curl
```

## Usage
```
Usage: check_curl [OPTIONS]
  [OPTIONS]:
  -P PROXY          Set Proxy Address (default: No Proxy)
  -M METHOD         HTTP Method (default: POST)
  -N NAME           Display Name of scanned object (default: default)
  -B BODY           Request Body to be send as with --data-urlencode (default: not sent)
  -I INSECURE       Sets the curl flag --insecure
  -C CONTAINS       If not contained in response body, CRITICAL will be returned
  -w WARNING        Warning threshold in milliseconds (default: 700)
  -c CRITICAL       Critical threshold in milliseconds (default: 2000)
  -H HEADER         Send Header (i.E. "AUTHORIZATION: Bearer 8*.UdUYwrl!nK")
  -F FOLLOW         Follow redirects (default: OFF)
  -U URL            Target URL
```

## Command Template
```
object CheckCommand "check-curl" {
  command = [ ConfigDir + "/scripts/check_curl.sh" ]
  arguments += {
    "-U" = "$host.name$"
    "-M" = "GET"
    "-C" = "$cah_bodycontains$"
  }
}
```

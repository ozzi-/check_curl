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
  -U URL            Target URL
  -M METHOD         HTTP Method (default: POST)
  -N NAME           Display Name of scanned object (default: default)
  -B BODY           Request Body to be sent (default: not sent)
  -E ENCODEURL      Send body defined with url encoding (curl --data-urlencode) (default: off)
  -I INSECURE       Sets the curl flag --insecure
  -C CONTAINS       If not contained in response body, CRITICAL will be returned
  -L LACKS          If contained in response body, CRITICAL will be returned (-C has priority when both are set)
  -w WARNING        Warning threshold in milliseconds (default: 700)
  -c CRITICAL       Critical threshold in milliseconds (default: 2000)
  -H HEADER         Send Header (i.E. "AUTHORIZATION: Bearer 8*.UdUYwrl!nK")
  -F FOLLOW         Follow redirects (default: OFF)
  -D DEBUG          Only prints the curl command (default: OFF)
  -P PROXY          Set Proxy Address (default: No Proxy)
  -K COOKIES        Enables/Disabled cookie handling in a temporary cookie jar
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

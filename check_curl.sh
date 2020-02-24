#!/bin/bash
# startup checks

if [ -z "$BASH" ]; then
  echo "Please use BASH."
  exit 3
fi
if [ ! -e "/usr/bin/which" ]; then
  echo "/usr/bin/which is missing."
  exit 3
fi
curl=$(which curl)
if [ $? -ne 0 ]; then
  echo "Please install curl."
  exit 3
fi

# Default Values
proxy=""
method="POST"
body=""
contains=""
warning=700
critical=2000
url=""
follow=1
header=""
name="default"
loadcookiepath=""

# Usage Info
usage() {
  echo '''Usage: check_curl [OPTIONS]
  [OPTIONS]:
  -P PROXY          Set Proxy Address (default: No Proxy)
  -M METHOD         HTTP Method (default: POST)
  -N NAME           Display Name of scanned object (default: default)
  -B BODY           Request Body to be send as with --data-urlencode (default: not sent)
  -I INSECURE       Sets the curl flag --insecure
  -C CONTAINS       If not contained in response body, CRITICAL will be returned
  -O obSSO          Loads the obSSO cookie from specified path (default: off)
  -w WARNING        Warning threshold in milliseconds (default: 700)
  -c CRITICAL       Critical threshold in milliseconds (default: 2000)
  -H HEADER         Send Header (i.E. "AUTHORIZATION: Bearer 8*.UdUYwrl!nK")
  -F FOLLOW         Follow redirects (default: OFF)
  -U URL            Target URL'''
}


# Check which threshold was reached
checkTime() {
  if [ $1 -gt $critical ]; then
    echo -n "CRITICAL: Slow "
  elif [ $1 -gt $warning ]; then
    echo -n "WARNING: Slow "
  else
    echo -n "OK"
  fi
}

# Return code value
getStatus() {
  if [ $1 -gt $critical ]; then
    return 2
  elif [ $1 -gt $warning ]; then
    return 1
  else
    return 0
  fi
}

#main
#get options
while getopts "P:M:B:C:w:c:U:H:F:N:O:" opt; do
  case $opt in
    P)
      proxy=$OPTARG
      ;;
    M)
      method=$OPTARG
      ;;
    B)
      body=$OPTARG
      ;;
    C)
      contains=$OPTARG
      ;;
    w)
      warning=$OPTARG
      ;;
    c)
      critical=$OPTARG
      ;;
    U)
      url=$OPTARG
      ;;
    I)
      insecure=1
      ;;
    N)
      name=$( echo $OPTARG | sed -e 's/[^A-Za-z0-9._-]/_/g' )
      ;;
    H)
      header=$OPTARG
      ;;
    O)
      loadcookiepath=$OPTARG
      ;;
    F)
      follow=1
      ;;
    *)
      usage
      exit 3
      ;;
  esac
done

#hostname is required
if [ -z "$url" ] || [ $# -eq 0 ]; then
  echo "Error: URL is required"
  usage
  exit 3
fi

proxyarg=""
if [ ! -z $proxy ] ; then
  proxyarg=" -x "$proxy" "
fi
headerarg=""
if [ ! -z "$header" ] ; then
  headerarg=' -H "'$header'" '
fi
followarg=""
if [ $follow -eq 1 ] ; then
  followarg=" -L "
fi
insecurearg=""
if [ $insecure -eq 1 ] ; then
  insecurearg=" --insecure "
fi
bodyarg=""
if [ ! -z $body ]; then
  bodyarg=" --data-urlencode $body"
fi
loadcookiearg=""
if [ ! -z $loadcookiepath ]; then
  cookieval=$(cat $loadcookiepath)
  loadcookiearg=" -H \"Cookie: ObSSOCookie=$cookieval\" "
  url="https://"$url
  proxyarg=""
fi

start=$(echo $(($(date +%s%N)/1000000)))
body=$(eval $curl --no-keepalive -L -s $insecurearg $proxyarg $followarg $loadcookiearg $bodyarg $headerarg -X $method "$url")
status=$?

end=$(echo $(($(date +%s%N)/1000000)))
#decide output by return code
if [ $status -eq 0 ] ; then
  if [ -n "$contains" ]; then
    if [[ ! $body == *$contains* ]]; then
      echo "CRITICAL: body does not contain '${contains}'|time=$((end - start))ms;${warning};${critical};0;"$critical"ms"
      exit 2
    fi
  fi
  echo "$(checkTime $((end - start))) $((end - start))ms - ${url}|time=$((end - start))ms;${warning};${critical};0;"$critical"ms"
  getStatus $((end - start))
  exit $?
else
  case $status in
    1)
      echo "CRITICAL: Unsupported protocol"
      ;;
    3)
      echo "CRITICAL: Malformed URL"
      ;;
    22)
      echo "CRITICAL: Server returned http code >= 400"
      ;;
    5)
      echo "CRITICAL: Couldn't resolve proxy $proxy"
      ;;
    6)
      echo "CRITICAL: Couldn't resolve host"
      ;;
    7)
      echo "CRITICAL: Couldn't connect to proxy $proxy"
      ;;
    56)
      echo "CRITICAL: Failure recieving network data (56)"
      ;;
    60)
      echo "CRITICAL: SSL/TLS connection problem (60)"
      ;;
    *)
      echo "UNKNOWN: $status - ${url}"
      exit 3
      ;;
  esac
  exit 2
fi
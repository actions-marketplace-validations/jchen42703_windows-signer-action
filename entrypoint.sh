#!/bin/bash

set -e

if [[ -z "$GITHUB_WORKSPACE" ]]; then
  echo "Set the GITHUB_WORKSPACE env variable."
  exit 1
fi

echo "--> outputting cert and key to files"
mkdir /certs
# The quotations around the cert/key vars are very import to handle line breaks
echo "${WINDOWS_CERT}" > /certs/bundle.crt
echo "${WINDOWS_KEY}" > /certs/codesign.key

echo "--> signing binary"

# create an array of timestamp servers...
# SERVERLIST=(timestamp.globalsign.com/?signature=sha2 http://timestamp.globalsign.com/scripts/timestamp.dll http://tsa.starfieldtech.com)
# http://timestamp.digicert.com http://ts.ssl.com
# http://timestamp.comodoca.com
SERVERLIST=(http://sha256timestamp.ws.symantec.com/sha256/timestamp)

# Sign file and if fails, rotate. If consumed all servers, and still fails, fail nonexclusively.
for SERVER in ${SERVERLIST[@]}; do
  echo "Timestamping with: ${SERVER}"
  SIGNED=$(/osslsigncode/osslsigncode-1.7.1/osslsigncode sign -certs /certs/bundle.crt -key /certs/codesign.key \
           -h sha256 -n ${NAME} -i ${DOMAIN} -t ${SERVER} -in ${BINARY} -out /signedbinary)
  if [ $? -eq 0 ]; then
    echo "Succeeded signing..."
    break
  fi
  if [SIGNED | grep -q "authenticode timestamping failed"];
  then
    # signing fails due to timeout
    echo "--> Signing failed due to rate limiting...retrying with different timestamp server"
  else
    echo "--> Signing failed. Check your configs."
    break
  fi
done

echo "--> overwriting existing binary with signed binary"
cp /signedbinary ${BINARY}
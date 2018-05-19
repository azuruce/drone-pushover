#!/bin/sh
if [ ! -z $PLUGIN_DEBUG ]; then set -o xtrace; fi

if [ "$CI_BUILD_STATUS" == "success" ]; then
  STATUS_COLOR="green"
  STATUS_SOUND="gamelan"
else
  STATUS_COLOR="red"
  STATUS_SOUND="falling"
fi

STATUS_COLOR_PRE="<b><font color=${STATUS_COLOR}>"
STATUS_COLOR_POST="</font></b>"

# set default pushover config
[ -z $PLUGIN_HTML] && PLUGIN_HTML=1
[ -z $PLUGIN_USER ] && PLUGIN_USER=${PUSHOVER_USER}
[ -z $PLUGIN_TOKEN ] && PLUGIN_TOKEN=${PUSHOVER_TOKEN}
[ -z $PLUGIN_TITLE ] && PLUGIN_TITLE="$(echo ${CI_BUILD_STATUS} | tr a-z A-Z) ${DRONE_REPO_NAME}/${DRONE_REPO_BRANCH}"
[ -z $PLUGIN_URL_TITLE ] && PLUGIN_URL_TITLE="build ${DRONE_BUILD_NUMBER}"
[ -z $PLUGIN_URL ] && PLUGIN_URL=${DRONE_BUILD_LINK}
[ -z $PLUGIN_MESSAGE ] && PLUGIN_MESSAGE="${STATUS_COLOR_PRE}${CI_COMMIT_AUTHOR}'s ${CI_BUILD_EVENT} ${CI_COMMIT_SHA: -4}: ${CI_COMMIT_MESSAGE}${STATUS_COLOR_POST}"
[ -z $PLUGIN_SOUND ] && PLUGIN_SOUND="${STATUS_SOUND}"

# if debug plugin, set curl_flag to -v (verbose), otherwise set to curl_flag plugin parameter, or -s (silence)
[ ! -z $PLUGIN_DEBUG ] && PLUGIN_CURL_FLAG=-v
[ -z $PLUGIN_CURL_FLAG ] && PLUGIN_CURL_FLAG=-s

# print drone env
printenv | grep DRONE

# print pushover config
echo PLUGIN_USER_LAST4=${PLUGIN_USER: -4}
echo PLUGIN_TOKEN_LAST4=${PLUGIN_TOKEN: -4}
set | grep PLUGIN | grep -v PLUGIN_USER | grep -v PLUGIN_TOKEN

RESP=$(curl ${PLUGIN_CURL_FLAG} \
  --form-string "html=${PLUGIN_HTML}" \
  --form-string "user=${PLUGIN_USER}" \
  --form-string "token=${PLUGIN_TOKEN}" \
  --form-string "title=${PLUGIN_TITLE}" \
  --form-string "message=${PLUGIN_MESSAGE}" \
  --form-string "sound=${PLUGIN_SOUND}" \
  --form-string "url_title=${PLUGIN_URL_TITLE}" \
  --form-string "url=${PLUGIN_URL}" \
  https://api.pushover.net/1/messages.json)

echo $RESP

# pushover returns json that has status:1 if success
[ $(echo $RESP | jq .status) == 1 ]

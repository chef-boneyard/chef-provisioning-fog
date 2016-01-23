#!/usr/bin/env bash

set -o errexit

POST_SCRIPT_DONE="post-script-done"

if [ -e /usr/bin/apt-get ]; then
    apt-get update -y
    # some SoftLayer debian images do not have these installed out of the box.
    apt-get install -y curl sudo
fi

curl_body=$(curl https://api.service.softlayer.com/rest/v3/SoftLayer_Resource_Metadata/getUserMetadata)

if [ "$curl_body" = "\"$POST_SCRIPT_DONE\"" ]; then
	echo "already run"
	exit 0
fi

#bugbug in theory the VM could provision before the provisioner calls
#setUserMetadata, so meta might be blank and we should deal with that here.

# we are trusting the input here because it has to be set with setUserMetadata
# which requires the user's API key. They can already do anything they want to
# this server or their account using the same API key so there should be no
# privilege escalation.

# the response body is enclosed in double quotes which need to be removed
# before decoding
meta=$(echo "$curl_body" | tr -d '"')
conf=$(echo -n "$meta" | base64 --decode)

# chef-provisioning-fog SoftLayer driver provides the variables:
#   POSTINST_REQUESTED_URL
#   POSTINST_UPDATE_URL
eval "$conf"

if [ "$POSTINST_REQUESTED_URL" ]; then
    curl "$POSTINST_REQUESTED_URL" --output user_post_install
    chmod +x user_post_install
    ./user_post_install
fi

# update user metadata so that the waiting SoftLayer driver can move on
curl ${POSTINST_UPDATE_URL} --header content-type:application/json --data '{"parameters":[["'"$POST_SCRIPT_DONE"'"]]}'

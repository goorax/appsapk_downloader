#!/bin/bash

readonly BASIC_URL='http://www.appsapk.com/'
readonly ROOT_URL=$BASIC_URL'android/all-apps/page/'
readonly APP_PATTERN='<a href="http://www.appsapk.com/.*/" title='
readonly DOWNLOAD_PATTERN='<p><a class="download" rel="nofollow" href=".*">Download APK</a></p>'
readonly WHITESPACE_REPLACE='s/ /%20/g'
readonly SLASH='/'

receive_content() {
    content=$(curl -s $ROOT_URL$1$SLASH | egrep -i "$APP_PATTERN" | cut -d/ -f4 | uniq)
}

receive_apk_url() {
    apk_url=$(curl -s $1 | egrep -i "$DOWNLOAD_PATTERN" | cut -d\" -f6 | sed -e "$WHITESPACE_REPLACE")
}

download_apk() {
    if [[ $1 == *apk ]]; then
	wget $1
    fi
}

crawl_repository() {	   
    for site in {1..10}
	do
   	receive_content $site
        for app_entry in $content
            do
	    receive_apk_url $BASIC_URL$app_entry$SLASH
	    download_apk $apk_url
        done
    done
}

crawl_repository



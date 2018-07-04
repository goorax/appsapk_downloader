#!/bin/bash

readonly BASIC_URL='https://www.appsapk.com/'
readonly ROOT_URL=$BASIC_URL'android/all-apps/page/'
readonly APP_PATTERN='<a href="https://www.appsapk.com/.*/" title='
readonly DOWNLOAD_PATTERN='<p><a class="download" rel="nofollow" href=".*">Download APK</a></p>'
readonly WHITESPACE_REPLACE='s/ /%20/g'
readonly SLASH='/'


show_usage() { echo "Usage: $0 -m [2..100] max. pages to crawl" 1>&2; exit 1; }

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
    for site in $(seq 1 $max);
    do
   	receive_content $site
        for app_entry in $content
            do
	    receive_apk_url $BASIC_URL$app_entry$SLASH
	    download_apk $apk_url
        done
    done
}

while getopts ":m:" opt; do
    max=2
    case "${opt}" in
            m)
                max=$OPTARG
                ;;
            \?)
                show_usage
                ;;
            :)
                echo "Invalid option: -$OPTARG requires an integer argument" >&2
                ;;
    esac
done
crawl_repository



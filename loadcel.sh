#!/bin/bash
# generate samples.csv list via https://www.ncbi.nlm.nih.gov/geo/browse/?view=samples&suppl=CEL&zsort=date&display=20 > "Export"

# Usage: ./loadcel.sh <path/to/target/folder>
TARGET_PATH=data

# Semi hard coded values
DATASET="im2text"
OUTPUT="im2text.json"

function die
{
    local message=$1
    [ -z "$message" ] && message="Died"
    echo "$message at ${BASH_SOURCE[1]}:${FUNCNAME[1]} line ${BASH_LINENO[0]}." >&2
    exit 1
}


function ensure_cmd_or_install_package_apt() {
  local CMD=$1
  shift
  local PKG=$*
  hash $CMD 2>/dev/null || { 
    log warn $CMD not available. Attempting to install $PKG
    (sudo apt-get update -yqq && sudo apt-get install -yqq ${PKG}) || die "Could not find $PKG"
  }
}

function is_sudoer() {
    CAN_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
    if [ ${CAN_RUN_SUDO} -gt 0 ]
    then
        echo 1
    else
        echo 0
    fi
}

function download_image() {
  local ID=$1
  shift
  local OUTPUT="$1"
  local CAPTION=$(echo $ID | awk -F '\t' '{print $3 " Sample of " $4, "organism of", $2}' | sed 's/\"//g' )
  local FLICKR_ID=$(echo $ID | awk -F '\t' '{print $1}' | sed 's/^...//')
  local IMAGE_ID="$(printf '%012d' ${FLICKR_ID})"
  # local IMAGE="$(sed -n ${ID}p ${TARGET_PATH}/dataset/SBU_captioned_photo_dataset_urls.txt)"
  local IMAGE=$(echo $ID | awk -F '\t' '{print $9}' | sed 's/^.\(.*\).$/\1/' )
  local IMAGE_PATH="${TARGET_PATH}/${DATASET}/${DATASET}_${IMAGE_ID}.jpg"
  # download images
  mkdir -p ${TARGET_PATH}/${DATASET}
  wget -r -nH --cut-dirs=5 -nc "$IMAGE" -O $IMAGE_ID.CEL.gz
  gunzip $IMAGE_ID.CEL.gz
  Rscript --vanilla convert.R $IMAGE_ID.CEL ${TARGET_PATH}/${DATASET} ${DATASET}_${IMAGE_ID}
  echo ${CAPTION} ${FLICKR_ID} ${IMAGE_ID} ${IMAGE_PATH} ${IMAGE} ${FLICKR_ID}
  mkdir -p tmp
  # generate json file
   cat "${OUTPUT}" | jq ". + [ {\"captions\": [ \"${CAPTION}\" ], \"id\": \"${IMAGE_ID}\", \"file_path\": \"${IMAGE_PATH}\", \"url\": \"${IMAGE}\", \"image_id\": \"${FLICKR_ID}\"  }]" > tmp/tmp.file.tmp

 mv tmp/tmp.file.tmp "${OUTPUT}"
}

# Check if we are sudoer or not
#if [ $(is_sudoer) -eq 0 ]; then
#    die "You must be root or sudo to run this script"
#fi

export die
# Eventually installing dependencies
ensure_cmd_or_install_package_apt jq jq
ensure_cmd_or_install_package_apt wget wget

echo "Creating Target folder"
[ -d "${TARGET_PATH}" ] && echo "Target path already started, moving forward" || mkdir -p "${TARGET_PATH}"

# test if initial file is there
echo "Downloading source dataset if needed"
[ -f sample.tsv ] && echo "Already there, moving forward" || echo "please add samples.tsv from https://www.ncbi.nlm.nih.gov/geo/browse/?view=samples&suppl=CEL&zsort=date&display=20"

echo "Creating output json file ${TARGET_PATH}/${OUTPUT}"
[ -f "${TARGET_PATH}/${OUTPUT}" ] && echo "Output file already created, moving forward" || echo "[]" > "${TARGET_PATH}/${OUTPUT}"

# iterate over sample.csv
IFS=$'\n' # make newlines the only separator
set -f # disable globbing
for i in $(cat sample.tsv); do
  download_image ${i} "${TARGET_PATH}/${OUTPUT}"
done

rm -rf ftp.ncbi.nlm.nih.gov


#echo "Combining all datasets now"
#[ -f "${TARGET_PATH}/${DATASET}.json" ] || echo "[]" > "${TARGET_PATH}/${DATASET}.json"
#jq -s add "${TARGET_PATH}/${DATASET}.json" "${TARGET_PATH}"/im2text.*.json > /tmp/final.json \
#  && mv /tmp/final.json "${TARGET_PATH}/${DATASET}.json"


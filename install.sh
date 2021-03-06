#!/bin/sh

os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "$os_name" = "linux" ]; then
    arch=$(uname -m | tr '[:upper:]' '[:lower:]')
    if echo "$arch" | grep -q 'x86_64'
    then
        platform="linux"
    elif echo "$arch" | grep -q -E '(x86)|(i686)'
    then
        platform="linux"
    else
        echo "Unsupported Linux architecture: ${arch}. Quit installation."
        exit 1
    fi
elif [ "$os_name" = "darwin" ]; then
    platform="darwin"
    arch=$(uname -m | tr '[:upper:]' '[:lower:]')
else
    echo "Unrecognized Linux platform: ${os_name}. Quit installation."
    exit 1
fi

cd /tmp

if [ "${GITHUB_TOKEN}" = "" ]; then
    echo "GITHUB_TOKEN empty"
    exit 1
fi

if [ "${VERSION}" = "" ]; then
    echo "VERSION empty"
    exit 1
    else
        echo "Download Ver. $VERSION"
fi

download () {
    curl -sLJO -H "Accept: application/octet-stream" -H "Authorization: Bearer $GITHUB_TOKEN" \
        "https://$GITHUB_TOKEN@api.github.com/repos/nozomi-nishinohara/k8s-auth0-cli/releases/assets/$1"
}

TAR_FILE=k8s-auth0_${platform}_${arch}.tar.gz

rm -f $TAR_FILE

TAG_INFO=$(curl -sL -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/nozomi-nishinohara/k8s-auth0-cli/releases/tags/v$VERSION)
VALIABLE=$(echo $TAG_INFO | tr -d '[:cntrl:]' | jq ".assets[] | select(.name | contains(\"${platform}_$arch\")) | .id")
# CHECK_SUM=$(echo $TAG_INFO | jq ".assets[] | select(.name | contains(\"checksums\")) | .id")
download $VALIABLE
[ "$(id -u)" -ne 0 ] && SUDO=sudo || SUDO=""

tar -xvf $TAR_FILE
chmod +x k8s-auth0
$SUDO mv k8s-auth0 /usr/bin/
rm -f $TAR_FILE
echo "Install Compleate"
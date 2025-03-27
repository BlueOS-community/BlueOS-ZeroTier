#! /bin/bash
echo "Downloading zerotier-one"
ARCH=$(uname -m)

echo "ARCH: $ARCH"
# map to available files on debian repos
if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
fi
if [ "$ARCH" = "aarch64" ]; then
  ARCH="arm64"
fi
if [ "$ARCH" = "armv7l" ]; then
  ARCH="armhf"
fi


echo "${PACKAGE_BASEURL}/zerotier-one_${VERSION}_${ARCH}.deb"
apt-get update -qq
echo "Installing curl"
apt-get install curl -y
echo "Downloading zerotier-one"
curl -sSL -o zerotier-one.deb "${PACKAGE_BASEURL}/zerotier-one_${VERSION}_${ARCH}.deb"

#!/usr/bin/bash

set -oue pipefail

IMAGE_PRETTY_NAME="Bluefin"
IMAGE_LIKE="rhel centos fedora bazzite nobara ultramarine"
HOME_URL="https://projectbluefin.io"
DOCUMENTATION_URL="https://docs.projectbluefin.io"
SUPPORT_URL="https://community.projectbluefin.io"
BUG_SUPPORT_URL="https://github.com/ublue-os/bluefin/issues/"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"
# IMAGE_BRANCH_NORMALIZED=$IMAGE_BRANCH

# if [[ $IMAGE_BRANCH_NORMALIZED == "main" ]]; then
#   IMAGE_BRANCH_NORMALIZED="stable"
# fi

case "$FEDORA_MAJOR_VERSION" in
  39|40)
    IMAGE_TAG="stable"
    ;;
  *)
    IMAGE_TAG="$FEDORA_MAJOR_VERSION"
    ;;
esac

# Image Info File
cat > $IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$IMAGE_FLAVOR",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag": "$IMAGE_TAG",
  "image-branch": "$IMAGE_BRANCH_NORMALIZED",
  "base-image-name": "$BASE_IMAGE_NAME",
  "fedora-version": "$FEDORA_MAJOR_VERSION",
  "version": "$VERSION_TAG",
  "version-pretty": "$VERSION_PRETTY"
}
EOF

# OS Release File
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Bazzite $FEDORA_MAJOR_VERSION (FROM Fedora ${BASE_IMAGE_NAME^})\"/" /usr/lib/os-release
sed -i "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:universal-blue:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
sed -i "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" /usr/lib/os-release
sed -i "s/^LOGO=.*/LOGO=$LOGO_ICON/" /usr/lib/os-release
sed -i "s/^ANSI_COLOR=.*/ANSI_COLOR=\"$LOGO_COLOR\"/" /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release
sed -i "s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"$CODE_NAME\"|" /usr/lib/os-release

if [[ -n "${SHA_HEAD_SHORT:-}" ]]; then
  echo "BUILD_ID=\"$SHA_HEAD_SHORT\"" >> /usr/lib/os-release
fi

# FIXME: Pretty name needs to have deck/KDE/GNOME/etc
echo "BOOTLOADER_NAME=\"$IMAGE_PRETTY_NAME $VERSION_PRETTY\"" >> /usr/lib/os-release

# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

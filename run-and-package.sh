#!/bin/bash -ex

if [ $# -lt 3 ]; then
    echo "Usage: $0 IMAGE_ID EMACS_SRC xxx=yyy zzz=www"
    exit 1
fi

IMAGE_ID="$1"
shift

EMACS_SRC="$(realpath $1)"
shift

CONTAINER_ID="emacs-appimage-build-$$-$(date +%s)"

# use remaining arguments as extra arguments
docker run \
       --name "$CONTAINER_ID" \
       -v "$EMACS_SRC:/work/emacs-src" \
       "$IMAGE_ID" \
       env "$@" scripts/build_emacs_in_docker.sh

docker cp $CONTAINER_ID:/work/dist ./dist

# download appimagetool-x86_64.AppImage if not exists
if [ ! -f ./appimagetool-x86_64.AppImage ]; then
    wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x ./appimagetool-x86_64.AppImage
fi

ARCH=x86_64 ./appimagetool-x86_64.AppImage --no-appstream ./dist/AppDir ./dist/Emacs.AppImage

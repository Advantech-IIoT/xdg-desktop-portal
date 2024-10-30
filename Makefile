all: build

YOCTO_VERSION=mickledore

SRC_PATH=$(CURDIR)
OUTPUT_PATH=$(CURDIR)/build
DESTINATION_PATH=$(SRC_PATH)
VERSION=$(shell git describe --tags `git rev-list --tags --max-count=1`)

ifeq ($(YOCTO_VERSION),kirkstone)
  DOCKERFILE=./res/kirkstone_qt_builder.Dockerfile
  DOCKER_TAG_NAME=advantech/qt-builder-kirkstone
else
  DOCKERFILE=./res/mickledore_qt_builder.Dockerfile
  DOCKER_TAG_NAME=advantech/qt-builder-mickledore
endif

build-image:
	docker buildx build --platform linux/arm64 -t $(DOCKER_TAG_NAME) -f $(DOCKERFILE) .

build: build-image
	@echo "build in docker"
	docker run --rm --platform linux/arm64 -v $(SRC_PATH):/src $(DOCKER_TAG_NAME) make linux-build

linux-build: clean
	@echo "make start"
	meson build/; cd build/; ninja

install:
	@echo "install xdg-desktop-portal"
	mkdir -p $(DESTINATION_PATH)/usr/local/libexec
	cp build/xdg-desktop-portal $(DESTINATION_PATH)/usr/local/libexec/
	cp build/xdg-desktop-portal.service $(DESTINATION_PATH)/usr/lib/systemd/user/
	cp build/org.freedesktop.portal.Desktop.service $(DESTINATION_PATH)/usr/share/dbus-1/services/
	mkdir -p $(DESTINATION_PATH)/usr/share/common-licenses/xdg-desktop-portal
	cp $(SRC_PATH)/COPYING $(DESTINATION_PATH)/usr/share/common-licenses/xdg-desktop-portal

clean:
	rm -rf build/

clean-meson-build:
	@echo "copy xdg-desktop-portal artifacts"
	cp build/src/xdg-desktop-portal build/
	cp build/src/xdg-desktop-portal.service build/
	cp build/src/org.freedesktop.portal.Desktop.service build/
	@echo "remove meson files"
	rm -rf build/data
	rm -rf build/meson-*
	rm -rf build/src
	rm -rf build/.*ignore
	rm -rf build/.ninja*
	rm -rf build/*.ninja
	rm -rf build/*.json
	rm -rf build/*.h

create-sbom: clean-sbom clean-meson-build
	cd build && sbom-tool generate -b . -bc . -pn xdg-desktop-portal -pv $(VERSION) -ps Advantech -nsb "https://github.com/Advantech-IIoT"
	cp build/_manifest/spdx_2.2/manifest.spdx.json $(DESTINATION_PATH)/../../scripts/out/sbom/xdg-desktop-portal.manifest.spdx.json

clean-sbom:
	rm -rf build/_manifest

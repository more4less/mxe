# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := zstd
$(PKG)_WEBSITE  := https://github.com/facebook/zstd
$(PKG)_DESCR    := Zstandard is a fast lossless compression algorithm
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.5.7
$(PKG)_CHECKSUM := 37d7284556b20954e56e1ca85b80226768902e2edabd3b649e9e72c0c9012ee3
$(PKG)_GH_CONF  := facebook/zstd/tags,v
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc

$(PKG)_DEPS_$(BUILD) :=
$(PKG)_OO_DEPS_$(BUILD) := $(MXE_CONF_PKGS)

define $(PKG)_BUILD
    # build and install the library
    # use cmake to ensure shared builds "do the right thing"
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)/build/cmake' \
        -DZSTD_BUILD_STATIC=$(CMAKE_STATIC_BOOL) \
        -DZSTD_BUILD_SHARED=$(CMAKE_SHARED_BOOL) \
        -DZSTD_BUILD_PROGRAMS=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' lib$(PKG) --cflags --libs`
endef

define $(PKG)_BUILD_$(BUILD)
    # build and install the library and programs
    # use make to avoid cmake dependency for gcc10+
    $(MAKE) -C '$(SOURCE_DIR)/lib' -j '$(JOBS)' V=1 libzstd.a
    $(MAKE) -C '$(SOURCE_DIR)/lib' -j 1 V=1 \
        prefix='$(PREFIX)/$(TARGET)' \
        install-pc \
        install-static \
        install-includes
    $(MAKE) -C '$(SOURCE_DIR)/programs' -j '$(JOBS)' V=1 zstd-release
    $(MAKE) -C '$(SOURCE_DIR)/programs' -j 1 V=1 \
        prefix='$(PREFIX)/$(TARGET)' \
        mandir='$(BUILD_DIR)' \
        install
endef

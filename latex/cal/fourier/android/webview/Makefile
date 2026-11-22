# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
APP = soleil-web
PKG = fr.sbeaugrand.soleilweb
MIN_SDK = 26
TARGET_SDK = 35
BUILD_TOOLS_VERSION = 35.0.0
VERSION_CODE = 1
VERSION_NAME = 1.0

SDK ?= $(HOME)/Android/Sdk
BUILD_TOOLS ?= $(SDK)/build-tools/$(BUILD_TOOLS_VERSION)
ANDROID_JAR ?= $(SDK)/platforms/android-$(TARGET_SDK)/android.jar
CMDLINE_TOOLS_ZIP ?= commandlinetools-linux-11076708_latest.zip
KEYSTORE ?= $(HOME)/.android/debug.keystore
BDIR ?= build
HTML = ../../html

SRCS = $(shell find src -name '*.java')
RES = $(shell find res -type f)

.PHONY: all
all: $(BDIR)/$(APP).apk

.PHONY: help
help:
	@echo
	@echo "sudo apt install default-jdk-headless"
	@echo "make sdk"
	@echo "make [COEFFS=../../../build/coeffs2026-2033]"
	@echo "make install"
	@echo

# SDK minimal : build-tools + platform (sans Android Studio ni Gradle)
.PHONY: sdk
sdk: $(BUILD_TOOLS)/d8 $(ANDROID_JAR)
$(SDK)/cmdline-tools/latest/bin/sdkmanager:
	@mkdir -p $(SDK)/cmdline-tools
	cd $(SDK)/cmdline-tools &&\
	 wget -q https://dl.google.com/android/repository/$(CMDLINE_TOOLS_ZIP) &&\
	 unzip -q $(CMDLINE_TOOLS_ZIP) && $(RM) $(CMDLINE_TOOLS_ZIP) &&\
	 mv cmdline-tools latest
$(BUILD_TOOLS)/d8 $(ANDROID_JAR) &: $(SDK)/cmdline-tools/latest/bin/sdkmanager
	yes | $< --sdk_root=$(SDK) --licenses >/dev/null
	$< --sdk_root=$(SDK)\
	 "build-tools;$(BUILD_TOOLS_VERSION)" "platforms;android-$(TARGET_SDK)"
	@touch $(BUILD_TOOLS)/d8 $(ANDROID_JAR)

# Page HTML autonome (coefficients integres, cf. ../../html/Makefile) :
# reprise telle quelle, regeneree seulement si absente ou si COEFFS est donne
.PHONY: FORCE
FORCE:
$(HTML)/build/soleil.html: $(if $(COEFFS),FORCE)
	@$(MAKE) --no-print-directory -C $(HTML)\
	 $(if $(COEFFS),COEFFS=$(abspath $(COEFFS)))
$(BDIR)/assets/soleil.html: $(HTML)/build/soleil.html
	@mkdir -p $(dir $@)
	cp $< $@

$(BDIR)/classes.stamp: $(SRCS) $(ANDROID_JAR)
	@$(RM) -r $(BDIR)/classes && mkdir -p $(BDIR)/classes
	javac --release 11 -Xlint:-options -encoding UTF-8\
	 -classpath $(ANDROID_JAR) -d $(BDIR)/classes $(SRCS)
	@touch $@

$(BDIR)/dex/classes.dex: $(BDIR)/classes.stamp
	@mkdir -p $(BDIR)/dex
	$(BUILD_TOOLS)/d8 --release --min-api $(MIN_SDK) --lib $(ANDROID_JAR)\
	 --output $(BDIR)/dex $(shell find $(BDIR)/classes -name '*.class')

$(BDIR)/res.zip: $(RES)
	@mkdir -p $(BDIR)
	$(BUILD_TOOLS)/aapt2 compile --dir res -o $@

$(BDIR)/unsigned.apk: AndroidManifest.xml $(BDIR)/res.zip\
 $(BDIR)/assets/soleil.html $(BDIR)/dex/classes.dex
	$(BUILD_TOOLS)/aapt2 link -o $@ --manifest AndroidManifest.xml\
	 -I $(ANDROID_JAR) -A $(BDIR)/assets $(BDIR)/res.zip\
	 --min-sdk-version $(MIN_SDK) --target-sdk-version $(TARGET_SDK)\
	 --version-code $(VERSION_CODE) --version-name $(VERSION_NAME)
	cd $(BDIR)/dex && zip -q ../unsigned.apk classes.dex

$(KEYSTORE):
	@mkdir -p $(dir $@)
	keytool -genkeypair -keystore $@ -storepass android\
	 -alias androiddebugkey -keypass android -keyalg RSA -validity 10000\
	 -dname "CN=Android Debug,O=Android,C=US"

$(BDIR)/$(APP).apk: $(BDIR)/unsigned.apk $(KEYSTORE)
	$(BUILD_TOOLS)/zipalign -f 4 $< $@
	$(BUILD_TOOLS)/apksigner sign --ks $(KEYSTORE) --ks-pass pass:android $@
	@ls -l $@

.PHONY: install
install: $(BDIR)/$(APP).apk
	adb install -r $<
	adb shell am start -n $(PKG)/.MainActivity

.PHONY: clean
clean:
	@$(RM) -r $(BDIR) *~

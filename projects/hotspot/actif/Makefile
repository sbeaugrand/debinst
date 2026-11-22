# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
APP = actif
PKG = fr.sbeaugrand.actif
MIN_SDK = 26
TARGET_SDK = 35
BUILD_TOOLS_VERSION = 35.0.0
VERSION_CODE = 1
VERSION_NAME = 1.0

SDK ?= $(HOME)/Android/Sdk
BUILD_TOOLS ?= $(SDK)/build-tools/$(BUILD_TOOLS_VERSION)
ANDROID_JAR ?= $(SDK)/platforms/android-$(TARGET_SDK)/android.jar
KEYSTORE ?= $(HOME)/.android/debug.keystore
CMDLINE_TOOLS_ZIP ?= commandlinetools-linux-11076708_latest.zip
BDIR ?= build

SRCS = $(shell find src -name '*.java')
RES = $(shell find res -type f)

.PHONY: all
all: $(BDIR)/$(APP).apk

.PHONY: help
help:
	@echo
	@echo "sudo apt install default-jdk-headless"
	@echo "make sdk"
	@echo "make"
	@echo "make install"
	@echo "make log"
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

$(BDIR)/classes.stamp: $(SRCS) $(BDIR)/res.apk
	@$(RM) -r $(BDIR)/classes && mkdir -p $(BDIR)/classes
	javac --release 11 -Xlint:-options -encoding UTF-8\
	 -classpath $(ANDROID_JAR) -d $(BDIR)/classes\
	 $(SRCS) $(shell find $(BDIR)/gen -name '*.java')
	@touch $@

$(BDIR)/dex/classes.dex: $(BDIR)/classes.stamp
	@mkdir -p $(BDIR)/dex
	find $(BDIR)/classes -name '*.class' -print0 | xargs -0\
	 $(BUILD_TOOLS)/d8 --release --min-api $(MIN_SDK) --lib $(ANDROID_JAR)\
	 --output $(BDIR)/dex

$(BDIR)/res.zip: $(RES)
	@mkdir -p $(BDIR)
	$(BUILD_TOOLS)/aapt2 compile --dir res -o $@

# Genere aussi R.java (acces a R.string.url depuis le code)
$(BDIR)/res.apk: AndroidManifest.xml $(BDIR)/res.zip
	@$(RM) -r $(BDIR)/gen && mkdir -p $(BDIR)/gen
	$(BUILD_TOOLS)/aapt2 link -o $@ --manifest AndroidManifest.xml\
	 -I $(ANDROID_JAR) $(BDIR)/res.zip --java $(BDIR)/gen\
	 --min-sdk-version $(MIN_SDK) --target-sdk-version $(TARGET_SDK)\
	 --version-code $(VERSION_CODE) --version-name $(VERSION_NAME)

$(BDIR)/unsigned.apk: $(BDIR)/res.apk $(BDIR)/dex/classes.dex
	cp $< $@
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
	@# Android >= 10 affiche une icone "infos appli" pour toute appli
	@# sans activite LAUNCHER qui demande des permissions ; ce reglage
	@# cache (modifiable seulement par adb) supprime cette icone de remplacement.
	adb shell settings put global show_hidden_icon_apps_enabled 0
	@# Administrateur de l'appareil : bloque la desinstallation (bouton grise)
	@# tant qu'il est actif. Seul "make uninstall" (adb) peut le retirer.
	adb shell dpm set-active-admin $(PKG)/.AdminReceiver
	adb shell am start -n $(PKG)/.MainActivity

# Retire l'admin (debloque la desinstallation) puis desinstalle.
.PHONY: uninstall
uninstall:
	-adb shell dpm remove-active-admin $(PKG)/.AdminReceiver
	adb uninstall $(PKG)

.PHONY: log
log:
	adb logcat -s Actif

.PHONY: clean
clean:
	@$(RM) -r $(BDIR) *~

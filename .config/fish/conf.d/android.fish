set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Android/Sdk"
set -gx ANDROID_AVD_HOME "$HOME/.android/avd"
set -gx JAVA_HOME "/usr/lib/jvm/java-17-openjdk"

fish_add_path -g "$ANDROID_HOME/emulator"
fish_add_path -g "$ANDROID_HOME/platform-tools"
fish_add_path -g "$ANDROID_HOME/cmdline-tools/latest/bin"
fish_add_path -g "$JAVA_HOME/bin"

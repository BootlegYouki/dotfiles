set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Android/Sdk"
set -gx ANDROID_AVD_HOME "$HOME/.android/avd"
set -gx JAVA_HOME "/usr/lib/jvm/java-17-openjdk"

# fish_add_path "$ANDROID_HOME/emulator" # excluded to avoid shadowing /usr/bin/qemu-img with ancient Android 2.12 qemu-img; emulator is symlinked in ~/.local/bin/
fish_add_path -a -g "$ANDROID_HOME/platform-tools"
fish_add_path -a -g "$ANDROID_HOME/cmdline-tools/latest/bin"
fish_add_path -a -g "$JAVA_HOME/bin"

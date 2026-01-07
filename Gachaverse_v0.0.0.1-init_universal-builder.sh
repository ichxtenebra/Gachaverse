#!/bin/bash

apt update -qq
apt upgrade -y -qq
apt install -y -qq build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu1-mesa-dev libasound2-dev libpulse-dev libdbus-1-dev libudev-dev libxi-dev libxrandr-dev unzip wget openjdk-17-jdk python3 python3-pip git

pip3 install -q gdown

rm -rf workspace
mkdir -p workspace/Gachaverse
cd workspace/Gachaverse

mkdir -p sdk/cmdline-tools
cd sdk/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmd.zip
unzip -q cmd.zip
mv cmdline-tools latest
rm cmd.zip
cd ../../

yes | sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=sdk --licenses > /dev/null 2>&1
sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=sdk "platform-tools" "platforms;android-35" "build-tools;35.0.0" "ndk;23.2.8568313" > /dev/null 2>&1

wget -q https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip -O godot.zip
unzip -q godot.zip
mv Godot_v4.4-stable_linux.x86_64 godot
chmod +x godot
rm godot.zip

mkdir -p templates/4.4.stable
wget -q https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_export_templates.tpz -O templates.zip
unzip -q templates.zip
mv templates/* templates/4.4.stable/
rmdir templates 2>/dev/null
rm templates.zip

mkdir -p ~/.local/share/godot/export_templates
rm -rf ~/.local/share/godot/export_templates/4.4.stable
ln -sf "$(pwd)/templates/4.4.stable" ~/.local/share/godot/export_templates/4.4.stable

mkdir -p app/assets app/fonts app/scenes app/scripts icons key out

gdown -q "1DrVpx3Vu8TSmPSO19BVwgAcnclRmJzjs" -O icons/icon.png
gdown -q "1_xqZ1nklNxjNwRf5F4i9Z30D4s80TGc3" -O app/assets/background.png
gdown -q "1RPyR4l8lePcyTGVgbtOGCDM_HkAq2dK8" -O app/assets/music.mp3

wget -q "https://github.com/googlefonts/orbitron/raw/main/fonts/ttf/Orbitron-Black.ttf" -O app/fonts/Orbitron-Black.ttf

cp icons/icon.png app/icon.png

cat > app/project.godot << 'EOF'
config_version=5
[application]
config/name="Gachaverse"
config/version="0.0.0.1-init"
run/main_scene="res://scenes/splash.tscn"
config/features=PackedStringArray("4.4")
config/icon="res://icon.png"
[display]
window/size/viewport_width=1080
window/size/viewport_height=1920
window/handheld/orientation=1
[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
environment/defaults/default_clear_color=Color(0, 0, 0, 1)
EOF

cat > app/scripts/splash.gd << 'EOF'
extends Control

func _ready():
	$Music.finished.connect(_music_end)
	$TapButton.pressed.connect(_tap)

func _music_end():
	get_tree().quit()

func _tap():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
EOF

cat > app/scenes/splash.tscn << 'EOF'
[gd_scene load_steps=5 format=3 uid="uid://splash"]

[ext_resource type="Texture2D" path="res://assets/background.png" id="1"]
[ext_resource type="AudioStream" path="res://assets/music.mp3" id="2"]
[ext_resource type="FontFile" path="res://fonts/Orbitron-Black.ttf" id="3"]
[ext_resource type="Script" path="res://scripts/splash.gd" id="4"]

[node name="Splash" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("4")

[node name="Background" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
texture = ExtResource("1")
expand_mode = 1
stretch_mode = 6

[node name="TapLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -540.0
offset_top = -192.0
offset_right = 540.0
offset_bottom = -96.0
grow_horizontal = 2
grow_vertical = 0
theme_override_colors/font_color = Color(1, 1, 1, 1)
theme_override_colors/font_shadow_color = Color(0, 0, 0, 0.7)
theme_override_colors/font_outline_color = Color(0.2, 0, 0.4, 1)
theme_override_constants/shadow_offset_x = 3
theme_override_constants/shadow_offset_y = 3
theme_override_constants/outline_size = 8
theme_override_fonts/font = ExtResource("3")
theme_override_font_sizes/font_size = 64
text = "Tap Screen"
horizontal_alignment = 1
vertical_alignment = 1

[node name="TapButton" type="Button" parent="."]
modulate = Color(1, 1, 1, 0)
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
focus_mode = 0

[node name="Music" type="AudioStreamPlayer" parent="."]
stream = ExtResource("2")
autoplay = true
EOF

cat > app/scenes/main.tscn << 'EOF'
[gd_scene format=3 uid="uid://main"]

[node name="Main" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0

[node name="WhiteBackground" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(1, 1, 1, 1)
EOF

keytool -genkeypair -keystore key/release.keystore -alias gachaverse -keyalg RSA -keysize 2048 -validity 10000 -storepass gachaverse -keypass gachaverse -dname "CN=Gachaverse,OU=Void,O=ICHxTenebra,L=Unknown,ST=Unknown,C=XX" 2>/dev/null

mkdir -p ~/.config/godot
cat > ~/.config/godot/editor_settings-4.4.tres << EOF
[gd_resource type="EditorSettings" format=3]
[resource]
export/android/android_sdk_path = "$(pwd)/sdk"
export/android/java_sdk_path = "/usr/lib/jvm/java-17-openjdk-amd64"
export/android/debug_keystore = "$(pwd)/key/release.keystore"
export/android/debug_keystore_user = "gachaverse"
export/android/debug_keystore_pass = "gachaverse"
EOF

KEYSTORE="$(pwd)/key/release.keystore"

write_preset() {
cat > app/export_presets.cfg << EOF
[preset.0]

name="Android"
platform="Android"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
gradle_build/use_gradle_build=true
gradle_build/export_format=0
gradle_build/min_sdk="23"
gradle_build/target_sdk="35"
architectures/armeabi-v7a=$1
architectures/arm64-v8a=$2
architectures/x86=$3
architectures/x86_64=$4
keystore/debug="$KEYSTORE"
keystore/debug_user="gachaverse"
keystore/debug_password="gachaverse"
keystore/release="$KEYSTORE"
keystore/release_user="gachaverse"
keystore/release_password="gachaverse"
version/code=2
version/name="0.0.0.1-init"
package/unique_name="Help_From_the_Void_Independent_Systems.ICHxTenebra.Gachaverse"
package/name="Gachaverse"
package/signed=true
package/app_category=2
launcher_icons/main_192x192="res://icon.png"
launcher_icons/adaptive_foreground_432x432=""
launcher_icons/adaptive_background_432x432=""
graphics/opengl_debug=false
xr_features/xr_mode=0
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
command_line/extra_args=""
apk_expansion/enable=false
apk_expansion/SALT=""
apk_expansion/public_key=""
permissions/custom_permissions=PackedStringArray()
permissions/access_checkin_properties=false
permissions/access_coarse_location=false
permissions/access_fine_location=false
permissions/access_location_extra_commands=false
permissions/access_mock_location=false
permissions/access_network_state=false
permissions/access_surface_flinger=false
permissions/access_wifi_state=false
permissions/account_manager=false
permissions/add_voicemail=false
permissions/authenticate_accounts=false
permissions/battery_stats=false
permissions/bind_accessibility_service=false
permissions/bind_appwidget=false
permissions/bind_device_admin=false
permissions/bind_input_method=false
permissions/bind_nfc_service=false
permissions/bind_notification_listener_service=false
permissions/bind_print_service=false
permissions/bind_remoteviews=false
permissions/bind_text_service=false
permissions/bind_vpn_service=false
permissions/bind_wallpaper=false
permissions/bluetooth=false
permissions/bluetooth_admin=false
permissions/bluetooth_privileged=false
permissions/brick=false
permissions/broadcast_package_removed=false
permissions/broadcast_sms=false
permissions/broadcast_sticky=false
permissions/broadcast_wap_push=false
permissions/call_phone=false
permissions/call_privileged=false
permissions/camera=false
permissions/capture_audio_output=false
permissions/capture_secure_video_output=false
permissions/capture_video_output=false
permissions/change_component_enabled_state=false
permissions/change_configuration=false
permissions/change_network_state=false
permissions/change_wifi_multicast_state=false
permissions/change_wifi_state=false
permissions/clear_app_cache=false
permissions/clear_app_user_data=false
permissions/control_location_updates=false
permissions/delete_cache_files=false
permissions/delete_packages=false
permissions/device_power=false
permissions/diagnostic=false
permissions/disable_keyguard=false
permissions/dump=false
permissions/expand_status_bar=false
permissions/factory_test=false
permissions/flashlight=false
permissions/force_back=false
permissions/get_accounts=false
permissions/get_package_size=false
permissions/get_tasks=false
permissions/get_top_activity_info=false
permissions/global_search=false
permissions/hardware_test=false
permissions/inject_events=false
permissions/install_location_provider=false
permissions/install_packages=false
permissions/install_shortcut=false
permissions/internal_system_window=false
permissions/internet=false
permissions/kill_background_processes=false
permissions/location_hardware=false
permissions/manage_accounts=false
permissions/manage_app_tokens=false
permissions/manage_documents=false
permissions/manage_external_storage=false
permissions/master_clear=false
permissions/media_content_control=false
permissions/modify_audio_settings=false
permissions/modify_phone_state=false
permissions/mount_format_filesystems=false
permissions/mount_unmount_filesystems=false
permissions/nfc=false
permissions/persistent_activity=false
permissions/post_notifications=false
permissions/process_outgoing_calls=false
permissions/read_calendar=false
permissions/read_call_log=false
permissions/read_contacts=false
permissions/read_external_storage=false
permissions/read_frame_buffer=false
permissions/read_history_bookmarks=false
permissions/read_input_state=false
permissions/read_logs=false
permissions/read_phone_state=false
permissions/read_profile=false
permissions/read_sms=false
permissions/read_social_stream=false
permissions/read_sync_settings=false
permissions/read_sync_stats=false
permissions/read_user_dictionary=false
permissions/reboot=false
permissions/receive_boot_completed=false
permissions/receive_mms=false
permissions/receive_sms=false
permissions/receive_wap_push=false
permissions/record_audio=false
permissions/reorder_tasks=false
permissions/restart_packages=false
permissions/send_respond_via_message=false
permissions/send_sms=false
permissions/set_activity_watcher=false
permissions/set_alarm=false
permissions/set_always_finish=false
permissions/set_animation_scale=false
permissions/set_debug_app=false
permissions/set_orientation=false
permissions/set_pointer_speed=false
permissions/set_preferred_applications=false
permissions/set_process_limit=false
permissions/set_time=false
permissions/set_time_zone=false
permissions/set_wallpaper=false
permissions/set_wallpaper_hints=false
permissions/signal_persistent_processes=false
permissions/status_bar=false
permissions/subscribed_feeds_read=false
permissions/subscribed_feeds_write=false
permissions/system_alert_window=false
permissions/transmit_ir=false
permissions/uninstall_shortcut=false
permissions/update_device_stats=false
permissions/use_credentials=false
permissions/use_sip=false
permissions/vibrate=false
permissions/wake_lock=false
permissions/write_apn_settings=false
permissions/write_calendar=false
permissions/write_call_log=false
permissions/write_contacts=false
permissions/write_external_storage=false
permissions/write_gservices=false
permissions/write_history_bookmarks=false
permissions/write_profile=false
permissions/write_secure_settings=false
permissions/write_settings=false
permissions/write_sms=false
permissions/write_social_stream=false
permissions/write_sync_settings=false
permissions/write_user_dictionary=false
EOF
}

build_apk() {
    rm -rf app/android app/.godot
    mkdir -p app/android/build
    unzip -q templates/4.4.stable/android_source.zip -d app/android/build
    touch app/android/.gdignore
    echo "4.4.stable" > app/android/.build_version
    cd app
    GODOT_SILENCE_ROOT_WARNING=1 JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ANDROID_HOME="$(dirname $(pwd))/sdk" ../godot --headless --export-release "Android" "../out/$1" &
    PID=$!
    while true; do
        sleep 2
        [ -f "../out/$1" ] && [ $(stat -c%s "../out/$1" 2>/dev/null || echo 0) -gt 1000000 ] && break
    done
    sleep 5
    kill -9 $PID 2>/dev/null
    pkill -9 -f godot 2>/dev/null
    pkill -9 -f java 2>/dev/null
    pkill -9 -f gradle 2>/dev/null
    sleep 3
    cd ..
}

pkill -9 -f godot 2>/dev/null
pkill -9 -f java 2>/dev/null
pkill -9 -f gradle 2>/dev/null
sleep 2

echo "=== BUILD 1/5: universal ==="
write_preset true true true true
build_apk "Gachaverse_v0.0.0.1-init_universal.apk"

echo "=== BUILD 2/5: arm64-v8a ==="
write_preset false true false false
build_apk "Gachaverse_v0.0.0.1-init_arm64-v8a.apk"

echo "=== BUILD 3/5: armeabi-v7a ==="
write_preset true false false false
build_apk "Gachaverse_v0.0.0.1-init_armeabi-v7a.apk"

echo "=== BUILD 4/5: x86_64 ==="
write_preset false false false true
build_apk "Gachaverse_v0.0.0.1-init_x86_64.apk"

echo "=== BUILD 5/5: x86 ==="
write_preset false false true false
build_apk "Gachaverse_v0.0.0.1-init_x86.apk"

cd out
echo ""
echo "SHA-256:"
for f in *.apk; do echo "$f: $(sha256sum "$f" | cut -d' ' -f1)"; done
cd ..

ls -lh out/

echo ""
echo "====================================================================="
echo "                         BUILD COMPLETE                              "
echo "====================================================================="
echo ""
echo "  Version: 0.0.0.1-init"
echo "  Engine: Godot 4.4 Stable"
echo "  Min SDK: 23 (Android 6.0)"
echo "  Target SDK: 35 (Android 15)"
echo ""
echo "====================================================================="

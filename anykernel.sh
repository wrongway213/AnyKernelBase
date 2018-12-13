# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Krieg Kernel - OnePlus 5/T by APOPHIS9283, wrongway213, Yoinx, REV3NT3CH & ViRb3
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus5
device.name2=OnePlus5T
device.name3=cheeseburger
device.name4=dumpling
device.name5=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
find $ramdisk -type f -exec chmod 644 {} \;
chown -R root:root $ramdisk/*;

# Select the correct image to flash
userflavor="$(file_getprop /system/build.prop "ro.build.user"):$(file_getprop /system/build.prop "ro.build.flavor")";
case "$userflavor" in
  "OnePlus:OnePlus5-user"|"OnePlus:OnePlus5T-user")
    os="oos";
    os_string="OxygenOS";;
  *)
    os="custom";
    os_string="a custom ROM";;
esac;
ui_print " ";
ui_print "You are on $os_string!";

# Detect if treble
case $(file_getprop /system/build.prop "ro.treble.enabled") in
  "true") tre=treble; ui_print "Treble rom detected!";;
  *) tre=nontreble;;
esac

if [ -f /tmp/anykernel/kernels/$os/$tre/Image.gz-dtb ]; then
  mv /tmp/anykernel/kernels/$os/$tre/Image.gz-dtb /tmp/anykernel/Image.gz-dtb;
else
  die "There is no kernel for your OS in this zip! Aborting...";
fi;

# Ensure *.sh files in /krieg/ path are executable
find $ramdisk/krieg -name "*.sh" -exec chmod 750 {} \;

## AnyKernel install
dump_boot;

# Set the default background app limit to 60
insert_line default.prop "ro.sys.fw.bg_apps_limit=60" before "ro.secure=1" "ro.sys.fw.bg_apps_limit=60";

# Import init.krieg.rc file
remove_line init.rc "import /init.krieg.rc"
insert_line init.rc "init.krieg.rc" after "import /init.usb.rc" "import /init.krieg.rc";

# end ramdisk changes
write_boot;


## end install


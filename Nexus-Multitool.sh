#!/bin/bash

#Version
nmtver="0.10 Beta"

################## Sets up ADB and and directories ###
f_setup(){
  clear
  maindir=~/Nexus-Multitool
  commondir=$maindir/all
  mkdir -p $commondir
  clear

  unamestr=`uname`
  cd $maindir
  case $unamestr in
  Darwin)
    xcode-select --install
    if [ -d $commondir/tools ]; then
      clear
    else
      echo "Downloading ADB and Fastboot (Developer Tools required)"
      echo ""
      mkdir -p $commondir/tools
      cd $commondir
      git clone git://git.kali.org/packages/google-nexus-tools
      curl -o $commondir/tools/wget photonicgeek.me/Downloads/Tools/mac-wget --progress-bar
      clear
      echo "Setting Up Tools"
      cd $commondir
      mkdir -p $commondir/tools
      mv ./google-nexus-tools/bin/* ./tools/
      rm -rf ./bin
      rm -rf ./debian
      rm -rf install.sh
      rm -rf license.txt
      rm -rf README.md
      rm -rf udev.txt
      rm -rf uninstall.sh
      cd ~/
    fi
    wget=$commondir/tools/wget
    adb=$commondir/tools/mac-adb
    fastboot=$commondir/tools/mac-fastboot;;
  *)
    if [ -d $commondir/tools ]; then
      clear
    else
      echo "Installing wget (Password may be required)"
      echo ""
      sudo apt-get -qq update && sudo apt-get -qq -y install wget
      clear
      echo "Downloading ADB and Fastboot (Developer Tools required)"
      echo ""
      mkdir -p $commondir/tools
      cd $commondir
      git clone git://git.kali.org/packages/google-nexus-tools
      clear
      echo "Setting Up Tools"
      cd $commondir
      mkdir -p $commondir/tools
      mv ./google-nexus-tools/bin/* ./tools/
      rm -rf ./bin
      rm -rf ./debian
      rm -rf install.sh
      rm -rf license.txt
      rm -rf README.md
      rm -rf udev.txt
      rm -rf uninstall.sh
      cd ~/
    fi
    adb=$commondir/tools/linux-i386-adb
    fastboot=$commondir/tools/linux-i386-fastboot;;
  esac

  rm -rf $commondir/google-nexus-tools
  chmod 755 $wget
  chmod 755 $adb
  chmod 755 $fastboot
  clear
}

######################### Detects connected device ###
f_autodevice(){
  clear
  $adb start-server
  cd ~/
  clear
  echo "Connect your device now."
  echo ""
  echo "Start up your device like normal and open the settings menu and scroll down to"
  echo "'About Device' Tap on 'Build Number' 7 times and return to the main settings"
  echo "menu. Open 'Developer Options' and enable the box that says 'USB debugging'. In"
  echo "the RSA Autorization box that pops up, check the box that says 'Always allow"
  echo "from this computer' and tap 'OK'."
  echo ""
  echo "Waiting for device... If you get stuck here, something went wrong."
  $adb wait-for-device
  clear

  echo "Connecting to device and reading device information."
  devicemake=`$adb shell getprop ro.product.manufacturer`
  devicemodel=`$adb shell getprop ro.product.model`
  currentdevice=`$adb shell getprop ro.product.name`
  androidver=`$adb shell getprop ro.build.version.release`
  androidbuild=`$adb shell getprop ro.build.id`
  serialno=`$adb shell getprop ro.serialno`
  twrprecovery=`$adb shell ls /sdcard/ | grep "TWRP"`
  rootedrom=`$adb shell which su`

  androidver=$(echo $androidver|tr -d '\r\n')
  androidbuild=$(echo $androidbuild|tr -d '\r\n')
  devicemake=$(echo $devicemake|tr -d '\r\n')
  devicemodel=$(echo $devicemodel|tr -d '\r\n')
  currentdevice=$(echo $currentdevice|tr -d '\r\n')
  serialno=$(echo $serialno|tr -d '\r\n')
  twrprecovery=$(echo $twrprecovery|tr -d '\r\n')
  rootedrom=$(echo $rootedrom|tr -d '\r\n')

  if [ "$twrprecovery" == "TWRP" ]; then
    twrprecovery="Detected"
  else
    twrprecovery="Not Detected"
  fi

  if [ "$rootedrom" == "/system/xbin/su" ]||[ "$rootedrom" == "/system/sbin/su" ]||[ "$rootedrom" == "/system/bin/su" ]; then
    rootedrom="Rooted"
  else
    rootedrom="Not Rooted"
  fi

  clear
  case $currentdevice in
    sojus|sojuk|sojua|soju|mysidspr|mysid|yakju|takju|occam|hammerhead|shamu|nakasi|nakasig|razor|razorg|mantaray|volantis|tungsten|fugu)
      clear;;
    *)
      echo "This is not a Nexus device. This utility only supports Nexus devices."
      echo ""
      read -p "Press [Enter] to exit the script."
      clear
      exit;;
  esac

  devicedir=$maindir/$currentdevice
  scriptdir=$maindir/scripts
  mkdir -p $devicedir
  mkdir -p $scriptdir
}

######################################## Main Menu ###
f_menu(){
  f_autodevice
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo "Connected Device: $devicemake $devicemodel ($currentdevice) ($serialno)"
  echo "Android Version: $androidver ($androidbuild)"
  echo ""
  echo "[1] Unlock / Lock Bootloader"
  echo "[2] Root                       (Requires Unlocked Bootloader)"
  echo "[3] Install TWRP Recovery      (Requires Unlocked Bootloader)"
  echo "[4] Install custom ROM         (Requires Unlocked Bootloader + TWRP)"
  echo "[5] Flash Custom Files         (Requires Unlocked Bootloader)"
  echo "[6] Restore to Stock           (Requires Unlocked Bootloader)"
  echo "[7] Tools"
  echo ""
  echo "[S] Settings and Options."
  echo "[D] Go back and select a different device."
  echo "[Q] Quit."
  echo ""
  read -p "Selection: " menuselection

  case $menuselection in
    1) f_unlocklock; f_menu;;
    2) f_root; f_menu;;
    3) f_twrp; f_menu;;
    4) f_customrom; f_menu;;
    5) f_flash; f_menu;;
    6) f_restore; f_menu;;
    7) f_tools; f_menu;;
    S|s) f_options;;
    D|d)
      clear
      echo "Unplug your current device, and plug in a new one."
      echo ""
      read -p "Press [Enter] to continue." null
      clear
      f_menu;;
    Q|q) clear; exit;;
    *) f_menu;;
  esac
}

########################### Unlocks the bootloader ###
f_unlocklock(){
  clear
  echo "Would you like to unlock or lock your bootloader?"
  echo ""
  echo "[1] Unlock Bootloader"
  echo "[2] Lock Bootloader"
  echo ""
  echo "[M] Return to Main Menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection:" selection

  case $selection in
    1)
      clear
      case $currentdevice in
        volantis|shamu)
          $adb start-server
          clear
          echo "Start up your device like normal and open the settings menu and scroll down to 'Developer Options'"
          echo "and enable 'OEM unlock'."
          echo ""
          read -p "Press [Enter] to continue." null
          clear;;
        *)
          clear;;
      esac

      echo "THIS NEXT STEP WILL ERASE YOUR DEVICE'S DATA."
      echo ""
      echo "Make sure that anything you wish to keep is backed up and taken off of the device!"
      echo ""
      read -p "Press [Enter] to continue, or [M] to return to the main menu." null

      case $selection in
        M|m) f_menu;;
        *) clear;;
      esac

      clear
      $adb reboot bootloader
      sleep 20
      $fastboot oem unlock
      clear
      echo "On your device, select the option to accept, unlock your device's bootloader, and erase all data."
      echo ""
      read -p "Press [Enter] to continue." null
      clear
      echo "Bootloader Unlocked"
      echo ""
      read -p "Press [Enter] to return to the main menu." null;;
    2)
      clear
      echo "Are you sure you would like to lock the bootloader? To unlock again means you need to erase your"
      echo "data."
      echo ""
      read -p "Press [Enter] to continue, or [M] to return to the main menu." selection

      case $selection in
        M|m) f_menu;;
        *) clear;;
      esac

      $adb reboot bootloader
      clear
      $adb oem lock
      echo "Bootloader locked."
      echo ""
      read -p "Press [Enter] to return to the main menu."
      f_menu;;
    M|m) f_menu;;
    Q|q) clear; exit;;
  esac
}

################################# Roots the device ###
f_root(){
  clear
  case $currentdevice in
    mysidspr|mysid|yakju|takju|occam|shamu|hammerhead|nakasi|nakasig|razor|razorg|mantaray|volantis)
      clear
      echo "Downloading files to root device."
      cd $devicedir
      export currentdevice
      $wget -O $scriptdir/autoroot-download.py 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/autoroot-download.py' --progress=bar:force 2>&1 | wgetprogress
      clear
      echo "Downloading CFAutoroot to root device."
      python $scriptdir/autoroot-download.py
      clear
      echo "Download Complete."
      sleep 1
      mkdir -p $devicedir/root
      cd $devicedir/root
      unzip $devicedir/root.zip
      clear
      echo "Rooting your device. This may take a minute."
      $adb reboot bootloader
      sleep 15
      case $currentdevice in
        mysidspr) $fastboot boot $devicedir/root/image/CF-Auto-Root-toroplus-mysidspr-nexus7.img;;
        mysid) $fastboot boot $devicedir/root/image/CF-Auto-Root-toro-mysid-nexus7.img;;
        yakju) $fastboot boot $devicedir/root/image/CF-Auto-Root-maguro-yakju-nexus7.img;;
        takju) $fastboot boot $devicedir/root/image/CF-Auto-Root-maguro-takju-nexus7.img;;
        occam) $fastboot boot $devicedir/root/image/CF-Auto-Root-mako-occam-nexus7.img;;
        shamu) $fastboot boot $devicedir/root/image/CF-Auto-Root-shamu-shamu-nexus7.img;;
        hammerhead) $fastboot boot $devicedir/root/image/CF-Auto-Root-hammerhead-hammerhead-nexus7.img;;
        nakasi) $fastboot boot $devicedir/root/image/CF-Auto-Root-grouper-nakasi-nexus7.img;;
        nakasig) $fastboot boot $devicedir/root/image/CF-Auto-Root-tilapia-nakasig-nexus7.img;;
        razor) $fastboot boot $devicedir/root/image/CF-Auto-Root-flo-razor-nexus7.img;;
        razorg) $fastboot boot $devicedir/root/image/CF-Auto-Root-deb-razorg-nexus7.img;;
        mantaray) $fastboot boot $devicedir/root/image/CF-Auto-Root-manta-mantaray-nexus7.img;;
        volantis) $fastboot boot $devicedir/root/image/CF-Auto-Root-flounder-volantis-nexus7.img;;
      esac
      clear
      echo "Your device is now rooted! Give it a minute to complete the process."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      rm -rf $devicedir/root;;
    sojus|sojuk|sojua|soju)
      clear
      echo "Downloading files needed for root."
      cd $devicedir
      export currentdevice
      $wget -O $scriptdir/autoroot-download.py 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/autoroot-download.py' --progress=bar:force 2>&1 | wgetprogress
      python $scriptdir/autoroot-download.py
      clear
      echo "Download complete."
      sleep 1
      mv $devicedir/root.zip $devicedir/flashable-root.zip
      $adb reboot recovery
      sleep 15
      $adb push $devicedir/flashable-root.zip /sdcard/tmp/root.zip
      $adb shell "echo -e 'install /sdcard/tmp/root.zip\ncmd rm -rf /sdcard/tmp\nreboot\n' > /cache/recovery/openrecoveryscript"
      clear
      $adb reboot recovery
      echo "Your device is now being rooted! Give it a minute to finish, and it will reboot itself."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      f_menu;;
    *)
      clear
      echo "Sorry, but this device doesn't support being rooted at this time."
      echo ""
      read -p "Press [Enter] to return to the menu."
      f_menu;;
  esac
}

#################################### Installs TWRP ###
f_twrp(){
  clear
  case $currentdevice in
    sojus) url="http://techerrata.com/get/twrp2/crespo/openrecovery-twrp-2.8.1.0-crespo.img";;
    sojuk) url="http://techerrata.com/get/twrp2/crespo/openrecovery-twrp-2.8.1.0-crespo.img";;
    sojua) url="http://techerrata.com/get/twrp2/crespo/openrecovery-twrp-2.8.1.0-crespo.img";;
    soju) url="http://techerrata.com/get/twrp2/crespo/openrecovery-twrp-2.8.1.0-crespo.img";;
    mysidspr) url="http://techerrata.com/get/twrp2/toroplus/openrecovery-twrp-2.8.1.0-toroplus.img";;
    mysid) url="http://techerrata.com/get/twrp2/toro/openrecovery-twrp-2.8.1.0-toro.img";;
    yakju) url="http://techerrata.com/get/twrp2/maguro/openrecovery-twrp-2.8.1.0-maguro.img";;
    takju) url="http://techerrata.com/get/twrp2/maguro/openrecovery-twrp-2.8.1.0-maguro.img";;
    occam) url="http://techerrata.com/get/twrp2/mako/openrecovery-twrp-2.8.1.0-mako.img";;
    shamu) url="http://techerrata.com/get/twrp2/shamu/openrecovery-twrp-2.8.2.0-shamu.img";;
    hammerhead) url="http://techerrata.com/get/twrp2/hammerhead/openrecovery-twrp-2.8.1.0-hammerhead.img";;
    nakasi) url="http://techerrata.com/get/twrp2/grouper/openrecovery-twrp-2.8.1.0-grouper.img";;
    nakasig) url="http://techerrata.com/get/twrp2/tilapia/openrecovery-twrp-2.8.1.0-tilapia.img";;
    razor) url="http://techerrata.com/get/twrp2/flo/openrecovery-twrp-2.8.1.0-flo.img";;
    razorg) url="http://techerrata.com/get/twrp2/deb/openrecovery-twrp-2.8.1.0-deb.img";;
    mantaray) url="http://techerrata.com/get/twrp2/manta/openrecovery-twrp-2.8.1.0-manta.img";;
    volantis) url="http://techerrata.com/get/twrp2/volantis/openrecovery-twrp-2.8.2.1-volantis.img";;
    *)
      clear
      echo "Sorry, but this device doesn't support being rooted at this time."
      echo ""
      read -p "Press [Enter] to return to the menu."
      f_menu;;
  esac
  echo "Downloading TWRP"
  $wget -O $devicedir/$currentdevice-twrp.img $url --progress=bar:force 2>&1 | wgetprogress
  clear
  echo "Rebooting into the bootloader."
  $adb reboot bootloader
  $fastboot flash recovery $devicedir/$currentdevice-twrp.img
  $fastboot reboot
  clear
  echo "TWRP install complete. Your device is now rebooting."
  echo ""
  read -p "Press [Enter] to return to the main menu." null
  f_menu
}

####################################### Custom ROM ###
f_customrom(){
  clear
  echo "Select a ROM to install:"
  echo ""
  if [ $currentdevice == "mysidspr" ]||[ $currentdevice == "mysid" ]||[ $currentdevice == "yakju" ]||[ $currentdevice == "takju" ]||[ $currentdevice == "occam" ]||[ $currentdevice == "hammerhead" ]||[ $currentdevice == "nakasi" ]||[ $currentdevice == "nakasig" ]||[ $currentdevice == "razor" ]||[ $currentdevice == "razorg" ]||[ $currentdevice == "mantaray" ]; then
    echo "[P] Paranoid Android"
  else
    echo "[X] Paranoid Android not avaliable."
  fi
  if [ $currentdevice == "yakju" ]||[ $currentdevice == "takju" ]||[ $currentdevice == "occam" ]||[ $currentdevice == "hammerhead" ]||[ $currentdevice == "nakasi" ]||[ $currentdevice == "nakasig" ]||[ $currentdevice == "razor" ]||[ $currentdevice == "razorg" ]||[ $currentdevice == "mantaray" ]; then
    echo "[O] OmniROM"
  else
    echo "[X] OmniROM not avaliable."
  fi
  if [ $currentdevice == "sojus" ]||[ $currentdevice == "sojuk" ]||[ $currentdevice == "sojua" ]||[ $currentdevice == "soju" ]||[ $currentdevice == "mysidspr" ]||[ $currentdevice == "mysid" ]||[ $currentdevice == "yakju" ]||[ $currentdevice == "takju" ]||[ $currentdevice == "occam" ]||[ $currentdevice == "hammerhead" ]||[ $currentdevice == "nakasi" ]||[ $currentdevice == "nakasig" ]||[ $currentdevice == "razor" ]||[ $currentdevice == "razorg" ]||[ $currentdevice == "mantaray" ]; then
    echo "[C] CyanogenMod"
  else
    echo "[X] CyanogenMod not avaliable."
  fi
  echo ""
  echo "[M] Return to main menu."
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    P|p) romselection="Paranoid-Android";;
    O|o) romselection="OmniROM";;
    C|c) romselection="CyanogenMod";;
    M|m) f_menu;;
    Q|q) clear; exit;;
    *) f_customrom;;
  esac

  clear
  echo "What kind of GApps package would you like?"
  echo ""
  echo "[1] Stock   (What is normally preinstalled on Nexus devices)"
  echo "[2] Full    (Most all of all of the apps avaliable)"
  echo "[3] Mini    (Only the common apps)"
  echo "[4] Micro   (Small number of applications)"
  echo "[5] Nano    (Play store + Google Search)"
  echo "[6] Pico    (The bare minimum)"
  echo ""
  echo "[M] Return to main menu."
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    1)
      gappstype="Stock"
      gappsurl="https://s.basketbuild.com/uploads/devs/TKruzze/Android%204.4.4%20GApps/Google%20Stock%20GApps/Older%20Versions/pa_gapps-stock-4.4.4-20141119-signed.zip";;
    2)
      gappstype="Full"
      gappsurl="https://s.basketbuild.com/uploads/devs/TKruzze/Android%204.4.4%20GApps/Full-Modular%20GApps/Older%20Versions/pa_gapps-modular-full-4.4.4-20141119-signed.zip";;
    3)
      gappstype="Mini"
      gappsurl="https://s.basketbuild.com/uploads/devs/TKruzze/Android%204.4.4%20GApps/Mini-Modular%20GApps/Older%20Versions/pa_gapps-modular-mini-4.4.4-20141119-signed.zip";;
    4)
      gappstype="Micro"
      gappsurl="https://s.basketbuild.com/uploads/devs/TKruzze/Android%204.4.4%20GApps/Micro-Modular%20GApps/Older%20Versions/pa_gapps-modular-micro-4.4.4-20141119-signed.zip";;
    5)
      gappstype="Nano"
      gappsurl="https://s.basketbuild.com/uploads/devs/TKruzze/Android%204.4.4%20GApps/Nano-Modular%20GApps/Older%20Versions/pa_gapps-modular-nano-4.4.4-20141119-signed.zip";;
    6)
      gappstype="Pico"
      gappsurl="https://s.basketbuild.com/uploads/devs/TKruzze/Android%204.4.4%20GApps/Pico-Modular%20GApps/Older%20Versions/pa_gapps-modular-pico-4.4.4-20141119-signed.zip";;
    M|m) f_menu;;
    Q|q) clear; exit;;
  esac

  currentday=`date +%d`
  ndays="1"
  day=`expr $currentday - $ndays`
  builddate=`date +%Y%m`"$day"

  case $romselection in
    Paranoid-Android)
      case $currentdevice in
        mysidspr) romurl="http://download.paranoidandroid.co/roms/toroplus/pa_toroplus-4.6-BETA6-20141103.zip";;
        mysid) romurl="http://download.paranoidandroid.co/roms/toro/pa_toro-4.6-BETA6-20141103.zip";;
        yakju) romurl="http://download.paranoidandroid.co/roms/maguro/pa_maguro-4.6-BETA6-20141103.zip";;
        takju) romurl="http://download.paranoidandroid.co/roms/maguro/pa_maguro-4.6-BETA6-20141103.zip";;
        occam) romurl="http://download.paranoidandroid.co/roms/mako/pa_mako-4.6-BETA6-20141103.zip";;
        hammerhead) romurl="http://download.paranoidandroid.co/roms/hammerhead/pa_hammerhead-4.6-BETA6-20141103.zip";;
        nakasi) romurl="http://download.paranoidandroid.co/roms/grouper/pa_grouper-4.6-BETA6-20141103.zip";;
        nakasig) romurl="http://download.paranoidandroid.co/roms/tilapia/pa_tilapia-4.6-BETA6-20141103.zip";;
        razor) romurl="http://download.paranoidandroid.co/roms/flo/pa_flo-4.6-BETA6-20141103.zip";;
        razorg) romurl="http://download.paranoidandroid.co/roms/deb/pa_deb-4.6-BETA6-20141103.zip";;
        mantaray) romurl="http://download.paranoidandroid.co/roms/manta/pa_manta-4.6-BETA6-20141103.zip";;
      esac;;
    OmniROM)
      case $currentdevice in
        mysidspr) romurl="http://dl.omnirom.org/toroplus/omni-4.4.4-$builddate-toroplus-NIGHTLY.zip";;
        mysid) romurl="http://dl.omnirom.org/toro/omni-4.4.4-$builddate-toro-NIGHTLY.zip";;
        yakju) romurl="http://dl.omnirom.org/maguro/omni-4.4.4-$builddate-maguro-NIGHTLY.zip";;
        takju) romurl="http://dl.omnirom.org/maguro/omni-4.4.4-$builddate-maguro-NIGHTLY.zip";;
        occam) romurl="http://dl.omnirom.org/mako/omni-4.4.4-$builddate-mako-NIGHTLY.zip";;
        hammerhead) romurl="http://dl.omnirom.org/hammerhead/omni-4.4.4-$builddate-hammerhead-NIGHTLY.zip";;
        nakasi) romurl="http://dl.omnirom.org/grouper/omni-4.4.4-$builddate-grouper-NIGHTLY.zip";;
        nakasig) romurl="http://dl.omnirom.org/tilapia/omni-4.4.4-$builddate-tilapia-NIGHTLY.zip";;
        razor) romurl="http://dl.omnirom.org/flo/omni-4.4.4-$builddate-flo-NIGHTLY.zip";;
        razorg) romurl="http://dl.omnirom.org/deb/omni-4.4.4-$builddate-deb-NIGHTLY.zip";;
        mantaray) romurl="http://dl.omnirom.org/manta/omni-4.4.4-$builddate-manta-NIGHTLY.zip";;
      esac;;
    CyanogenMod)
      case $currentdevice in
        sojus) romurl="http://download.cyanogenmod.org/get/jenkins/90440/cm-11-20141112-SNAPSHOT-M12-crespo.zip";;
        sojuk) romurl="http://download.cyanogenmod.org/get/jenkins/90440/cm-11-20141112-SNAPSHOT-M12-crespo.zip";;
        sojua) romurl="http://download.cyanogenmod.org/get/jenkins/90440/cm-11-20141112-SNAPSHOT-M12-crespo.zip";;
        soju) romurl="http://download.cyanogenmod.org/get/jenkins/90440/cm-11-20141112-SNAPSHOT-M12-crespo.zip";;
        mysidspr) romurl="http://download.cyanogenmod.org/get/jenkins/75251/cm-11-20140708-SNAPSHOT-M8-toroplus.zip";;
        mysid) romurl="http://download.cyanogenmod.org/get/jenkins/78509/cm-11-20140804-SNAPSHOT-M9-toro.zip";;
        yakju) romurl="http://download.cyanogenmod.org/get/jenkins/90777/cm-11-20141115-SNAPSHOT-M12-maguro.zip";;
        takju) romurl="http://download.cyanogenmod.org/get/jenkins/90777/cm-11-20141115-SNAPSHOT-M12-maguro.zip";;
        occam) romurl="http://download.cyanogenmod.org/get/jenkins/90767/cm-11-20141115-SNAPSHOT-M12-mako.zip";;
        hammerhead) romurl="http://download.cyanogenmod.org/get/jenkins/86435/cm-11-20141008-SNAPSHOT-M11-hammerhead.zip";;
        nakasi) romurl="http://download.cyanogenmod.org/get/jenkins/90453/cm-11-20141112-SNAPSHOT-M12-grouper.zip";;
        nakasig) romurl="http://download.cyanogenmod.org/get/jenkins/83804/cm-11-20140916-SNAPSHOT-M10-tilapia.zip";;
        razor) romurl="http://download.cyanogenmod.org/get/jenkins/90768/cm-11-20141115-SNAPSHOT-M12-flo.zip";;
        razorg) romurl="http://download.cyanogenmod.org/get/jenkins/90776/cm-11-20141115-SNAPSHOT-M12-deb.zip";;
        mantaray) romurl="http://download.cyanogenmod.org/get/jenkins/86455/cm-11-20141008-SNAPSHOT-M11-manta.zip";;
      esac;;
  esac

  clear
  echo "Downloading ROM."
  $wget -O $devicedir/$romselection-ROM.zip $romurl --progress=bar:force 2>&1 | wgetprogress
  clear
  echo "Downloaded ROM."

  clear
  echo "Downloading GApps."
  $wget -O $commondir/gapps/$gappstype-GApps.zip $gappsurl --progress=bar:force 2>&1 | wgetprogress
  clear
  echo "Downloaded GApps."

  clear
  echo "Downloading SuperSU."
  currentdevicetmp=$currentdevice
  currentdevice="supersu"
  export currentdevice
  $wget -O $scriptdir/autoroot-download.py 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/autoroot-download.py' --progress=bar:force 2>&1 | wgetprogress
  cd $commondir
  clear
  python $scriptdir/autoroot-download.py
  clear
  cd ~/
  currentdevice=$currentdevicetmp
  clear
  echo "Downloaded SuperSU."

  sleep 3

  clear
  echo "Please wait while the ROM is being installed."
  $adb reboot recovery
  sleep 20
  $adb push $devicedir/$romselection-ROM.zip /sdcard/tmp/rom.zip
  $adb push $commondir/gapps/$gappstype-GApps.zip /sdcard/tmp/gapps.zip
  $adb push $commondir/root.zip /sdcard/tmp/root.zip
  $adb shell "echo -e 'install /sdcard/tmp/rom.zip\ninstall /sdcard/tmp/gapps.zip\ninstall /sdcard/tmp/root.zip\nwipe cache\nwipe data\ncmd rm -rf /sdcard/tmp\nreboot\n' > /cache/recovery/openrecoveryscript"
  $adb reboot recovery
  clear
  echo "The device is now rebooting. Give it time to flash the new ROM. It will boot on its own."
  echo ""
  read -p "Press [Enter] to return to the main menu."
  f_menu
}

####################### Flashes a variety of files ###
f_flash(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo "Connected Device: $devicemake $devicemodel ($currentdevice) ($serialno)"
  echo "Android Version: $androidver ($androidbuild)"
  echo ""
  echo "[1] Flash zip in recovery (Requires TWRP)"
  echo "[2] Custom recovery (IMG)"
  echo "[3] Custom Kernel (IMG)"
  echo "[4] Custom Cache (IMG)"
  echo "[5] Custom System (IMG)"
  echo "[6] Custom Userdata (IMG)"
  echo ""
  echo "[M] Return to Main Menu."
  echo "[Q] Quit."
  echo ""
  read -p "Selection: " selection

  case $selection in
    1)
      clear
      echo "Either type the path or click and drag the file into this window that you want to flash."
      echo ""
      read -p "" ziptoflash
      clear
      echo "Please wait while the zip is copied and flashed. Your device will start nomally once finished."
      $adb reboot recovery
      $adb wait-for-device
      $adb push $ziptoflash /sdcard/tmp/ziptoflash.zip
      $adb shell "echo -e 'install /sdcard/tmp/ziptoflash.zip\ncmd rm -rf /sdcard/tmp\ncmd reboot\n' > /cache/recovery/openrecoveryscript"
      $adb reboot recovery
      clear
      echo "Flashing complete."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      clear
      f_flash;;
    2)
      clear
      echo "Would you like to permanently flash the file, or temporarily?"
      echo ""
      echo "[1] Premanently"
      echo "[2] Temporarily"
      echo ""
      read -p "Selection: " selection
      clear
      echo "Either type the path or click and drag the file into this window that you want to flash."
      echo ""
      read -p "" imgtoflash
      clear
      echo "Please wait while the image is flashed."
      $adb reboot bootloader

      case $selection in
        1) $fastboot flash recovery $imgtoflash;;
        2) $fastboot boot $imgtoflash;;
      esac

      clear
      echo "Flashing complete."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      clear
      f_flash;;
    3)
      clear
      echo "Would you like to permanently flash the file, or temporarily?"
      echo ""
      echo "[1] Premanently"
      echo "[2] Temporarily"
      echo ""
      read -p "Selection: " selection
      clear
      echo "Either type the path or click and drag the file into this window that you want to flash."
      echo ""
      read -p "" imgtoflash
      clear
      echo "Please wait while the image is flashed."
      $adb reboot bootloader

      case $selection in
        1) $fastboot flash boot $imgtoflash;;
        2) $fastboot boot $imgtoflash;;
      esac

      clear
      echo "Flashing complete."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      clear
      f_flash;;
    4)
      clear
      echo "Either type the path or click and drag the file into this window that you want to flash."
      echo ""
      read -p "" imgtoflash
      clear
      echo "Please wait while the image is flashed."
      $adb reboot bootloader
      $fastboot flash cache $imgtoflash
      clear
      echo "Flashing complete."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      clear
      f_flash;;
    5)
      clear
      echo "Either type the path or click and drag the file into this window that you want to flash."
      echo ""
      read -p "" imgtoflash
      clear
      echo "Please wait while the image is flashed."
      $adb reboot bootloader
      $fastboot flash system $imgtoflash
      clear
      echo "Flashing complete."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      clear
      f_flash;;
    6)
      clear
      echo "Either type the path or click and drag the file into this window that you want to flash."
      echo ""
      read -p "" imgtoflash
      clear
      echo "Please wait while the image is flashed."
      $adb reboot bootloader
      $fastboot flash userdata $imgtoflash
      clear
      echo "Flashing complete."
      echo ""
      read -p "Press [Enter] to return to the main menu." null
      clear
      f_flash;;
    M|m) f_menu;;
    Q|q) clear; exit;;
  esac

}

########################## Restore device to stock ###
f_restore(){
  clear
  echo "Are you sure you want to restore your device? This will erase ALL data!"
  echo ""
  echo "[Y]es, erase everything and restore to stock."
  echo "[N]o! I want to keep everything and return to the menu!"
  echo ""
  read -p "Selection: " selection

  case $selection in
    Y|y) clear; echo "Continuing with erase and restore.";;
    N|n) f_menu;;
  esac

  case $currentdevice in
    sojus)
      restoredir="sojus-jro03r"
      url="https://dl.google.com/dl/android/aosp/sojus-jro03r-factory-59a247f5.tgz";;
    sojuk)
      restoredir="sojuk-jro03e"
      url="https://dl.google.com/dl/android/aosp/sojuk-jro03e-factory-93a21b70.tgz";;
    sojua)
      restoredir="sojua-jzo54k"
      url="https://dl.google.com/dl/android/aosp/sojua-jzo54k-factory-1121b619.tgz";;
    soju)
      restoredir="soju-jzo54k"
      url="https://dl.google.com/dl/android/aosp/soju-jzo54k-factory-36602333.tgz";;
    mysidspr)
      restoredir="mysidspr-ga02"
      url="https://dl.google.com/dl/android/aosp/mysidspr-ga02-factory.tgz";;
    mysid)
      restoredir="mysid-jdq39"
      url="https://dl.google.com/dl/android/aosp/mysid-jdq39-factory-e365033f.tgz";;
    yakju)
      restoredir="yakju-jwr66y"
      url="https://dl.google.com/dl/android/aosp/yakju-jwr66y-factory-09207065.tgz";;
    takju)
      restoredir="takju-jwr66y"
      url="https://dl.google.com/dl/android/aosp/takju-jwr66y-factory-5104ab1d.tgz";;
    occam)
      restoredir="occam-lrx21t"
      url="https://dl.google.com/dl/android/aosp/occam-lrx21t-factory-51cee750.tgz";;
    hammerhead)
      restoredir="hammerhead-lrx21o"
      url="https://dl.google.com/dl/android/aosp/hammerhead-lrx21o-factory-01315e08.tgz";;
    shamu)
      restoredir="shamu-lrx21o"
      url="https://dl.google.com/dl/android/aosp/shamu-lrx21o-factory-e028f5ea.tgz";;
    nakasi)
      restoredir="nakasi-lrx21p"
      url="https://dl.google.com/dl/android/aosp/nakasi-lrx21p-factory-93daa4d3.tgz";;
    nakasig)
      restoredir="nakasig-ktu84p"
      url="https://dl.google.com/dl/android/aosp/nakasig-ktu84p-factory-0cc2750b.tgz";;
    razor)
      restoredir="razor-lrx21p"
      url="https://dl.google.com/dl/android/aosp/razor-lrx21p-factory-ba55c6ab.tgz";;
    razorg)
      restoredir="razorg-ktu84p"
      url="https://dl.google.com/dl/android/aosp/razorg-ktu84p-factory-f21762aa.tgz";;
    mantaray)
      restoredir="mantaray-lrx21p"
      url="https://dl.google.com/dl/android/aosp/mantaray-lrx21p-factory-ad2499ea.tgz";;
    volantis)
      restoredir="volantis-lrx21r"
      url="https://dl.google.com/dl/android/aosp/volantis-lrx21r-factory-ac87eba2.tgz";;
    tungsten)
      restoredir="tungsten-ian67k"
      url="https://dl.google.com/dl/android/aosp/tungsten-ian67k-factory-468d9865.tgz";;
    fugu)
      restoredir="fugu-lrx21v"
      url="https://dl.google.com/dl/android/aosp/fugu-lrx21v-factory-64050f47.tgz";;
  esac

  echo "Downloading restore image."
  $wget -O $devicedir/restore.tgz $url --progress=bar:force 2>&1 | wgetprogress
  clear
  cd $devicedir
  echo "Unpacking restore image."
  gunzip -c restore.tgz | tar xopf -
  cd $devicedir/$restoredir
  clear
  echo "Rebooting into the bootloader."
  $adb reboot bootloader
  clear
  echo "Flashing restore image."
  sed 's/fastboot/$fastboot/g' ./flash-all.sh
  clear
  sh ./flash-all.sh
  clear

  echo "Did the flashing complete successfully? (The tablet should be rebooting.)"
  echo ""
  echo "[Y]es, the restore was successful."
  echo "[N]o, the flash was unsuccessful. (This is an issue with google for the Nexus 6 and 9.)"
  echo ""
  read -p "Selection: " selection

  case $selection in
    Y|y) clear;;
    N|n)
      unzip image-$restoredir.zip
      $fastboot format userdata
      clear
      $fastboot format cache
      clear
      if [ -e ./boot.img ]; then
        $fastboot flash boot boot.img
      else
        echo "boot.img not found. Skipping."
      fi
      clear
      if [ -e ./recovery.img ]; then
        $fastboot flash recovery recovery.img
      else
        echo "recovery.img not found. Skipping."
      fi
      clear
      if [ -e ./system.img ]; then
        $fastboot flash system system.img
      else
        echo "system.img not found. Skipping."
      fi
      clear
      if [ -e ./userdata.img ]; then
        $fastboot flash userdata userdata.img
      else
        echo "userdata.img not found. Skipping."
      fi
      clear
      if [ -e ./cache.img ]; then
        $fastboot flash cache cache.img
      else
        echo "cache.img not found. Skipping."
      fi
      clear
      if [ -e ./vendor.img ]; then
        $fastboot flash vendor vendor.img
      else
        echo "vendor.img not found. Skipping."
      fi
      $fastboot reboot;;
  esac

  rm -rf $restoredir
  cd ~/
  clear
  f_autodevice
}

######################################## ADB tools ###
f_tools(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo "Connected Device: $devicemake $devicemodel ($currentdevice) ($serialno)"
  echo "Android Version: $androidver ($androidbuild)"
  echo ""
  echo "[1] Pull File from Device"
  echo "[2] Push File to Device"
  echo "[3] Install APK"
  echo "[4] Start ADB Shell"
  echo "[5] Back Up device and copy to computer       (Requires TWRP)"
  echo "[6] Restore device from backup on computer    (Requires TWRP)"
  if [ "$currentdevice" == "volantis" ]||[ "$currentdevice" == "shamu" ]; then
    echo "[7] Decrypt Device                            (Requires TWRP)"
  fi
  echo ""
  echo "[M] Return to Previous Menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    1)
      clear
      echo "What file do you want to pull?"
      read -p "" sourcedir
      clear
      echo "Where would you like the file to be put?"
      read -p "" destdir
      clear
      echo "Pulling File."
      $adb pull $sourcedir $destdir
      echo ""
      echo "Pull Complete."
      read -p "Press [Enter] to return to the main menu." null
      f_tools;;
    2)
      clear
      echo "What file do you want to transfer?"
      read -p "" sourcedir
      clear
      echo "Where would you like the file to be put?"
      read -p "" destdir
      clear
      echo "Pushing File."
      $adb pull $sourcedir $destdir
      echo ""
      echo "Push Complete."
      read -p "Press [Enter] to return to the main menu." null
      f_tools;;
    3)
      clear
      echo "What APK do you want to install? (Input directory or drag-and drop)"
      read -p "" apkdir
      clear
      echo "Installing APK"
      $adb install $apkdir
      echo ""
      echo "Install complete"
      read -p "Press [Enter] to return to the main menu."
      f_tools;;
    4)
      clear
      echo "Starting ADB Shell. Type 'exit' to return to the menu."
      $adb shell
      f_tools;;
    5)
      clear
      echo "What partitions do you want to back up? Type any that apply."
      echo ""
      echo "S = System"
      echo "D = Data"
      echo "C = Cache"
      echo "R = Recovery"
      echo "B = Boot"
      echo "A = Android secure"
      echo "E = SD-Ext"
      echo ""
      echo "O = Use Compression"
      echo "M = Don't create MD5"
      echo ""
      read -p "Back up: " partitions
      clear
      partitions=$(echo $partitions | tr 'a-z' 'A-Z')
      partitions=$(echo $partitions | tr -d ' ')
      clear
      echo "What do you want the backup to be named?"
      echo ""
      read -p "Name: " backupname
      clear
      echo "Starting backup. Please wait."
      $adb reboot recovery
      sleep 20
      $adb shell "echo -e 'backup $partitions $backupname\nreboot recovery\n' > /cache/recovery/openrecoveryscript"
      $adb reboot recovery
      clear
      read -p "Press [Enter] when the backup is complete and the device is back in recovery." null
      clear
      echo "Pulling Backup off the device"
      echo ""
      $adb pull /sdcard/TWRP/BACKUPS/$serialno/$backupname/ $devicedir/backups/$serialno/$backupname
      $adb shell rm -rf /sdcard/TWRP/BACKUPS/$serialno/$backupname
      $adb reboot
      clear
      echo "Backup complete! Backup located at:"
      echo "$devicedir/Backups/$backupname"
      echo ""
      read -p "Press [Enter] To return to the main menu." null
      f_twrptools;;
    6)
      clear
      ls $devicedir/backups/$serialno
      echo ""
      echo "Enter the name of the backup that you want to restore."
      echo ""
      read -p "Backup: " backupname
      if [ -d $devicedir/backups/$serialno/$backupname ]; then
        clear
      else
        clear
        echo "That backup doesn't exist! Returning to main menu."
        sleep 3
        f_twrptools
      fi

      clear
      echo "What partitions do you want to restore from the backup? Type any that apply."
      echo ""
      echo "S = System"
      echo "D = Data"
      echo "C = Cache"
      echo "R = Recovery"
      echo "B = Boot"
      echo "A = Android secure"
      echo "E = SD-Ext"
      echo ""
      read -p "Back up: " partitions
      clear
      partitions=$(echo $partitions | tr 'a-z' 'A-Z')
      partitions=$(echo $partitions | tr -d ' ')

      $adb reboot recovery
      sleep 20

      clear
      echo "Pushing backup to device."
      echo ""
      $adb shell "echo -e 'restore $backupname $partitions\nreboot recovery\n' > /cache/recovery/openrecoveryscript"
      $adb push $devicedir/backups/$serialno/$backupname /sdcard/TWRP/BACKUPS/$serialno/$backupname
      $adb reboot recovery
      clear
      read -p "Press [Enter] when the restore is complete and the device is back in recovery." null
      clear
      $adb shell rm -rf /sdcard/TWRP/BACKUPS/$serialno/$backupname
      $adb reboot
      clear
      echo "Restore complete."
      echo ""
      read -p "Press [Enter] to return to the main menu."
      clear
      f_twrptools;;
    7)
      clear
      echo "This utility will decrypt your device to make it run faster. It factory resets the device."
      echo "Make sure any data you want to keep is backed up!"
      echo ""
      echo "[Y]es, erase everything and decrypt the device."
      echo "[N]o, I want to keep it encrypted and return to the menu."
      echo ""
      read -p "Selection: " selection

      case $selection in
        Y|y) clear; echo "Continuing with erase and decrypt.";;
        N|n) f_menu;;
      esac

      case $currentdevice in
        volantis) url="https://github.com/photonicgeek/Nexus-Multitool/raw/master/Files/Devices/volantis/boot_noforceencrypt.img";;
        shamu) url="https://github.com/photonicgeek/Nexus-Multitool/raw/master/Files/Devices/shamu/boot_noforceencrypt.img";;
      esac

      clear
      echo "Downloading patched kernel."
      $wget -O $devicedir/noencrypt-boot.img $url --progress=bar:force 2>&1 | wgetprogress

      clear
      echo "Wiping device and patching kernel. It will reboot several times."
      $adb reboot bootloader
      $fastboot flash boot $devicedir/noencrypt-boot.img
      $fastboot reboot
      $adb wait-for-device
      $adb reboot recovery
      sleep 10
      $adb shell "echo -e 'wipe data\nwipe cache\nreboot\n' > /cache/recovery/openrecoveryscript"
      $adb reboot recovery
      clear
      echo "Your device is now decrypted!"
      echo ""
      read -p "Press [Enter] to return to the main menu."
      f_menu;;
    M|m) f_menu;;
    Q|q) clear; exit;;
  esac
}

############################# Options and settings ###
f_options(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo "Connected Device: $devicemake $devicemodel ($currentdevice) ($serialno)"
  echo "Android Version: $androidver ($androidbuild)"
  echo ""
  echo "[1] Update Nexus Multitool"
  echo "[2] Delete All Nexus Multitool Files and Exit"
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    1) f_update; f_options;;
    2) f_delete; exit;;
    R|r) f_menu;;
    Q|q) clear ; exit;;
    *) f_options;;
  esac
}

############################### Update this script ###
f_update(){
  unamestr=`uname`
  case $unamestr in
  Darwin)
    self=$BASH_SOURCE
    $wget -O /tmp/Nexus-Multitool.sh 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/Nexus-Multitool.sh' --progress=bar:force 2>&1 | wgetprogress
    clear
    rm -rf $self
    mv /tmp/Nexus-Multitool.sh $self
    rm -rf /tmp/Nexus-Multitool.sh
    chmod 755 $self
    exec $self;;
  *)
    self=$(readlink -f $0)
    $wget -O $self 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/Nexus-Multitool.sh' --progress=bar:force 2>&1 | wgetprogress
    clear
    exec $self;;
  esac
}

##################################### Delete files ###
f_delete(){
  clear
  echo "Are you sure you would like to delete all Nexus Multitool files?"
  echo ""
  echo "[Y] Yes, delete all of the files."
  echo "[N] No, bring me back to the main menu."
  echo ""
  read -p "Selection: " selection

  case $selection in
    Y|y)
      clear
      echo "Deleting all files."
      rm -rf $maindir
      sleep 2
      clear
      echo "Files deleted."
      echo ""
      read -p "Press [Enter] to exit the script." null
      clear
      exit;;
    N|n)
      f_menu;;
    *)
      f_delete;;
  esac
}



######################## INTERNAL SCRIPT UTILITIES ###
f_internal(){
  wgetprogress (){
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
      if $flag
        then
        printf '%c' "$c"
      else
        if [[ $c != $cr && $c != $nl ]]
          then
          count=0
        else
          ((count++))
          if ((count > 1))
            then
            flag=true
          fi
        fi
      fi
    done
  }
}

################## What actually starts the script ###
f_internal
f_setup
f_menu

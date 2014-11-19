#!/bin/bash

#Version
nmtver="0.1"

f_deviceselect(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo ""
  echo "Please Select your device:"
  echo ""
  echo "[1]  Nexus S (Various)                      [10]  Nexus Q (Tungsten)"
  echo "[2]  Galaxy Nexus (Various)                 [11]  Nexus Player (Fugu)"
  echo "[3]  Nexus 4 (Occam)"
  echo "[4]  Nexus 5 (Hammerhead)"
  echo "[#]  Nexus 6 (Shamu)"
  echo ""
  echo "[6]  Nexus 7 2012 (Nakasi/Nakasig)"
  echo "[7]  Nexus 7 2013 (Razor/Razorg)"
  echo "[8]  Nexus 10 (Mantaray)"
  echo "[9]  Nexus 9 (Volantis)"
  echo ""
  #echo "[S] Settings and Options"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " deviceselection

  case $deviceselection in
    1) f_nexussselect; f_setup; f_menu;;
    2) f_gnexselect; f_setup; f_menu;;
    3) currentdevice=occam; f_setup; f_menu;;
    4) currentdevice=hammerhead; f_setup; f_menu;;
    5) currentdevice=shamu; f_setup; f_menu;;
    6) f_n712select; f_setup; f_menu;;
    7) f_n713select; f_setup; f_menu;;
    8) currentdevice=mantaray; f_setup; f_menu;;
    9) currentdevice=volantis; f_setup; f_menu;;
    10) currentdevice=tungsten; f_setup; f_menu;;
    11) currentdevice=fugu; f_setup; f_menu;;
    S|s) f_setup; f_options; f_menu;;
    Q|q) clear; exit;;
  esac
}

f_nexussselect(){
  clear
  echo "Nexus Multitool"
  echo ""
  echo "Which Nexus S device?"
  echo ""
  echo "[1] 4G, d720"
  echo "[2] Korea version, m200"
  echo "[3] 850MHz version, i9020a"
  echo "[4] Worldwide version, i9020t and i9023"
  echo ""
  read -p "Selection: " nexussselection

  case $nexussselection in
    1) currentdevice=sojus;;
    2) currentdevice=sojuk;;
    3) currentdevice=sojua;;
    4) currentdevice=soju;;
    *) f_nexussselect;;
  esac
}

f_gnexselect(){
  clear
  echo "Nexus Multitool"
  echo ""
  echo "Which Galaxy Nexus device?"
  echo ""
  echo "[1] Sprint CDMA/LTE"
  echo "[2] Verizon CDMA/LTE"
  echo "[3] GSM/HSPA+"
  echo "[4] GSM/HSPA+ with Google Wallet"
  echo ""
  read -p "Selection: " nexussselection

  case $nexussselection in
    1) currentdevice=toroplus;;
    2) currentdevice=toro;;
    3) currentdevice=maguro;;
    4) currentdevice=maguro-gw;;
    *) f_nexussselect;;
  esac
}

f_n712select(){
  clear
  echo "Nexus Multitool"
  echo ""
  echo "Which Nexus 7?"
  echo ""
  echo "[1] Wifi Only"
  echo "[2] Wifi + Cellular"
  echo ""
  read -p "Selection: " nexussselection

  case $nexussselection in
    1) currentdevice=nakasi;;
    2) currentdevice=nakasig;;
    *) f_nexussselect;;
  esac
}

f_n713select(){
  clear
  echo "Nexus Multitool"
  echo ""
  echo "Which Nexus 7?"
  echo ""
  echo "[1] Wifi Only"
  echo "[2] Wifi + LTE"
  echo ""
  read -p "Selection: " nexussselection

  case $nexussselection in
    1) currentdevice=razor;;
    2) currentdevice=razorg;;
    *) f_nexussselect;;
  esac
}

f_setup(){
  clear
  maindir=~/Nexus-Multitool
  devicedir=$maindir/$currentdevice
  commondir=$maindir/all
  scriptdir=$maindir/scripts
  mkdir -p $devicedir
  mkdir -p $commondir
  mkdir -p $scriptdir
  clear

  unamestr=`uname`
  cd $maindir
  case $unamestr in
  Darwin)
    if [ -d $commondir/adb-tools ]; then
      clear
    else
      echo "Downloading ADB and Fastboot (Developer Tools required)"
      echo ""
      mkdir -p $commondir/adb-tools
      cd $commondir
      git clone git://git.kali.org/packages/google-nexus-tools
      clear
      echo "Setting Up Tools"
      cd $commondir
      mkdir -p $commondir/adb-tools
      mv ./google-nexus-tools/bin/* ./adb-tools/
      rm -rf ./bin
      rm -rf ./debian
      rm -rf install.sh
      rm -rf license.txt
      rm -rf README.md
      rm -rf udev.txt
      rm -rf uninstall.sh
      cd ~/
    fi
    adb=$commondir/adb-tools/mac-adb
    fastboot=$commondir/adb-tools/mac-fastboot;;
  *)
    if [ -d $commondir/adb-tools ]; then
      clear
    else
      echo "Installing cURL (Password may be required)"
      echo ""
      sudo apt-get -qq update && sudo apt-get -qq -y install curl
      clear
      echo "Downloading ADB and Fastboot (Developer Tools required)"
      echo ""
      mkdir -p $commondir/adb-tools
      cd $commondir
      git clone git://git.kali.org/packages/google-nexus-tools
      clear
      echo "Setting Up Tools"
      cd $commondir
      mkdir -p $commondir/adb-tools
      mv ./google-nexus-tools/bin/* ./adb-tools/
      rm -rf ./bin
      rm -rf ./debian
      rm -rf install.sh
      rm -rf license.txt
      rm -rf README.md
      rm -rf udev.txt
      rm -rf uninstall.sh
      cd ~/
    fi
    adb=$commondir/adb-tools/linux-i386-adb
    fastboot=$commondir/adb-tools/linux-i386-fastboot;;
  esac

  rm -rf $commondir/google-nexus-tools
  chmod 755 $adb
  chmod 755 $fastboot
  clear
}

f_menu(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo ""
  echo "[1] Unlock bootloader (USE THIS BEFORE ANY OTHER OPTION)"
  echo "[2] Root"
  echo "[3] Install TWRP Recovery"
  echo "[4] Restore to stock"
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " menuselection

  case $menuselection in
    1) f_unlock; f_menu;;
    2) f_root; f_menu;;
    3) f_twrp; f_menu;;
    4) f_restore;;
    R|r) f_deviceselect;;
    Q|q) clear; exit;;
    *) f_menu;;
  esac
}

f_unlock(){
  clear
  case $currentdevice in
    flounder|shamu)
      $adb start-server
      clear
      echo "Start up your device like normal and open the settings menu and scroll down to 'About Device'"
      echo "Tap on 'Build Number' 7 times and return to the main settings menu. Select 'Developer Options'"
      echo "and enable the box that says 'Enable OEM unlock' and 'USB debugging'. In the RSA Autorization"
      echo "box that pops up, check the box that says 'Always allow from this computer' and tap 'OK'"
      echo ""
      read -p "Press [Enter] to continue." null
      clear
      echo "Waiting for device..."
      $adb wait-for-device
      clear;;
    *)
      $adb start-server
      echo "Start up your device like normal and open the settings menu and scroll down to 'About Device'"
      echo "Tap on 'Build Number' 7 times and return to the main settings menu. Select 'Developer Options'"
      echo "and enable the box that says 'USB debugging'. In the RSA Autorization box that pops up, check"
      echo "the box that says 'Always allow from this computer' and tap 'OK'"
      echo ""
      echo "Waiting for device... If you get stuck here, something went wrong."
      $adb wait-for-device
      clear;;
  esac
  echo "THIS NEXT STEP WILL ERASE YOUR DEVICE'S DATA."
  echo "Make sure taht anything you wish to keep is backed"
  echo "up and taken off of the device!"
  echo ""
  read -p "Press [Enter] to continue." null
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
  read -p "Press [Enter] to return to the menu" null
}

f_root(){
  clear
  case $currentdevice in
    mysidspr-toroplus|mysid-toro|yakju-maguro|takju-maguro|mako|hammerhead|grouper|tilapia|flo|deb|manta|flounder)
      echo "Boot into your device's OS like normal"
      $adb wait-for-device
      $adb reboot bootloader
      sleep 15
      clear
      echo "Downloading files to root device..."
      cd $devicedir
      export currentdevice
      curl -o $scriptdir/autoroot-download.py 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/autoroot-download.py' --progress-bar
      python $scriptdir/autoroot-download.py
      clear
      echo "Download Complete."
      sleep 1
      mkdir -p $devicedir/root
      cd $devicedir/root
      unzip $devicedir/root.zip
      clear
      echo "Rooting your device. This may take a minute..."
      case $currentdevice in
        mysidspr-toroplus) $fastboot boot $devicedir/root/image/CF-Auto-Root-toroplus-mysidspr-nexus7.img;;
        mysid-toro) $fastboot boot $devicedir/root/image/CF-Auto-Root-toro-mysid-nexus7.img;;
        yakju-maguro) $fastboot boot $devicedir/root/image/CF-Auto-Root-maguro-yakju-nexus7.img;;
        takju-maguro) $fastboot boot $devicedir/root/image/CF-Auto-Root-maguro-takju-nexus7.img;;
        mako) $fastboot boot $devicedir/root/image/CF-Auto-Root-mako-occam-nexus7.img;;
        hammerhead) $fastboot boot $devicedir/root/image/CF-Auto-Root-hammerhead-hammerhead-nexus7.img;;
        grouper) $fastboot boot $devicedir/root/image/CF-Auto-Root-grouper-nakasi-nexus7.img;;
        tilapia) $fastboot boot $devicedir/root/image/CF-Auto-Root-tilapia-nakasig-nexus7.img;;
        flo) $fastboot boot $devicedir/root/image/CF-Auto-Root-flo-razor-nexus7.img;;
        deb) $fastboot boot $devicedir/root/image/CF-Auto-Root-deb-razorg-nexus7.img;;
        manta) $fastboot boot $devicedir/root/image/CF-Auto-Root-manta-mantaray-nexus7.img;;
        flounder) $fastboot boot $devicedir/root/image/CF-Auto-Root-flounder-volantis-nexus7.img;;
      esac
      echo ""
      read -p "Press [Enter] to return to the menu." null
      rm -rf $devicedir/root;;
    *)
      echo "The root method for this device is still undergoing development."
      echo ""
      read -p "Press [Enter] to return to the menu." null;;
  esac
}

f_twrp(){
  clear
  case $currentdevice in
    mysidspr-toroplus) url="http://techerrata.com/get/twrp2/toroplus/openrecovery-twrp-2.8.1.0-toroplus.img";;
    mysid-toro) url="http://techerrata.com/get/twrp2/toro/openrecovery-twrp-2.8.1.0-toro.img";;
    yakju-maguro) url="http://techerrata.com/get/twrp2/maguro/openrecovery-twrp-2.8.1.0-maguro.img";;
    takju-maguro) url="http://techerrata.com/get/twrp2/maguro/openrecovery-twrp-2.8.1.0-maguro.img";;
    mako) url="http://techerrata.com/get/twrp2/mako/openrecovery-twrp-2.8.1.0-mako.img";;
    hammerhead) url="http://techerrata.com/get/twrp2/hammerhead/openrecovery-twrp-2.8.1.0-hammerhead.img";;
    grouper) url="http://techerrata.com/get/twrp2/grouper/openrecovery-twrp-2.8.1.0-grouper.img";;
    tilapia) url="http://techerrata.com/get/twrp2/tilapia/openrecovery-twrp-2.8.1.0-tilapia.img";;
    flo) url="http://techerrata.com/get/twrp2/flo/openrecovery-twrp-2.8.1.0-flo.img";;
    deb) url="http://techerrata.com/get/twrp2/deb/openrecovery-twrp-2.8.1.0-deb.img";;
    manta) url="http://techerrata.com/get/twrp2/manta/openrecovery-twrp-2.8.1.0-manta.img";;
    flounder) url="http://techerrata.com/get/twrp2/volantis/openrecovery-twrp-2.8.2.1-volantis.img";;
    *)
      echo "The recovery install method for this device is still undergoing development."
      echo ""
      read -p "Press [Enter] to return to the menu." null
      f_menu;;
  esac
  echo "Downloading TWRP"
  curl -o $devicedir/$currentdevice-twrp.img $url --progress-bar
  clear
  echo "Boot into your device's OS like normal"
  $adb wait-for-device
  clear
  echo "Rebooting into the bootloader"
  $adb reboot bootloader
  sleep 15
  $fastboot flash recovery $devicedir/$currentdevice-twrp.img
  $fastboot reboot
  clear
  echo "TWRP install complete. Your device is now rebooting."
  echo ""
  read -p "Press [Enter] to return to the menu." null
  f_menu
}

f_restore(){
  clear
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
    toroplus)
      restoredir="mysidspr-ga02"
      url="https://dl.google.com/dl/android/aosp/mysidspr-ga02-factory.tgz";;
    toro)
      restoredir="mysid-jdq39"
      url="https://dl.google.com/dl/android/aosp/mysid-jdq39-factory-e365033f.tgz";;
    maguro)
      restoredir="yakju-jwr66y"
      url="https://dl.google.com/dl/android/aosp/yakju-jwr66y-factory-09207065.tgz";;
    maguro-gw)
      restoredir="takju-jwr66y"
      url="https://dl.google.com/dl/android/aosp/takju-jwr66y-factory-5104ab1d.tgz";;
    occam)
      restoredir="occam-lrx21t"
      url="https://dl.google.com/dl/android/aosp/occam-lrx21t-factory-51cee750.tgz";;
    hammerhead)
      restoredir="hammerhead-lrx21o"
      url="https://dl.google.com/dl/android/aosp/hammerhead-lrx21o-factory-01315e08.tgz";;
    #shamu) url="";;
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
    *)
      echo "The recovery install method for this device is still undergoing development."
      echo ""
      read -p "Press [Enter] to return to the menu." null
      f_menu;;
  esac

  echo "Downloading restore image."
  curl -o $devicedir/restore.tgz $url --progress-bar
  clear
  echo "Reboot your device to the bootloader."
  echo ""
  read -p "Press [Enter] to continue." null
  clear
  cd $devicedir
  echo "Unpacking restore image."
  gunzip -c restore.tgz | tar xopf -
  cd $devicedir/$restoredir
  clear
  echo "Flashing restore image."
  sed 's/fastboot/$fastboot/g' ./flash-all.sh
  sh ./flash-all.sh
  clear
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

  $fastboot reboot
  rm -rf $restoredir
  cd ~/
  clear
  echo "Flashing complete."
  echo ""
  read -p "Press [Enter] to return to the menu" null
  f_menu
}

f_options(){
  clear
  echo "Nexus Multitool - Version $nmtver"
  echo ""
  echo "[1] Update Nexus Multitool"
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " selection

  case $selection in
    1) f_update; f_options;;
    R|r) f_deviceselect;;
    Q|q) clear ; exit;;
    *) f_options;;
  esac
}

f_update(){
  unamestr=`uname`
  case $unamestr in
  Darwin)
    self=$BASH_SOURCE
    curl -o /tmp/NetHunter-Installer.sh 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/Nexus-Multitool.sh'  --progress-bar
    clear
    rm -rf $self
    mv /tmp/kfu.sh $self
    rm -rf /tmp/kfu.sh
    chmod 755 $self
    exec $self;;
  *)
    self=$(readlink -f $0)
    curl -L -o $self 'https://raw.githubusercontent.com/photonicgeek/Nexus-Multitool/master/Nexus-Multitool.sh' --progress-bar
    clear
    exec $self;;
  esac
}

f_deviceselect

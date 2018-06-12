#!/bin/sh

source /etc/preinit
script_init

# Kill it! Kill it with fire!
pkill -KILL clover-mcp

#Clear cache and inodes for good measure...
echo 3 > /proc/sys/vm/drop_caches

dd if=/dev/zero of=/dev/fb0 #Clear FB just in case...

WorkingDir=$(pwd)
GameName=$(echo $WorkingDir | awk -F/ '{print $NF}')
ok=0

if [ -f "/usr/share/games/$GameName/$GameName.desktop" ]; then
	WOLFTrueDir=$(grep /usr/share/games/$GameName/$GameName.desktop -e 'Exec=' | awk '{print $2}' | sed 's/\([/\t]\+[^/\t]*\)\{1\}$//')
	WOLFPortableFiles="$WOLFTrueDir/WOLF_3D_files"
	ok=1
fi

if [ "$ok" == 1 ]; then
	decodepng "$WOLFTrueDir/Hakchi_WOLF_assets/wolfsplash-min.png" > /dev/fb0;

	#Load in the extra libraries required to run on SNESC
	[ ! -L $WOLFTrueDir/lib/libSDL2-2.0.so.0 ] && ln -sf "/usr/lib/libSDL2.so" "$WOLFTrueDir/lib/libSDL2-2.0.so.0"

	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WOLFTrueDir/lib
	export LD_LIBRARY_PATH
	
	#Change the HOME environment variable for running on the mini...
	HOME="$WOLFTrueDir/WOLF_3D_files"
	export HOME
	
	chmod +x $WOLFTrueDir/WOLF_3D_files/wolf3d
	
	cd $WOLFTrueDir/WOLF_3D_files/

	$WOLFTrueDir/WOLF_3D_files/ldd $WOLFTrueDir/WOLF_3D_files/wolf3d &> $WOLFTrueDir/wolf3dtest_ldd.log
	
	$WOLFTrueDir/WOLF_3D_files/wolf3d &> $WOLFTrueDir/wolf3dtest.log
	
	#Clear cache and inodes for good measure...
	echo 3 > /proc/sys/vm/drop_caches	
else
	decodepng "$WOLFTrueDir/Hakchi_WOLF_assets/wolferror_files-min.png" > /dev/fb0;
	sleep 5
fi

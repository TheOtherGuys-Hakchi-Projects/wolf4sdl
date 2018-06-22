#!/bin/sh

source /etc/preinit
script_init

# Kill it! Kill it with fire! (not in this case...)
# pkill -KILL clover-mcp

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

if [ ! -f "$WOLFPortableFiles/gamemaps.wl6" ]; then
  ok=0
fi

if [ "$ok" == 1 ]; then
	decodepng "$WOLFTrueDir/Hakchi_WOLF_assets/wolfsplash-min.png" > /dev/fb0;

	#Load in the extra libraries required to run on SNESC
	#No longer required as SDL2 lib on console is crap and requires a rebuilt one. But just in case...
	#[ ! -L $WOLFTrueDir/lib/libSDL2-2.0.so.0 ] && ln -sf "$WOLFTrueDir/lib/libSDL2.so" "$WOLFTrueDir/lib/libSDL2-2.0.so.0"

	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WOLFTrueDir/lib
	export LD_LIBRARY_PATH
	
	#Change the HOME environment variable for running on the mini...
	HOME="$WOLFTrueDir/WOLF_3D_files"
	export HOME

	#Clean down the volatile Wolf3D memory and reload it
	tmppath="/tmp/wolf3d"
	rm -rf "$tmppath"
	mkdir -p "$tmppath"
	cp $WOLFTrueDir/WOLF_3D_files/*.wl6 $tmppath
	
	chmod +x $WOLFTrueDir/WOLF_3D_files/wolf3d
	
	cd $WOLFTrueDir/WOLF_3D_files/
	
	$WOLFTrueDir/WOLF_3D_files/wolf3d --bits 32 &> $WOLFTrueDir/wolf3d.log
	
	#Clear cache and inodes for good measure...
	echo 3 > /proc/sys/vm/drop_caches	
	
	sleep 1
else
	decodepng "$WOLFTrueDir/Hakchi_WOLF_assets/wolferror_files-min.png" > /dev/fb0;
	sleep 5
fi

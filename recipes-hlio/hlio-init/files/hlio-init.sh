#!/bin/bash
# SIANA Systems  2022
# Based on:
# Bootchart logger script
# Ziga Mahkovec  <ziga.mahkovec@klika.si>
# Michael Meeks  <michael.meeks@novell.com>

#Path of executable
PATHDIR=/usr/bin 
#Path of SPLASH file
PATHSPLASHDIR=/usr/share/psplash
#Path of backup SPLASH file
PATHBACKDIR=/usr/share/psplash


#There can be multiples image files in each directory, the priority is: first look for jpg, then look for png
#In case there is no files, the program is redirected to be use with text files in order to show red color of error
#It is a must to have at least one image file in each directory

#0: not found
#1:JPG
#2:PNG


STR=0;
STRBACK=0;

#look for SPLASH file

if [[  -n $(find $PATHSPLASHDIR/  -name "*.jpg" -maxdepth 1 ) ]] ; then		
		STR='1';	
else
	if [[ -n $(find $PATHSPLASHDIR/  -name "*.png" -maxdepth 1) ]]; then
		STR='2';				
	else
		STR='0';			
	fi		
fi

#look for backup file
if [[  -n $(find $PATHBACKDIR/ -name "*.jpg"  -maxdepth 1) ]] ; then		
		STRBACK='1';						
else
	if [[ -n $(find $PATHBACKDIR/  -name "*.png"  -maxdepth 1) ]]; then
		STRBACK='2';		
	else
		STRBACK='0';					
	fi		
fi

# Start the splash.
start()
{
	# If in init start ourselves in our familiar system
	if [ -n "$INIT_PROCESS" ]; then		
			#launch psplash 
			if [[ $STR -gt 0 ]] && [[ $STRBACK -gt 0 ]] ; then		
					$PATHDIR/psplash-drm $PATHSPLASHDIR/splash.* $PATHBACKDIR/default.* -w  			
			else	
					$PATHDIR/psplash-drm /home/root/README-CHECK-GPU   /home/root/README-CHECK-GPU   -w	 
			fi		
	# Otherwise, manually launched the splash
	else

			if [[ $STR -gt 0 ]] && [[ $STRBACK -gt 0 ]] ; then		
					$PATHDIR/psplash-drm $PATHSPLASHDIR/splash.* $PATHBACKDIR/default.* -w  
			else	
					$PATHDIR/psplash-drm /home/root/README-CHECK-GPU   /home/root/README-CHECK-GPU   -w	 
			fi		

		if [ "$#" -gt 0 ]; then
			# If a command was passed, run it
			# (used for profiling specific applications)
			echo "profile.process = $( basename $1 )" >> header
			$@
			stop
		else
			echo "no command passed, you need to manually stop the service sometime"
		fi
	fi
}

if [ $$ -eq 1 ]; then
        # Either started by the kernel - in which case, we start the
        # logger in background and exec init [ re-using this pid (1) ]
        # Or - started after the initrd has completed, in which case
        # we try to do nothing much.
	INIT_PROCESS="yes"
	echo "Starting psplash "

	# Are we running in the initrd ?
	if [ ! -e /dev/random ]; then
		IN_INITRD="yes"
		start &
	else # running inside the main system
		echo "Start psplash: no initrd used; starting"
		start &				
		# the rest of the system to charge ahead, so we catch it		
		echo "psplash continuing boot" >> $TMPFS/kmsg
	fi
	
	# Optionally, an alternative init(1) process may be specified using
	# the kernel command line (e.g. "psplash_init=/sbin/initng")
	init="/sbin/init"
	for i in $@; do
		if [ "${i%%=*}" = "psplash_init" ]; then
			init="${i#*=}"
			break
		fi
                if [ "${i%%=*}" = "init" ]; then
			_init=${i#*=}
			if test "$_init" != "/sbin/psplash"; then
                           init="$_init"
                        fi
                        break
                fi
	done
	export PATH=$OLDPATHps -
	# switch to - either the initrd's init, or the main system's
	exec $init $*
fi

	





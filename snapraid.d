Name{number}
	snapraid - SnapRAID Backup For Disk Arrays

Synopsis
	:snapraid [-c, --conf CONFIG]
	:	[-f, --filter PATTERN] [-d, --filter-disk NAME]
	:	[-m, --filter-missing] [-e, --filter-error]
	:	[-a, --audit-only] [-i, --import DIR]
	:	[-p, --percentage PERC] [-o, --older-than DAYS]
	:	[-Z, --force-zero] [-E, --force-empty]
	:	[-U, --force-uuid] [-D, --force-device]
	:	[-v, --verbose] [-l, --log FILE]
	:	[-s, --start BLKSTART] [-t, --count BLKCOUNT]
	:	sync|status|scrub|list|diff|dup|pool|check|fix|rehash

	:snapraid [-V, --version] [-h, --help] [-C, --gen-conf CONTENT]

Description
	SnapRAID is a backup program for disk arrays. It stores redundancy
	information of your data and it's able to recover from up to six
	disk failures.

	SnapRAID is mainly targeted for a home media center, with a lot of
	big files that rarely change.

	Beside the ability to recover from disk failures, other
	features of SnapRAID are:

	* All your data is hashed to ensure data integrity and to avoid
		silent corruption.
	* If the failed disks are too many to allow a recovery,
		you lose the data only on the failed disks.
		All the data in the other disks is safe.
	* If you accidentally delete some files in a disk, you can
		recover them.
	* You can start with already filled disks.
	* The disks can have different sizes.
	* You can add disks at any time.
	* It doesn't lock-in your data. You can stop using SnapRAID at any
		time without the need to reformat or move data.

	The official site of SnapRAID is:

		:http://snapraid.sourceforge.net

Limitations
	SnapRAID is in between a RAID and a Backup program trying to get the best
	benefits of them. Although it also has some limitations that you should
	consider before using it.

	The main one is that if a disk fails, and you haven't recently synced,
	you may not able to do a complete recover.
	More specifically, you may be unable to recover up to the size of the
	amount of the changed or deleted files from the last sync operation.
	This happens even if the files changed or deleted are not in the
	failed disk.
	New added files don't prevent the recovering of the already existing
	files. You may only lose the just added files, if they are on the failed
	disk.

	This is the reason because SnapRAID is better suited for data that
	rarely change.

	Other limitations are:

	* You have different file-systems for each disk.
		Using a RAID you have only a big file-system.
	* It doesn't stripe data.
		With RAID you get a speed boost with striping.
	* It doesn't support real-time recovery.
		With RAID you do not have to stop working when a disk fails.
	* It's able to recover damages only from a limited number of disks.
		With a Backup you are able to recover from a complete
		failure of the whole disk array.
	* Only file, timestamps, symlinks and hardlinks are saved.
		Permissions, ownership and extended attributes are not saved.

Getting Started
	To use SnapRAID you need to first select one disk of your disk array
	to dedicate at the "parity" information. With one disk for parity you
	will be able to recover from a single disk failure, like RAID5.

	If you want to be able to recover from more disk failures, like RAID6,
	you must reserve additional disks for parity. Any additional parity
	disk allow to recover from one more disk failure.

	As parity disks, you have to pick the biggest disks in the array,
	as the redundancy information may grow in size as the biggest data
	disk in the array.

	These disks will be dedicated to store the "parity" files.
	You should not store your data in them.

	The list of files is saved in the "content" files, usually
	stored in the data, parity or boot disks.
	These files contain the details of your backup, with all the
	checksums to verify its integrity.
	The "content" file is stored in multiple copies, and each one must
	be in a different disk, to ensure that in even in case of multiple
	disk failures at least one copy is available.

	For example, suppose that you are interested only at one parity level
	of protection, and that your disks are present in:

		:/mnt/diskp <- selected disk for parity
		:/mnt/disk1 <- first disk to backup
		:/mnt/disk2 <- second disk to backup
		:/mnt/disk3 <- third disk to backup

	you have to create the configuration file /etc/snapraid.conf with
	the following options:

		:parity /mnt/diskp/parity
		:content /var/snapraid/content
		:content /mnt/disk1/content
		:content /mnt/disk2/content
		:disk d1 /mnt/disk1/
		:disk d2 /mnt/disk2/
		:disk d3 /mnt/disk3/

	If you are in Windows, you should use drive letters and backslashes
	instead of slashes, and if you like, also file extensions.

		:parity E:\parity.par
		:content C:\snapraid\content.lst
		:content F:\array\content.lst
		:content G:\array\content.lst
		:disk d1 F:\array\
		:disk d2 G:\array\
		:disk d3 H:\array\

	At this point you are ready to start the "sync" command to build the
	redundancy information.

		:snapraid sync

	This process may take some hours the first time, depending on the size
	of the data already present in the disks. If the disks are empty
	the process is immediate.

	You can stop it at any time pressing Ctrl+C, and at the next run it
	will start where interrupted.

	When this command completes, your data is SAFE.

	At this point you can start using your array as you like, and periodically
	update the redundancy information running the "sync" command.

  Checking & Fixing
	To check the integrity of your data you can use the "check" command:

		:snapraid check

	If will read all your data, to check if it's correct.

	If an error is found, you can use the "fix" command to fix it.

		:snapraid fix

	Note that the fix command will revert your data at the state of the
	last "sync" command executed. It works like a snapshot was taken
	in "sync".

  Recovering and Undeleting
	In recovering SnapRAID is more like a backup program than a RAID system,
	and it can be used to restore or undelete only a single file or directory
	to its previous state using the -f, --filter option :

		:snapraid fix -f FILE

	or for a directory:

		:snapraid fix -f DIR/

	You can also use it to recover only accidentally deleted files inside
	a directory using the -m, --filter-missing option, that restores
	only missing files, leaving untouched all the others.

		:snapraid fix -m -f DIR/

	Or to recover all the deleted files in all the drives with:

		:snapraid fix -m

  Scrubbing
	To periodically check the old data for errors, you can run the "scrub"
	command.

		:snapraid scrub

	This command is similar at "check" but verifies only the oldest data
	in your array. Every run of the command checks about 12% of the data,
	but nothing newer than 10 days.
	You can use the -p, --percentage option to specify a different amount,
	and the -o, --older-than option to specify a different age in days.
	For example, to check 5% of the array older than 20 days use:

		:snapraid -p 5 -o 20 scrub

	If silent errors are found, the corresponding blocks are marked as bad
	in the "content" file, and listed in the "status" command.

		:snapraid status

	To fix them, you can use the "fix" command filtering for files
	containing bad blocks:

		:snapraid -e fix

	At the next "scrub" the errors will disappear from the "status" report
	if really fixed. You can use -p 0 to scrub only blocks marked as bad.

		:snapraid -p 0 scrub

  Pooling
	To have all the files in your array shown in the same directory tree,
	you can enable "pooling", that consists in creating a virtual view of all
	the files in your array using symbolic links.
	You can configure the "pooling" directory in the configuration file with:

		:pool /pool

	or, if you are in Windows, with:

		:pool C:\pool

	and then run the "pool" command.

		:snapraid pool

	If you are using a Unix platform and you want to configure SAMBA to
	share such directory, you should add to your /etc/samba/smb.conf the
	following options:

		:# In the global section of smb.conf
		:unix extensions = no

		:# In the share section of smb.conf
		:[pool]
		:comment = Pool
		:path = /pool
		:read only = yes
		:guest ok = yes
		:wide links = yes

Commands
	SnapRAID provides some simple commands that allow to:

	* Make a backup/snapshot -> "sync"
	* Periodically checks old data -> "scrub"
	* Prints a report of the status of the array -> "status"
	* Check for integrity the full array -> "check"
	* Restore the last backup/snapshot -> "fix".

	Take care that the commands have to be written in lower case.

  sync
	Updates the redundancy information. All the modified files
	in the disk array are read, and the redundancy data is
	recomputed.

	Files are identified by path and/or inode and checked by
	size and timestamp.
	If the size or timestamp are different, the redundancy data is
	recomputed for the whole file.
	Using inode allow you can move them on the disk
	without triggering any redundancy recomputation.

	You can stop this process at any time pressing Ctrl+C,
	without losing the work already done.

	The "content", "parity" files are modified if necessary.
	The files in the array are NOT modified.

  check
	Checks all the files and the redundancy data.
	All the files are hashed and compared with the snapshot saved
	in the previous "sync" command.

	If an error if found, a recovery attempt is simulated to check
	if the error is a recoverable one or not.

	If you use the -a, --audit-only option, only the file
	data is checked, and the redundandy data is ignored.

	Files are identified by path, and checked by content.

	Nothing is modified.

  fix
	Checks and fix all the files. It's like "check" but it also fixes
	errors reverting the state of the disk array to the previous "sync"
	command.

	After a successful "fix", you should also run a "sync" command to
	update the new state of the files.

	All the files that cannot be fixed are renamed adding
	the ".unrecoverable" extension.

	The "content" file is NOT modified.
	The "parity" files are modified if necessary.
	The files in the array are modified if necessary.

  scrub
	Scrubs the array, checking for silent errors.

	For each command invocation, the 12% of the array is checked, but
	nothing that it's more recent than 10 days.
	This means that scrubbing once a week, every bit of data is checked
	at least one time every two months.

	You can use the -p, --percentage option to specify a different amount,
	and the -o, --older-than option to specify a different age in days.
	Note that if only one of -p and -o is specified the default value of
	the other option is not used.

	Any silent error identified is recorded in the content file,
	and it's listed in the "status" command until it's fixed calling
	"fix" and then "scrub".

	The oldest blocks are scrubbed first ensuring an optimal check.
	Blocks already marked as bad are always checked, and if found
	correct, they are automatically unmarked.

	It's recommended to run "scrub" on a synched array, to avoid to have
	reported error caused by unsynched data. These errors are recognized
	as not being silent errors, and the blocks are not marked as bad,
	but such errros are reported in the output of the command.

	The "content" file is modified to update the time of the last check
	of each block.
	The "parity" files are NOT modified.
	The files in the array are NOT modified.

  status
	Prints a summary of the state of the disk array.

	It includes information about the parity fragmentation, how old
	are the blocks without checking, and all the recorded silent
	errors encoutered while scrubbing.

	Nothing is modified.

  list
	Lists all the files contained in the array at the time of the
	last "sync" command.

	Nothing is modified.

  diff
	Lists all the files modified from the last "sync" command that
	have to recompute their redundancy data.

	This command doesn't check the file data, but only the file timestamp
	size and inode.

	Nothing is modified.

  dup
	Lists all the duplicate files. Two files are assumed equal if their
	hashes are matching. The file data is not read, but only the
	precomputed hashes are used.

	Nothing is modified.

  pool
	Creates or updates in the "pooling" directory a virtual view of all
	the files of your disk array.

	The files are not really copied here, but just linked using
	symbolic links.

	When updating, all the present symbolic links and empty
	subdirectories are deleted and replaced with the new
	view of the array. Any othe regular file is left in place.

	Nothing is modified outside the pool directory.

  rehash
	Schedules a rehash of the whole array.

	This option can be used to change the hash kind used,
	typically when upgrading from a 32 bits system to a 64
	bits one to switch from MurmurHash3 to the faster SpookyHash.

	If you are already using the optimal hash, this command
	do nothing and just inform you that nothing has to be done.

	The rehash isn't done immediately, but it takes place
	progressively during the "sync" and "scrub" commands.

	You can get the rehash state using the "status" command.

	During the rehash, SnapRAID maintains full functionality,
	with the only expection of the "dup" command not able to detect
	duplicated files using a different hash.

Options
	SnapRAID provides the following options:

	-c, --conf CONFIG
		Selects the configuration file. If not specified it's assumed
		the file "/etc/snapraid.conf" in Unix, and "snapraid.conf" in
		the current directory in Windows.

	-f, --filter PATTERN
		Filters the files to process in the "check" and "fix"
		commands.
		Only the files matching the entered pattern are processed.
		This option can be used many times.
		See the PATTERN section for more details in the
		pattern specifications.
		In Unix, ensure to quote globbing chars if used.
		This option can be used only with the "check" and "fix" commands.
		Note that it cannot be used with "sync", because "sync" always
		process the whole array.

	-d, --filter-disk NAME
		Filters the files to process in the "check" and "fix"
		commands.
		Only the files present in the specified disk are processed.
		You must specify a disk name as named in the configuration
		file.
		In "check", you can make it faster, specifing also -a, --audit-only
		option, to avoid to access other disks to check parity data.
		If you combine more --filter, --filter-disk and --filter-missing options,
		only files matching all the set of filters are selected.
		This option can be used many times.
		This option can be used only with the "check" and "fix" commands.
		Note that it cannot be used with "sync", because "sync" always
		process the whole array.

	-m, --filter-missing
		Filters the files to process in the "check" and "fix"
		commands.
		Only the files missing/deleted from the array are processed.
		When used with "fix", this is a kind of "undelete" command.
		If you combine more --filter, --filter-disk and --filter-missing options,
		only files matching all the set of filters are selected.
		This option can be used only with the "check" and "fix" commands.
		Note that it cannot be used with "sync", because "sync" always
		process the whole array.

	-e, --filter-error
		Filters the files to process in the "check" and "fix"
		commands.
		It process only the files containing blocks marked with silent
		errors during the "sync" or "scrub" command, and listed in the
		"status" command.
		Errors found in "check" are not processed by this
		option, because they are not marked as bad as "check" is a
		read-only command.
		This option can be used only with the "check" and "fix" commands.

	-p, --percentage PERC
		Selects the part of the array to process in the "scrub" command.
		PERC is a numeric value from 0 to 100, default is 12.
		When specifing 0, only the blocks marked as bad are scrubbed.
		This option can be used only with the "scrub" command.

	-o, --older-than DAYS
		Selects the older the part of the array to process in the
		"scrub" command.
		DAYS is the minimum age in days for a block to be scrubbed,
		default is 10.
		Blocks marked as bad are always scrubbed despite this option.
		This option can be used only with the "scrub" command.

	-a, --audit-only
		When checking, only verify the hash of the files, without
		doing any kind of check on the redundancy data.
		If you are interested in checking only the file data this
		option can speedup a lot the checking process.
		This option can be used only with the "check" command.

	-i, --import DIR
		When fixing imports from the specified directory any file
		that you deleted from the array after the last "sync"
		commmand.
		If you still have such files, they could be used by the "fix"
		command to improve the recover process.
		The files are read also in subdirectories and they are
		identified regardless of their name.
		This option can be used only with the "check" and "fix" command.

	-Z, --force-zero
		Forces the insecure operation of syncing a file with zero
		size that before was not.
		If SnapRAID detects a such condition, it stops proceeding
		unless you specify this option.
		This allows to easily detect when after a system crash,
		some accessed files were zeroed.
		This is a possible condition in Linux with the ext3/ext4
		filesystems.
		This option can be used only with the "sync" command.

	-E, --force-empty
		Forces the insecure operation of syncing a disk with all
		the original files missing.
		If SnapRAID detects that all the files originally present
		in the disk are missing or rewritten, it stops proceeding
		unless you specify this option.
		This allows to easily detect when a data file-system is not
		mounted.
		This option can be used only with the "sync" command.

	-U, --force-uuid
		Forces the insecure operation of syncing, checking and fixing
		with disks that have changed their UUID.
		If SnapRAID detects that some disks have changed UUID,
		it stops proceeding unless you specify this option.
		This allows to detect when your disks are mounted in the
		wrong mount points.
		It's anyway allowed to have a single UUID change with
		single parity, and more with multiple parity, because it's
		the normal case of replacing disks after a recover.
		This option can be used only with the "sync", "check" or
		"fix" command.

	-D, --force-device
		Forces the insecure operation of fixing with disks on the same
		physical device.
		If SnapRAID detects that some disks have the same device ID,
		it stops proceeding, because it's not a supported configuration.
		But it could happen that you want to temporarely restore a lost
		disk in the free space left in an already used disk. and this
		option allows you to continue anyway.

	-l, --log FILE
		Write a detailed log of errors found in check and fix.
		This log contains the exact specification of which block of
		any file is not recoverable and why.
		If this option is not specified, no detailed log is printed,
		and you'll get only a summary at the end of the operations.
		When checking and fixing this allows to keep separated
		the possible huge list of errors from the human readable
		output.

	-s, --start BLKSTART
		Starts the processing from the specified
		block number. It could be useful to retry to check
		or fix some specific block, in case of a damaged disk.
		It's present mainly for advanced manual recovering.

	-t, --count BLKCOUNT
		Processes only the specified number of blocks.
		It's present mainly for advanced manual recovering.

	-C, --gen-conf CONTENT_FILE
		Generates a dummy configuration file from an existing
		content file.
		The configuration file is written in the standard output,
		and it doesn't overwrite an existing one.
		This configuration file also contains the information
		needed to reconstruct the disk mount points, in case you
		lose the entire system.

	-v, --verbose
		Prints more information in the processing.

	-h, --help
		Prints a short help screen.

	-V, --version
		Prints the program version.

Configuration
	SnapRAID requires a configuration file to know where your disk array
	is located, and where storing the redundancy information.

	This configuration file is located in /etc/snapraid.conf in Unix or
	in the execution directory in Windows.

	It should contain the following options (case sensitive):

  parity FILE
	Defines the file to use to store the parity information.
	The parity enables the protection from a single disk
	failure, like RAID5.
	
	It must be placed in a disk dedicated for this purpose with
	as much free space as the biggest disk in the array.
	Leaving the parity disk reserved for only this file ensures that
	it doesn't get fragmented, improving the performance.

	This option is mandatory and it can be used only one time.

  [q,r,s,t,u]-parity FILE
	Defines the files to use to store extra parity information.
	For each parity file specified, one additional level of protection
	is enabled:

	* q-parity enables RAID6 double parity
	* r-parity enables triple parity
	* s-parity enables quad parity
	* t-parity enables penta (five) parity
	* u-parity enables hexa (six) parity

	Each parity level requires also all the files of the previous levels.

	Each file must be placed in a disk dedicated for this purpose with
	as much free space as the biggest disk in the array.
	Leaving the parity disks reserved for only these files ensures that
	they doesn't get fragmented, improving the performance.

	These options are optional and they can be used only one time.

  z-parity FILE
	Defines an alternate file and format to store the triple parity.

	This option is an alternative at 'r-parity' mainly intended for
	low end CPUs like ARM or AMD Phenom, Athlon and Opteron that don't
	support the SSSE3 instructions set, and in such case it may provide
	a better performance.

	This format is similar at the one used by the Linux Kernel RAID6 and
	ZFS RAIDZ3, but it doesn't work beyond triple parity.

	When using 'r-parity' you will be warned if it's recommended to use
	the 'z-parity' format for a performance improvment.

	It's possible to convert from one format to another, adjusting
	the configuraton file with the wanted z-parity or r-parity file,
	and using 'fix' to recreate it.

  content FILE
	Defines the file to use to store the list and checksums of all the
	files present in your disk array.

	It can be placed in the disk used to store data, parity, or
	any other disk available.
	If you use a data disk, this file is automatically excluded
	from the "sync" process.

	This option is mandatory and it can be used more time to save
	more copies of the same files.

	You have to store at least one copy for each parity disk used
	plus one. Using some more don't hurt.

  disk NAME DIR
	Defines the name and the mount point of the disks of the array.
	NAME is used to identify the disk, and it must be unique.
	DIR is the mount point of the disk in the filesystem.

	You can change the mount point as you like, as long you
	keep the NAME fixed.

	You should use one option for each disk of the array.

  nohidden
	Excludes all the hidden files and directory.
	In Unix hidden files are the ones starting with ".".
	In Windows they are the ones with the hidden attribute.

  exclude/include PATTERN
	Defines the file or directory patterns to exclude and include
	in the sync process.
	All the patterns are processed in the specified order.

	If the first pattern that matches is an "exclude" one, the file
	is excluded. If it's an "include" one, the file is included.
	If no pattern matches, the file is excluded if the last pattern
	specified is an "include", or included if the last pattern
	specified is an "exclude".

	See the PATTERN section for more details in the pattern
	specifications.

	This option can be used many times.

  block_size SIZE_IN_KIBIBYTES
	Defines the basic block size in kibi bytes of the redundancy
	blocks. Where one kibi bytes is 1024 bytes.
	The default is 256 and it should work for most conditions.
	You could increase this value if you do not have enough RAM
	memory to run SnapRAID.

	As a rule of thumb, with 4 GiB or more memory use the default 256,
	with 2 GiB use 512, and with 1 GiB use 1024.

	In more details SnapRAID requires about TS*28/BS bytes
	of RAM memory to run. Where TS is the total size in bytes of
	your disk array, and BS is the block size in bytes.

	For example with 4 disk of 3 TiB and a block size of 256 KiB
	(1 KiB = 1024 Bytes) you have:

	:RAM = (4 * 3 * 2^40) * 28 / (256 * 2^10) = 1.4 GiB

	You could instead decrease this value if you have a lot of
	small files in the disk array. For each file, even if of few
	bytes, a whole block is always allocated, so you may have a lot
	of unused space.
	As approximation, you can assume that half of the block size is
	wasted for each file.

	For example, with 10000 files and a 256 KiB block size, you are
	going to waste 1.2 GiB.

    autosave SIZE_IN_GIBIBYTES
	Automatically save the state when synching after the specied amount
	of GiB processed.
	This option is useful to avoid to restart from scratch long "sync"
	commands interrupted by a machine crash, or any other event that
	may interrupt SnapRAID.
	The SIZE argument is specified in gibibytes. Where one gibi bytes
	is 1073741824 bytes.

    pool DIR
	Defines the pooling directory where the virtual view of the disk
	array is created using the "pool" command.
	The directory must already exist.

  Examples
	An example of a typical configuration for Unix is:

		:parity /mnt/diskp/parity
		:content /mnt/diskp/content
		:content /var/snapraid/content
		:disk d1 /mnt/disk1/
		:disk d2 /mnt/disk2/
		:disk d3 /mnt/disk3/
		:exclude /lost+found/
		:exclude /tmp/

	An example of a typical configuration for Windows is:

		:parity E:\parity.par
		:content E:\content.lst
		:content C:\snapraid\content.lst
		:disk d1 G:\array\
		:disk d2 H:\array\
		:disk d3 I:\array\
		:exclude Thumbs.db
		:exclude \$RECYCLE.BIN
		:exclude \System Volume Information

Pattern
	Patterns are used to select a subset of files to exclude or include in
	the process.

	There are four different types of patterns:

	=FILE
		Selects any file named as FILE. You can use any globbing
		character like * and ?.
		This pattern is applied only to files and not to directories.

	=DIR/
		Selects any directory named DIR. You can use any globbing
		character like * and ?.
		This pattern is applied only to directories and not to files.

	=/PATH/FILE
		Selects the exact specified file path. You can use any
		globbing character like * and ? but they never match a
		directory slash.
		This pattern is applied only to files and not to directories.

	=/PATH/DIR/
		Selects the exact specified directory path. You can use any
		globbing character like * and ? but they never match a
		directory slash.
		This pattern is applied only to directories and not to files.

	In Windows you can freely use the backslash \ instead of the forward slash /.

	Note that Windows system directories, junction to directories,
	mount points, and any other Windows special directory is treated just
	as a file, meaning that to exclude it you must use a file rule, and
	not a directory one.

	In the configuration file, you can use different strategies to filter
	the files to process.
	The simplest one is to use only "exclude" rules to remove all the
	files and directories you do not want to process. For example:

		:# Excludes any file named "*.unrecoverable"
		:exclude *.unrecoverable
		:# Excludes the root directory "/lost+found"
		:exclude /lost+found/
		:# Excludes any sub-directory named "tmp"
		:exclude tmp/

	The opposite way is to define only the file you want to process, using
	only "include" rules. For example:

		:# Includes only some directories
		:include /movies/
		:include /musics/
		:include /pictures/

	The final way, is to mix "exclude" and "include" rules. In this case take
	care that the order of rules is important. Previous rules have the
	precedence over the later ones.
	To get things simpler you can first have all the "exclude" rules and then
	all the "include" ones. For example:

		:# Excludes any file named "*.unrecoverable"
		:exclude *.unrecoverable
		:# Excludes any sub-directory named "tmp"
		:exclude tmp/
		:# Includes only some directories
		:include /movies/
		:include /musics/
		:include /pictures/

	On the command line, using the -f option, you can only use "include"
	patterns. For example:

		:# Checks only the .mp3 files.
		:# Note the "" use to avoid globbing expansion by the shell in Unix.
		:snapraid -f "*.mp3" check

	In Unix, when using globbing chars in the command line, you have to quote them.
	Otherwise the shell will try to expand them.

Recovering
	The worst happened, and you lost a disk!

	DO NOT PANIC! You will be able to recover it!

	The first thing you have to do is to avoid futher changes at you disk array.
	Disable any remote connection to it, any scheduled process, including any
	scheduled SnapRAID nightly sync.

	Then proceed with the following steps.

  STEP 1 -> Reconfigure
	You need some space to recover, even better if you already have an additional
	disk, but in case, also an external USB or remote one is enough.
    
	Change the SnapRAID configuration file and make the "disk" option
	of the failed disk to point to a place where you have enough empty space
	to recover the files.

	For example, if you have that disk "d1" failed, you can change:

		:disk d1 /mnt/disk1/

	to:

		:disk d1 /mnt/new_spare_disk/

  STEP 2 -> Fix
	Run the fix command, storing the log in an external file with:

		:snapraid -d NAME -l fix.log fix

	Where NAME is the name of the disk, like "d1" as in our previous example.

	This command will take a long time.

	Take care that you need also few gigabytes free to store the fix.log file.
	Run it from a disk with some free space.

	Now you have recovered all the recoverable. If some file is partially or totally
	unrecoverable, it will be renamed adding the ".unrecoverable" extension.

	You can get a detailed list of all the unrecoverable blocks in the fix.log file
	checking all the lines starting with "unrecoverable:"

	If you are not satified of the recovering, you can retry it as many time you wish.
	For example, if you have moved away some files from other disks after the last "sync",
	you can retry to put them inplace, and retry the "fix".

	If you are satisfied of the recovering, you can now proceed further,
	but take care that after synching you will no more able to retry the
	"fix" command!

  STEP 3 -> Check
	As paranoid but recommended check, you can now run a "check" command to ensure
	that everything is OK on the disk.

		:snapraid -d NAME -a check

	Where NAME is the name of the disk, like "d1" as in our previous example.

	The options -d and -a tell SnapRAID to check only the specified disk,
	and ignore all the redundancy data.

	This command will take a long time.

  STEP 4 -> Sync
	Run the "sync" command to resyncronize the array with the new disk.

		:snapraid sync

	If everything was recovered, this command is immediate.

Content
	SnapRAID stores the list and checksums of your files in the content file.

	It's a binary file, listing all the files present in your disk array,
	with all the checksums to verify their integrity.

	You do not need to understand its format to use SnapRAID.

	This file is read and written by the "sync" and "scrub" commands, and
	only read by "fix", "check" and "status".

Parity
	SnapRAID stores the redundancy information of your array in the parity
	files.

	They are binary files, containing the computed redundancy of all the
	blocks defined in the "content" file.

	These files are read and written by the "sync" and "fix" commands, and
	only read by "scrub" and "check".

Encoding
	SnapRAID in Unix ignores any encoding. It simply reads and stores the
	file names with the same encoding used by the filesystem.

	In Windows all the names read from the filesystem are converted and
	processed in the UTF-8 format.

	To have the file names printed correctly you have to set the Windows
	console in the UTF-8 mode, with the command "chcp 65001", and use
	a TrueType font like "Lucida Console" as console font.
	Note that it has effect only on the printed file names, if you
	redirect the console output to a file, the resulting file is always
	in the UTF-8 format.

Copyright
	This file is Copyright (C) 2011 Andrea Mazzoleni

See Also
	rsync(1)


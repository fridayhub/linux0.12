#
# if you want the ram-disk device, define this to be the
# size in blocks.
#
RAMDISK = #-DRAMDISK=512

# This is a basic Makefile for setting the general configuration
include Makefile.header
include Makefile.emulators

LDFLAGS += -Ttext 0 -e startup_32
CFLAGS  += $(RAMDISK) -nostdinc -Iinclude
CPP += -Iinclude

#
# ROOT_DEV specifies the default root-device when making the image.
# This can be either FLOPPY, /dev/xxxx or empty, in which case the
# default of /dev/hd6 is used by 'build'.
# hakits modify refer to tool/build judge argc 4 and argc 6 in func main
#ROOT_DEV= 021d # FLOPPY B
#ROOT_DEV= 0301 # hd1
ROOT_DEV=
SWAP_DEV=NONE

ARCHIVES=kernel/kernel.o mm/mm.o fs/fs.o
DRIVERS =kernel/blk_drv/blk_drv.a kernel/chr_drv/chr_drv.a
MATH	=kernel/math/math.a
LIBS	=lib/lib.a

.c.s:
	$(CC) $(CFLAGS) -S -o $*.s $<
.s.o:
	$(AS) -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) -c -o $*.o $<

all:	Image

Image: boot/bootsect boot/setup kernel.sym
	@cp -f images/kernel.sym images/kernel.tmp
	@$(STRIP) images/kernel.tmp
	@$(OBJCOPY) -O binary -R .note -R .comment images/kernel.tmp images/kernel
	$(BUILD) boot/bootsect boot/setup images/kernel images/Image
	@rm images/kernel.tmp
	@rm images/kernel -f
	@sync

#disk: Image
#	dd bs=8192 if=Image of=/dev/fd0

#tools/build: tools/build.c
#	$(CC) -w -O -m32 -fno-stack-protector -fstrength-reduce -fomit-frame-pointer \
#	-o tools/build tools/build.c

boot/head.o: boot/head.s

kernel.sym:	boot/head.o init/main.o \
		$(ARCHIVES) $(DRIVERS) $(MATH) $(LIBS)
	$(LD) $(LDFLAGS)  boot/head.o init/main.o \
	$(ARCHIVES) \
	$(DRIVERS) \
	$(MATH) \
	$(LIBS) \
	-o images/kernel.sym 
	nm images/kernel.sym |grep -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)'| sort > images/kernel.map

kernel/math/math.a:
	(cd kernel/math; make)

kernel/blk_drv/blk_drv.a:
	(cd kernel/blk_drv; make)

kernel/chr_drv/chr_drv.a:
	(cd kernel/chr_drv; make)

kernel/kernel.o:
	(cd kernel; make)

mm/mm.o:
	(cd mm; make)

fs/fs.o:
	(cd fs; make)

lib/lib.a:
	(cd lib; make)

boot/setup: boot/setup.s
	$(AS86) -o boot/setup.o boot/setup.s
	$(LD86) -s -o boot/setup boot/setup.o

boot/setup.s:	boot/setup.S include/linux/config.h
	$(CPP) -traditional boot/setup.S -o boot/setup.s

boot/bootsect.s:	boot/bootsect.S include/linux/config.h
	$(CPP) -traditional boot/bootsect.S -o boot/bootsect.s

boot/bootsect:	boot/bootsect.s
	$(AS86) -o boot/bootsect.o boot/bootsect.s
	$(LD86) -s -o boot/bootsect boot/bootsect.o

clean:
	@make clean -C rootfs
	rm -f images/Image images/kernel.map tmp_make core boot/bootsect boot/setup \
		boot/bootsect.s boot/setup.s
	rm -f init/*.o images/kernel.sym tools/build boot/*.o
	(cd mm;make clean)
	(cd fs;make clean)
	(cd kernel;make clean)
	(cd lib;make clean)

backup: clean
	(cd .. ; tar cf - linux | compress - > backup.Z)
	sync

dep:
	sed '/\#\#\# Dependencies/q' < Makefile > tmp_make
	(for i in init/*.c;do echo -n "init/";$(CPP) -M $$i;done) >> tmp_make
	cp tmp_make Makefile
	(cd fs; make dep)
	(cd kernel; make dep)
	(cd mm; make dep)

### Dependencies:
init/main.o : init/main.c include/unistd.h include/sys/stat.h \
  include/sys/types.h include/sys/time.h include/time.h include/sys/times.h \
  include/sys/utsname.h include/sys/param.h include/sys/resource.h \
  include/utime.h include/linux/tty.h include/termios.h include/linux/sched.h \
  include/linux/head.h include/linux/fs.h include/linux/mm.h \
  include/linux/kernel.h include/signal.h include/asm/system.h \
  include/asm/io.h include/stddef.h include/stdarg.h include/fcntl.h \
  include/string.h 

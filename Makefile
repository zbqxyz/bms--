# Makefile for fdos.
# < cuplision@163.com>


KERNELFILE=KFOOL
# RELEASE=0 release
# RELEASE=1 debug
# RELEASE=2 demon
RELEASE=2
CC=gcc
CXX=g++
AS=nasm
LD=ld
AR=ar
RM=rm
MAKE=make
MAKEPARAM=--no-print-directory
#MAKEPARAM=
OMIT=-
PWD=pwd
WORKDIR=$(shell pwd)
IMGFILE=$(WORKDIR)/floppy.img
Q=@
#Q=
CFLAGS=-D_KERNEL_ -D_VERSION_=$(RELEASE) -I$(WORKDIR)/$(ARCH)\
	-I$(WORKDIR)/include -Wall -ffreestanding \
       -fno-builtin -fno-builtin-function -fno-stack-protector\
	 -z nodefaultlib -I$(WORKDIR)/include/drivers -c
CCFLAGS+=-D_ARCH_$(ARCH)_
CBUILDIN=-D_BUILDIN_ $(CFLAGS)
# used for some directory.
CPFLAGS=
ASFLAGS+=-I $(WORKDIR)/include/ -I $(WORKDIR)/$(ARCH) -f elf
BINASFLAGS=
# build-in objects.
y-objs=
yobjs-list:=$(WORKDIR)/.yobjs
# module objects.
m-objs=
mobjs-list:=$(WORKDIR)/.mobjs
# separate objects.
s-objs=
sobjs-list:=$(WORKDIR)/.sobjs
# binary objects.
b-objs=
PHONY+=y-objs m-objs s-objs b-objs
EXPORTS+=KERNELFILE VERSION CC CXX AS LD AR RM MAKE MAKEPARAM OMIT \
	PWD ARCH WORKDIR IMGFILE Q CFLAGS CCFLAGS CMODULE \
	CBUILDIN ASFLAGS BINASFLAGS CPFLAGS yobjs-list mobjs-list\
	 sobjs-list
SEP-DIRS=ontom
# must be the last one.
LAST-DIR=boot
SUB-DIRS=drivers
BOOT_LOADER:=boot/old/boot.bin boot/old/loader.bin

all: _all

PHONY+=all _all

config:
	$(Q)$(OMIT) chmod +x config.sh
	$(Q)$(OMIT) ./config.sh 0
PHONY+=config
reconfig:
	$(Q)$(OMIT) chmod +x config.sh
	$(Q)$(OMIT) ./config.sh 1
PHONY+=reconfig

# FIXME: maybe there is a better way to refresh objects-list files.
_all:
	$(Q)echo ''> $(yobjs-list);echo ''> $(mobjs-list);echo ''> $(sobjs-list);
	$(Q)for d in $(SEP-DIRS) $(SUB-DIRS) $(LAST-DIR); do\
	   $(MAKE) $(MAKEPARAM) -C $$d all;\
     done
PHONY+=all
drivers:
	$(Q)$(MAKE) $(MAKEPARAM) -C drivers all 2>/dev/null
PHONY+=drivers
fs:
	$(Q)$(MAKE) $(MAKEPARAM) -C fs all 2>/dev/null
PHONY+=fs
kernel:
	$(Q)$(MAKE) $(MAKEPARAM) -C kernel all 2>/dev/null
PHONY+=kernel
modules:
	$(Q)echo ''> $(mobjs-list);
	$(Q)for d in $(SEP-DIRS) $(SUB-DIRS) $(LAST-DIR); do\
	   $(MAKE) $(MAKEPARAM) -C $$d modules;\
     done
PHONY+=modules
clean:list-clean
	$(Q)$(OMIT)for d in $(SEP-DIRS) $(SUB-DIRS) $(LAST-DIR);do $(MAKE) $(MAKEPARAM) -C $$d clean 2>/dev/null;done;
PHONY+=clean
list-clean:
	$(Q)for f in $(yobjs-list) $(mobjs-list) $(sobjs-list);do echo "    RM        $$f";done;
	$(Q)$(OMIT)$(RM) $(yobjs-list) $(mobjs-list) $(sobjs-list) 2>/dev/null;
	$(Q)true
PHONY+=list-clean
modules-clean:
	$(Q)echo ''> $(mobjs-list);
	$(Q)for d in $(SEP-DIRS) $(SUB-DIRS) $(LAST-DIR); do\
	   $(MAKE) $(MAKEPARAM) -C $$d modules-clean;\
     done
drivers-clean:
	$(Q)$(MAKE) $(MAKEPARAM) -C drivers clean 2>/dev/null
PHONY+=drivers-clean
kernel-clean:
	$(Q)$(MAKE) $(MAKEPARAM) -C kernel clean 2>/dev/null
PHONY+=kernel-clean
fs-clean:
	$(Q)$(MAKE) $(MAKEPARAM) -C fs clean 2>/dev/null
PHONY+=fs-clean
image:
	$(Q)$(MAKE) $(MAKEPARAM) -C boot boot-img
PHONY+=image
arch-clean:
	$(Q)$(MAKE) $(MAKEPARAM) -C $(ARCH) boot-img
PHONY+=arch-clean

DOEXPORTS=$(EXPORTS)

export $(EXPORTS) DOEXPORTS
.PHONY: $(PHONY)

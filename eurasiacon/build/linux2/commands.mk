#
# Copyright (C) Imagination Technologies Ltd. All rights reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
# 
# This program is distributed in the hope it will be useful but, except 
# as otherwise stated in writing, without any warranty; without even the 
# implied warranty of merchantability or fitness for a particular purpose. 
# See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
# 
# The full GNU General Public License is included in this distribution in
# the file called "COPYING".
#
# Contact Information:
# Imagination Technologies Ltd. <gpl-support@imgtec.com>
# Home Park Estate, Kings Langley, Herts, WD4 8LZ, UK 
# 

# from-one-* recipes make a thing from one source file, so they use $<. Others
# use $(MODULE_something) instead of $^

# We expect that MODULE_*FLAGS contains all the flags we need, including the
# flags for all modules (like $(ALL_CFLAGS) and $(ALL_HOST_CFLAGS)), and
# excluding flags for include search dirs or for linking libraries. The
# exceptions are ALL_EXE_LDFLAGS and ALL_LIB_LDFLAGS, since they depend on the
# type of thing being linked, so they appear in the commands below

define host-o-from-one-c
$(if $(V),,@echo "  HOST_CC " $(call relative-to-top,$<))
$(HOST_CC) -MD -c $(MODULE_HOST_CFLAGS) $(MODULE_INCLUDE_FLAGS) \
	-include $(CONFIG_H) $< -o $@
endef

define target-o-from-one-c
$(if $(V),,@echo "  CC      " $(call relative-to-top,$<))
$(CC) -MD -c $(MODULE_CFLAGS) $(MODULE_INCLUDE_FLAGS) \
	 -include $(CONFIG_H) $< -o $@
endef

# We use $(CC) to compile C++ files, and expect it to detect that it's
# compiling C++
define host-o-from-one-cxx
$(if $(V),,@echo "  HOST_CC " $(call relative-to-top,$<))
$(HOST_CC) -MD -c $(MODULE_HOST_CXXFLAGS) $(MODULE_INCLUDE_FLAGS) \
	 -include $(CONFIG_H) $< -o $@
endef

define target-o-from-one-cxx
$(if $(V),,@echo "  CC      " $(call relative-to-top,$<))
$(CC) -MD -c $(MODULE_CXXFLAGS) $(MODULE_INCLUDE_FLAGS) \
	 -include $(CONFIG_H) $< -o $@
endef

define host-executable-from-o
$(if $(V),,@echo "  HOST_LD " $(call relative-to-top,$@))
$(HOST_CC) $(MODULE_HOST_LDFLAGS) \
	-o $@ $(sort $(MODULE_ALL_OBJECTS)) $(MODULE_LIBRARY_DIR_FLAGS) \
	$(MODULE_LIBRARY_FLAGS)
endef

define host-executable-cxx-from-o
$(if $(V),,@echo "  HOST_LD " $(call relative-to-top,$@))
$(HOST_CXX) $(MODULE_HOST_LDFLAGS) \
	-o $@ $(sort $(MODULE_ALL_OBJECTS)) $(MODULE_LIBRARY_DIR_FLAGS) \
	$(MODULE_LIBRARY_FLAGS)
endef

define target-executable-from-o
$(if $(V),,@echo "  LD      " $(call relative-to-top,$@))
$(CC) \
	$(SYS_EXE_LDFLAGS) $(MODULE_LDFLAGS) -o $@ \
	$(SYS_EXE_CRTBEGIN) $(sort $(MODULE_ALL_OBJECTS)) $(SYS_EXE_CRTEND) \
	$(MODULE_LIBRARY_DIR_FLAGS) $(MODULE_LIBRARY_FLAGS) $(LIBGCC)
endef

define target-executable-cxx-from-o
$(if $(V),,@echo "  LD      " $(call relative-to-top,$@))
$(CXX) \
	$(SYS_EXE_LDFLAGS) $(MODULE_LDFLAGS) -o $@ \
	$(SYS_EXE_CRTBEGIN) $(sort $(MODULE_ALL_OBJECTS)) $(SYS_EXE_CRTEND) \
	$(MODULE_LIBRARY_DIR_FLAGS) $(MODULE_LIBRARY_FLAGS) $(LIBGCC)
endef

define target-shared-library-from-o
$(if $(V),,@echo "  LD      " $(call relative-to-top,$@))
$(CC) -shared -Wl,--no-undefined -Wl,-Bsymbolic \
	$(SYS_LIB_LDFLAGS) $(MODULE_LDFLAGS) -o $@ \
	$(SYS_LIB_CRTBEGIN) $(sort $(MODULE_ALL_OBJECTS)) $(SYS_LIB_CRTEND) \
	$(MODULE_LIBRARY_DIR_FLAGS) $(MODULE_LIBRARY_FLAGS) $(LIBGCC)
endef

# If there were any C++ source files in a shared library, we use this recipe,
# which runs the C++ compiler to link the final library
define target-shared-library-cxx-from-o
$(if $(V),,@echo "  LD      " $(call relative-to-top,$@))
$(CXX) -shared -Wl,--no-undefined -Wl,-Bsymbolic \
	$(SYS_LIB_LDFLAGS) $(MODULE_LDFLAGS) -o $@ \
	$(SYS_LIB_CRTBEGIN) $(sort $(MODULE_ALL_OBJECTS)) $(SYS_LIB_CRTEND) \
	$(MODULE_LIBRARY_DIR_FLAGS) $(MODULE_LIBRARY_FLAGS) $(LIBGCC)
endef

define target-copy-debug-information
$(OBJCOPY) --only-keep-debug $@ $(basename $@).dbg
endef

define host-strip-debug-information
$(HOST_STRIP) --strip-unneeded $@
endef

define target-strip-debug-information
$(STRIP) --strip-unneeded $@
endef

define target-add-debuglink
$(if $(V),,@echo "  DBGLINK " $(call relative-to-top,$(basename $@).dbg))
$(OBJCOPY) --add-gnu-debuglink=$(basename $@).dbg $@
endef

define host-static-library-from-o
$(if $(V),,@echo "  HOST_AR " $(call relative-to-top,$@))
$(HOST_AR) cru $@ $(sort $(MODULE_ALL_OBJECTS))
endef

define target-static-library-from-o
$(if $(V),,@echo "  AR      " $(call relative-to-top,$@))
$(AR) cru $@ $(sort $(MODULE_ALL_OBJECTS))
endef

define tab-c-from-y
$(if $(V),,@echo "  BISON   " $(call relative-to-top,$<))
$(BISON) $(MODULE_BISON_FLAGS) -o $@ -d $<
endef

define l-c-from-l
$(if $(V),,@echo "  FLEX    " $(call relative-to-top,$<))
$(FLEX) $(MODULE_FLEX_FLAGS) -o$@ $<
endef

define clean-dirs
$(if $(V),,@echo "  RM      " $(call relative-to-top,$(MODULE_DIRS_TO_REMOVE)))
$(RM) -rf $(MODULE_DIRS_TO_REMOVE)
endef

define make-directory
$(MKDIR) -p $@
endef

define check-exports
endef

# Programs used in recipes

BISON ?= bison
CC ?= gcc
CXX ?= g++
HOST_CC ?= gcc
HOST_CXX ?= g++
JAR ?= jar
JAVA ?= java
JAVAC ?= javac
ZIP ?= zip

override AR			:= $(if $(V),,@)$(CROSS_COMPILE)ar
override BISON		:= $(if $(V),,@)$(BISON)
override BZIP2		:= $(if $(V),,@)bzip2 -9
override CC			:= $(if $(V),,@)$(CROSS_COMPILE)$(CC)
override CC_CHECK	:= $(if $(V),,@)$(MAKE_TOP)/tools/cc-check.sh
override CXX		:= $(if $(V),,@)$(CROSS_COMPILE)$(CXX)
override CHMOD		:= $(if $(V),,@)chmod
override CP			:= $(if $(V),,@)cp
override DOS2UNIX	:= $(if $(V),,@)\
 $(shell if [ -z `which fromdos` ]; then echo dos2unix -f -q; else echo fromdos -f -p; fi)
override ECHO		:= $(if $(V),,@)echo
override FLEX		:= $(if $(V),,@)flex
override GAWK		:= $(if $(V),,@)gawk
override GREP		:= $(if $(V),,@)grep
override HOST_AR	:= $(if $(V),,@)ar
override HOST_CC	:= $(if $(V),,@)$(HOST_CC)
override HOST_CXX	:= $(if $(V),,@)$(HOST_CXX)
override HOST_STRIP := $(if $(V),,@)strip
override INSTALL	:= $(if $(V),,@)install
override JAR		:= $(if $(V),,@)$(JAR)
override JAVA		:= $(if $(V),,@)$(JAVA)
override JAVAC		:= $(if $(V),,@)$(JAVAC)
override M4			:= $(if $(V),,@)m4
override MKDIR		:= $(if $(V),,@)mkdir
override MV			:= $(if $(V),,@)mv
override OBJCOPY	:= $(if $(V),,@)$(CROSS_COMPILE)objcopy
override PDSASM		:= $(if $(V),,@)$(HOST_OUT)/pdsasm
override RM			:= $(if $(V),,@)rm -f
override SED		:= $(if $(V),,@)sed
override STRIP		:= $(if $(V),,@)$(CROSS_COMPILE)strip
override TAR		:= $(if $(V),,@)tar
override TOUCH  	:= $(if $(V),,@)touch
override USEASM		:= $(if $(V),,@)$(HOST_OUT)/useasm
override USELINK	:= $(if $(V),,@)$(HOST_OUT)/uselink
override VHD2INC	:= $(if $(V),,@)$(HOST_OUT)/vhd2inc
override ZIP		:= $(if $(V),,@)$(ZIP)

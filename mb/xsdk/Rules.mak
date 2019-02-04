# rule for all modules

############## Common for all modules
# support PC environments
# ARCH=
# ARCH=mb


# released or debug version, different on debug and log info£¬2007.03.15
# must be 'release' or 'debug'
EDITION=debug
#EDITION=release

ifeq ($(EDITION),release)
	C_FLAGS += -D__EXT_RELEASE__
else	
endif 

ifeq ($(ARCH),mb)
#	C_FLAGS += -D__ARM_CMN__=1 -DARCH_ARM=1  -DARCH_X86=0 -DARCH_X86_32=0 
	CROSS_COMPILER=mb-
	LDFLAGS+=  
	flag=
#	C_FLAGS +=-DARM -DARCH_ARM=1 
	
else
	ARCH=X86
#	C_FLAGS +=-D$(ARCH) -DARCH_X86=1 -DARCH_X86_32=1 -DARCH_ARM=0 
	EXTENSION=
endif


BIN_DIR=$(ROOT_DIR)/BIN/$(BOARD_NAME)
OBJ_DIR=objs


ifeq ($(ARCH),X86)
else
	ARCH=mb
endif

HW_DESGIN:=vMicroBlaze_i
SCRIPT_DIR:=$(RULE_DIR)/scripts

HW_NAME:=vMicroBlaze_wrapper
OUTPUT_DIR:=output

WORKSPACE:=ws

HW_PROJECT:=hwProj
BSP_PROJECT:=bspProj
FS_BOOT_EXE:=fsboot.elf
DOWNLOAD_FILE:=download

export OUTPUT_DIR
export HW_PROJECT
export BSP_PROJECT
export FS_BOOT_EXE
export DOWNLOAD_FILE


CC	= $(CROSS_COMPILER)gcc
CXX 	= $(CROSS_COMPILER)g++ 
STRIP	= $(CROSS_COMPILER)strip
LD	= $(CROSS_COMPILER)ld
RANLIB 	= $(CROSS_COMPILER)ranlib
STRIP 	= $(CROSS_COMPILER)strip
AR 	= $(CROSS_COMPILER)ar
OBJCOPY 	= $(CROSS_COMPILER)objcopy
SIZE 	= $(CROSS_COMPILER)size

ASM = as

RM	= rm -r -f
MKDIR	= mkdir -p
MODE	= 700
OWNER	= root
CHOWN	= chown
CHMOD	= chmod
COPY	= cp
MOVE	= mv

LN		= ln -sf


# configuration options for manage this project  TZ=CN 
#BUILDTIME := $(shell TZ=UTC date -u "+%Y_%m_%d-%H_%M")
BUILDTIME := $(shell date -u "+%Y_%m_%d")
GCC_VERSION := $(shell $(CC) -dumpversion )

RELEASES_NAME=$(NAME)_$(GCC_VERSION)_$(ARCH)_$(EDITION)_$(BUILDTIME).tar.gz  


export BUILDTIME
export RELEASES_NAME

ifeq ($(CPU_E70Q20),YES)
	BOARD_NAME=AN767
	# CFLAGS += -D__SAME70Q20__ -DEXTLAB_BOARD=1 -DEXT_LAB
	LINK_SCRIPT =src/lscript.ld
else
	BOARD_NAME=Vid
	# CFLAGS += -D__SAME70Q21__ -DEXTLAB_BOARD=0 -DEXT_LAB
	LINK_SCRIPT =src/lscript.ld
endif


############## definitions for different modules


BSP_HOME:=$(ROOT_DIR)/bsp
LWIP_HOME:=$(ROOT_DIR)/bsp/libs/lwip141_v2_0
OS_HOME:=$(ROOT_DIR)/os



CFLAGS += 

EXE=microBlaze$(BOARD_NAME).bin


SUPPORT_LIBS:= -L$(BIN_DIR) -L$(ROOT_DIR)/libs -Wl,--no-relax -Wl,--gc-sections -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

BSP_LIBS += \
		axidma_v9_5 \
		axiethernet_v5_6 \
		bram_v4_2 \
		cpu_v2_6 \
		intc_v3_7 \
		spi_v4_3 \
		tmrctr_v4_4 \
		uartlite_v3_2 \
		standalone_v6_5 \
		

# gmac, tc and pmc only used in network
BSP_HEADER= \
	-I$(BSP_HOME) \
	-I$(BSP_HOME)/include \
	-I$(BSP_HOME)/src/axidma_v9_5/src \
	-I$(BSP_HOME)/src/axiethernet_v5_6/src \
	-I$(BSP_HOME)/src/bram_v4_2/src \
	-I$(BSP_HOME)/src/cpu_v2_6/src \
	-I$(BSP_HOME)/src/intc_v3_7/src \
	-I$(BSP_HOME)/src/spi_v4_3/src \
	-I$(BSP_HOME)/src/tmrctr_v4_4/src \
	-I$(BSP_HOME)/src/uartlite_v3_2/src \
	-I$(BSP_HOME)/src/standalone_v6_5/src \
	-I$(BSP_HOME)/src/mig_7series_v2_1/src \


XILISF_HEADER= \
	-I$(BSP_HOME)/libs/xilisf_v5_9/src/include \


LWIP_SRC_HOME=$(LWIP_HOME)/src

LWIP_HEADER= \
	-I$(LWIP_SRC_HOME)/lwip-1.4.1/src/include \
	-I$(LWIP_SRC_HOME)/lwip-1.4.1/src/include/ipv4 \
	-I$(LWIP_SRC_HOME)/contrib/ports/xilinx/include \

#	$(LWIP_SRC_HOME)/contrib/ports/xilinx/netif \




MUX_HEADER= \
	-I$(MAIN_HEAD_HOME)/include \


CFLAGS += -DROOT_DIR='"$(ROOT_DIR)"' -I$(ROOT_DIR) 


###################################################################
# define directories for header file and build flags
###################################################################


RTOS_FLAGS+=

LWIP_FLAGS+=-DLWIP_DEBUG -DLWIP_V2=1 

M_FLAGS := -mcpu=v10.0 -mlittle-endian -mno-xl-soft-div -mno-xl-soft-mul -mxl-barrel-shift -mxl-multiply-high -mxl-pattern-compare

CFLAGS += $(M_FLAGS) \
	-ffunction-sections -fdata-sections -Wall -Wextra \
	
O_CFLAGS += \	
	-O1 -fdata-sections -ffunction-sections -mlong-calls -g3 -Wall \
	-pipe -fno-strict-aliasing -Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith \
	-std=gnu99 -Wchar-subscripts -Wcomment -Wformat=2 -Wimplicit-int -Wmain -Wparentheses -Wsequence-point -Wreturn-type -Wswitch -Wtrigraphs \
	-Wunused -Wuninitialized -Wunknown-pragmas -Wfloat-equal -Wundef -Wshadow -Wbad-function-cast -Wwrite-strings -Wsign-compare -Waggregate-return \
	-Wmissing-declarations -Wformat -Wmissing-format-attribute -Wno-deprecated-declarations -Wredundant-decls \
	-Wunreachable-code --param max-inline-insns-single=500 

# -Wcast-align  -v

# can't use this options, pbuf in Lwip and gmac of atmel must be alligned differently, such as 8 bytes border or others
# CPACK_FLAGS =	-fpack-struct
# -fpack-struct, add 05.07,2018,JL

# -Wlong-long: disable ISO C90 not support 'long long' warns in RTK SDK
# -Wpacked : disable warns for 'packed' in LwIP protocols
# -Wnested-externs : nested extern declaration

# for FreeRTOS, declarations of sysclk_get_cpu_hz() 
#CFLAGS += -Werror=implicit-function-declaration	


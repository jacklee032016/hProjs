# Run in MinGW
# Jan.25, 2019,  Jack Lee

# on windows you have to prefix vivado call with a cmd shell with /c
ifeq ($(UNAME), Linux)
PREFIX = ""
POSTFIX = ""
else
PREFIX = cmd /c "
POSTFIX = "
endif

#MODULE=oled
MODULE=keyboard
# MODULE=GPIO
export MODULE


# These are all the compilation targets, starting with "all"
all: oled

##### Project PicoBlaze + UART
oled:setup build

setup: .setup.done

.setup.done:
	vivado -mode batch -source ./scripts/setup.tcl -tempDir works -log setup.log -jou setup.jou

build: .build.done
.build.done : 
	vivado -mode batch -source ./scripts/build.tcl -tempDir works -log build.log -jou build.jou

run:
	MODULE=$(MODULE); vivado -mode batch -source ./scripts/program.tcl -tempDir works -log program.log -jou program.jou

# delete everything except this Makefile
clean :	
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf
	rm -rf *.log
	rm -rf *.jou
	rm -rf works
	

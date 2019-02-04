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



# These are all the compilation targets, starting with "all"
all: first

##### Project first
first:firstSetup firstCompile firstSw

firstSetup: .firstSetup.done

.firstSetup.done:
	vivado -mode batch -source ./scripts/bdGen.tcl -tempDir works -log firstSetup.log -jou firstSetup.jou

firstCompile: .firstCompile.done
.firstCompile.done : 
	cmd /c "vivado -mode batch -source ./scripts/compile.tcl -tempDir works -log firstCompile.log -jou firstCompile.jou"

firstSw: .firstSw.done
.firstSw.done : 
	xsdk -batch -source ./scripts/swGen.tcl 

upload: 
	vivado -mode batch -source ./scripts/program.tcl -tempDir works -log program.log -jou program.jou

#
#	xsdk -batch -source ./scripts/swRun.tcl 

# delete everything except this Makefile
clean :	
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf
	rm -rf *.log
	rm -rf *.jou
	rm -rf works
	

# on windows you have to prefix vivado call with a cmd shell with /c
ifeq ($(UNAME), Linux)
PREFIX = ""
POSTFIX = ""
else
PREFIX = cmd /c "
POSTFIX = "
endif


PREFIX = ""
POSTFIX = ""

# these are the sources - everything depends upon them
# RTL=../hdl/top/top.v ../hdl/threeFlop/threeFlop.v
# XDC=../xdc/top.xdc ../xdc/top_io_simple.xdc

# These are all the compilation targets, starting with "all"
all: golden ledCtrl update


##### Project Led Ctrl
ledCtrl:setupLedCtrl compileLedCtrl

setupLedCtrl: .setupLedCtrl.done

.setupLedCtrl.done:
	vivado -mode batch -source ./scripts/setupLedCtrl.tcl -tempDir works -log setup.log -jou setup.jou

compileLedCtrl : .compileLedCtrl.done
.compileLedCtrl.done : 
	cmd /c "vivado -mode batch -source ./scripts/compileLedCtrl.tcl -log compile.log -jou compile.jou"


##### Project update
update:setupUpdate compileUpdate

setupUpdate: .setupUpdate.done

.setupUpdate.done:
	vivado -mode batch -source ./projUpdate.tcl -tempDir works -log setup.log -jou setup.jou

#	vivado -mode batch -source ./scripts/setupUpdate.tcl -force -tempDir works -log setupUpdate.log -jou setupUpdate.jou


compileUpdate : .compileUpdate.done
.compileUpdate.done : 
	cmd /c "vivado -mode batch -source ./scripts/compileUpdate.tcl -log compileUpdate.log -jou compileUpdate.jou"



##### Project Golden
golden:setupGolden compileGolden

# This setups up the top level project
setupGolden: .setupGolden.done

#.setupGolden.done:
#	vivado -mode batch -source ./goldenProj.tcl -tempDir works -log setup.log -jou setup.jou

#setupGolden : .setupGolden.done
#
.setupGolden.done:
	vivado -mode batch -source ./scripts/setupGolden.tcl -tempDir works -log setup.log -jou setup.jou


#.setup.done
compileGolden : .compileGolden.done
.compileGolden.done : 
	cmd /c "vivado -mode batch -source ./scripts/compileGolden.tcl -log compile.log -jou compile.jou"

# delete everything except this Makefile
clean :	
	find . -not -name "Makefile*" -not -name "." | xargs rm -rf

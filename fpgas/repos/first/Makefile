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
all: golden ledCtrl update picoUart

##### Project PicoBlaze + UART
picoUart:setupPicoUart compilePicoUart

setupPicoUart: .setupPicoUart.done

.setupPicoUart.done:
	vivado -mode batch -source ./scripts/picoUartSetup.tcl -tempDir works -log picoUartSetup.log -jou picoUartSetup.jou

compilePicoUart : .compilePicoUart.done
.compilePicoUart.done : 
	cmd /c "vivado -mode batch -source ./scripts/picoUartCompile.tcl -tempDir works -log picoUartCompile.log -jou picoUartCompile.jou"


##### Project Led Ctrl
ledCtrl:setupLedCtrl compileLedCtrl

setupLedCtrl: .setupLedCtrl.done

.setupLedCtrl.done:
	vivado -mode batch -source ./scripts/setupLedCtrl.tcl -tempDir works -log ledCtrlSetup.log -jou ledCtrlSetup.jou

compileLedCtrl : .compileLedCtrl.done
.compileLedCtrl.done : 
	cmd /c "vivado -mode batch -source ./scripts/compileLedCtrl.tcl -tempDir works -log ledCtrlCompile.log -jou ledCtrlCompile.jou"


##### Project update
update:setupUpdate compileUpdate

setupUpdate: .setupUpdate.done

.setupUpdate.done:
	vivado -mode batch -source ./scripts/setupUpdate.tcl -tempDir works -log updateSetup.log -jou updateSetup.jou


compileUpdate : .compileUpdate.done
.compileUpdate.done : 
	cmd /c "vivado -mode batch -source ./scripts/compileUpdate.tcl -tempDir works -log updateCompile.log -jou updateCompile.jou"



##### Project Golden
golden:setupGolden compileGolden

# This setups up the top level project
setupGolden: .setupGolden.done

#.setupGolden.done:
#	vivado -mode batch -source ./goldenProj.tcl -tempDir works -log goldenSetup.log -jou goldenSetup.jou

#setupGolden : .setupGolden.done
#
.setupGolden.done:
	vivado -mode batch -source ./scripts/setupGolden.tcl -tempDir works -log goldenSetup.log -jou goldenSetup.jou


#.setup.done
compileGolden : .compileGolden.done
.compileGolden.done : 
	cmd /c "vivado -mode batch -source ./scripts/compileGolden.tcl -tempDir works -log goldenCompile.log -jou goldenCompile.jou"

# delete everything except this Makefile
clean :	
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf
	rm -rf *.log
	rm -rf *.jou
	rm -rf works
	

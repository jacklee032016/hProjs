# Run in MinGW
# Jan.25, 2019,  Jack Lee

include $(RULE_DIR)/Rules.mak

HW_DEFINE_FILE=$(WORKSPACE)/$(HW_PROJECT)/$(HW_NAME)

# These are all the compilation targets, starting with "all"
all: run

##### Project first
first:setup compile bsp

setup: .setup.done

.setup.done:
	vivado -mode batch -source $(SCRIPT_DIR)/bdGen.tcl -tempDir works -log setup.log -jou setup.jou

compile: .compile.done
.compile.done : 
	vivado -mode batch -source $(SCRIPT_DIR)/compile.tcl -tempDir works -log compile.log -jou compile.jou

bsp: .bsp.done
.bsp.done : 
	xsdk -batch -source $(SCRIPT_DIR)/swGen.tcl 

download: fboot
	mkdir -p $(OUTPUT_DIR)
	updatemem -force -meminfo $(HW_DEFINE_FILE).mmi -bit $(HW_DEFINE_FILE).bit -data fsboot/fsboot.elf -proc $(HW_DESGIN)/microblaze_0 -out $(OUTPUT_DIR)/download.bit 

fboot:
	cd fsboot; make
	
upload:download
	vivado -mode batch -source $(SCRIPT_DIR)/program.tcl -tempDir works -log works/program.log -jou works/program.jou

	
run: upload
	xsdk -batch -source $(SCRIPT_DIR)/swRun.tcl 

#

# delete everything except this Makefile
clean :	
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf
	rm -rf *.log
	rm -rf *.jou
	rm -rf works
	

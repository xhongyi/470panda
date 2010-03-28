# make          <- runs simv (after compiling simv if needed)
# make simv     <- compile simv if needed (but do not run)
# make int      <- runs int_simv interactively (after compiling it if needed)
# make syn      <- runs syn_simv (after synthesizing if needed then 
#                                 compiling synsimv if needed)
# make syn_int  <- runs syn_int_simv interactively (much like make syn)
# make clean    <- remove files created during compilations (but not synthesis)
# make nuke     <- remove all files created during compilation and synthesis
#
# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be 
# similar to the information in those scripts but that seems hard to avoid.
#

VCS = vcs +v2k +vc -Mupdate -line -full64
LIB = /usr/caen/generic/mentor_lib-D.1/public/eecs470/verilog/lec25dscc25.v
INTFLAGS = -I +memcbk

# For visual debugger
VISFLAGS = -lncurses

all:    simv
	./simv | tee program.out

##### 
# Modify starting here
#####



MODULE		= 	pipeline


TESTBENCH = 	sys_defs.vh	    \
#testbench/$(MODULE)_test.v \
	 testbench/mem.v						\
	 testbench/pipe_print.c

SIMFILES =	verilog/$(MODULE).v	\
						verilog/prien.v \
						verilog/if_mod.v \
						verilog/id.v \
						verilog/rs.v \
						verilog/rob.v \
						verilog/mt.v \
						verilog/fl.v \
						verilog/alu_sim.v \
						verilog/alu_mul.v \
						verilog/prf.v \
						verilog/cdb.v \
						verilog/icache.v \
						verilog/cachemem.v 

SYNFILES = synth/$(MODULE).vg

# For visual debugger
VISTESTBENCH = $(TESTBENCH:testbench.v=visual_testbench.v) \
		testbench/visual_c_hooks.c

synth/$(MODULE).vg:        $(SIMFILES) synth/$(MODULE).tcl  #synth/prien.vg #synth/cachemem128x64.vg
	cd synth && dc_shell-t -f ./$(MODULE).tcl | tee $(MODULE)_synth.out 

#synth/prien.vg:  verilog/prien.v
#	cd synth && dc_shell-t -f ./prien.tcl | tee prien_synth.out
 

synth/cachemem128x64.vg:  verilog/cachemem.v
	cd synth && dc_shell-t -f ./icache.tcl | tee cachemem128x64_synth.out
 
#####
# Should be no need to modify after here
#####
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES)	-o simv

int:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(INTFLAGS) $(TESTBENCH) $(SIMFILES) -o int_simv -RI

# For visual debugger
vis_simv:	$(SIMFILES) $(VISTESTBENCH)
	$(VCS) $(VISFLAGS) $(VISTESTBENCH) $(SIMFILES) -o vis_simv 
	./vis_simv

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv 

syn:	syn_simv
	./syn_simv | tee syn_program.out

syn_int:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(INTFLAGS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_int_simv -RI

clean:
	rm -rf simv simv.daidir csrc vcs.key program.out
	rm -rf vis_simv vis_simv.daidir
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf int_simv int_simv.daidir syn_int_simv syn_int_simv.daidir
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out $(MODULE).out writeback.out vc_hdrs.h

nuke:	clean
	rm -f synth/*.vg synth/*.rep synth/*.db synth/*.chk synth/command.log
	rm -f synth/*.out synth/*.ddc command.log


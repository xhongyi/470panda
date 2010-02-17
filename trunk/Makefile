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

INTFLAGS = -I +memcbk

all:    simv
	./simv | tee program.out

##### 
# Modify starting here
#####

TESTBENCH = 	sys_defs.vh	    \
		testbench/testbench.v	\
		testbench/mem.v		    \
		testbench/pipe_print.c	\
		testbench/cachemem.v 
SIMFILES =	verilog/pipeline.v	\
		verilog/regfile.v	\
		verilog/icache.v	\
		verilog/if_stage.v	\
		verilog/id_stage.v	\
		verilog/ex_stage.v	\
		verilog/mem_stage.v	\
		verilog/wb_stage.v	
SYNFILES = synth/pipeline.vg /afs/engin.umich.edu/caen/generic/mentor_lib-D.1/public/eecs470/verilog/lec25dscc25.v

synth/pipeline.vg:        $(SIMFILES)
	cd synth && dc_shell -f ./pipeline.scr | tee synth.out 

#####
# Should be no need to modify after here
#####
simv:	$(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES)	-o simv -R

int:	$(SIMFILES) $(TESTBENCH) 
	$(VCS) $(INTFLAGS) $(TESTBENCH) $(SIMFILES) -o int_simv -RI

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) -o syn_simv 

syn:	syn_simv
	./syn_simv | tee syn_program.out

syn_int:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(INTFLAGS) $(TESTBENCH) $(SYNFILES) -o syn_int_simv -RI

clean:
	rm -rf simv simv.daidir csrc vcs.key program.out
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf int_simv int_simv.daidir syn_int_simv syn_int_simv.daidir
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out pipeline.out writeback.out vc_hdrs.h

nuke:	clean
	rm -f synth/*.vg synth/*.rep synth/*.db synth/*.chk synth/command.log
	rm -f synth/*.out command.log


# SIMULATOR = Questa for Mentor's QuestaSim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = Questa

RTL        = ../rtl/*
INC        = +incdir+../master_part +incdir+../slave_part +incdir+../test +incdir+../packages +incdir+../env
work       = work   # library name
SVTB1      = ../env/top.sv
SVTB2      = ../test/axi_pkg.sv
COVOP      = -coverage +cover=bcft
VSIMOPT    = -vopt -voptargs=+acc
VSIMCOV    = $(COVOP)
VSIMBATCH  = -c -do "log -r /* ; coverage save -onexit fixed_cov0; run -all; exit"
VSIMBATCH1 = -c -do "log -r /* ; coverage save -onexit incr_cov0; run -all; exit"
VSIMBATCH2 = -c -do "log -r /* ; coverage save -onexit wrap_cov0; run -all; exit"
VSIMBATCH3 = -c -do "log -r /* ; coverage save -onexit random_cov0; run -all; exit"

help:
	@echo "================================================================================="
	@echo "! USAGE      --  make target                                                    !"
	@echo "! clean      =>  clean the earlier log and intermediate files.                  !"
	@echo "! sv_cmp     =>  Create library and compile the code.                           !"
	@echo "! run_test1  =>  Clean, compile & run the fixed sequence test in batch mode.      !"
	@echo "! run_test2  =>  Clean, compile & run the incr sequence test in batch mode.     !"
	@echo "! run_test3  =>  Clean, compile & run the wrap sequence test in batch mode.        !"
	@echo "! run_test4  =>  Clean, compile & run the random sequence test in batch mode.        !"
	@echo "! view_wave1 =>  View waveform of fixed_seq_test                                !"
	@echo "! view_wave2 =>  View waveform of incr_seq_test                               !"
	@echo "! view_wave3 =>  View waveform of wrap_seq_test                                  !"
	@echo "! view_wave4 =>  View waveform of random_seq_test                                  !"
	@echo "================================================================================="

clean       : clean_$(SIMULATOR)
sv_cmp      : sv_cmp_$(SIMULATOR)
run_test1   : run_test1_$(SIMULATOR)
run_test2   : run_test2_$(SIMULATOR)
run_test3   : run_test3_$(SIMULATOR)
run_test4   : run_test4_$(SIMULATOR)
view_wave1  : view_wave1_$(SIMULATOR)
view_wave2  : view_wave2_$(SIMULATOR)
view_wave3  : view_wave3_$(SIMULATOR)
view_wave4  : view_wave4_$(SIMULATOR)
regress_12  : regress_12_$(SIMULATOR)
regress_123 : regress_123_$(SIMULATOR)
regress_1234 : regress_1234_$(SIMULATOR)
cov         : cov_$(SIMULATOR)

# ====================================================
# QuestaSim specific commands
# ====================================================

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1)

run_test1_Questa: sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH) -wlf wave_file1.wlf -l test1.log -sv_seed 147734295 work.top +UVM_TESTNAME=fixed_seq_test
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html fixed_cov0

run_test2_Questa: sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1) -wlf wave_file2.wlf -l test2.log -sv_seed 3669109994 work.top +UVM_TESTNAME=incr_seq_test
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html incr_cov0

run_test3_Questa: sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2) -wlf wave_file3.wlf -l test3.log -sv_seed 1957851890 work.top +UVM_TESTNAME=wrap_seq_test
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html wrap_cov0

run_test4_Questa: sv_cmp
	vsim $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3) -wlf wave_file3.wlf -l test4.log -sv_seed random work.top +UVM_TESTNAME=random_seq_test
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html random_cov0

view_wave1_Questa:
	vsim -view wave_file1.wlf

view_wave2_Questa:
	vsim -view wave_file2.wlf

view_wave3_Questa:
	vsim -view wave_file3.wlf

view_wave4_Questa:
	vsim -view wave_file4.wlf

report_12_Questa:
	vcover merge -out axi_cov fixed_cov0 incr_cov0
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi_cov

regress_12_Questa: clean_Questa sv_cmp_Questa run_test1_Questa run_test2_Questa report_12_Questa

report_123_Questa:
	vcover merge -out axi_cov fixed_cov0 incr_cov0 wrap_cov0
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi_cov

regress_123_Questa: clean_Questa sv_cmp_Questa run_test1_Questa run_test2_Questa run_test3_Questa report_123_Questa

report_1234_Questa:
	vcover merge -out axi_cov fixed_cov0 incr_cov0 wrap_cov0 random_cov0
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi_cov

regress_1234_Questa: clean_Questa sv_cmp_Questa run_test1_Questa run_test2_Questa run_test3_Questa run_test4_Questa report_1234_Questa

cov_Questa:
	firefox covhtmlreport/index.html &

clean_Questa:
	rm -rf transcript* *.log vsim.wlf fcover* covhtml* *cov* *.wlf modelsim.ini work
	clear

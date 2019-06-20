GIT_ROOT=$(shell git rev-parse --show-toplevel)
SIMSUSY=simsusy
MG5aMC=$(GIT_ROOT)/vendor/MG5_aMC/bin/mg5_aMC

.PHONY: all clean

all: $(TARGETS)

%.in: %.wls
	./$<

%.spec: %.in
	$(SIMSUSY) run --v1 mssm.tree_calculator $< $@

%.spec_for_mg5: %.in
	$(SIMSUSY) run mssm.mg5_tree_calculator $< $@.tmp
	yaslha extract SphenoLowEnergy,GM2MassInsertion $< | yaslha merge -e $@.tmp > $@
	rm $@.tmp

%.sdecay: %.spec susyhit.in
	cp $< slhaspectrum.in
	../vendor/SUSY-HIT/run
	mv susyhit_slha.out $@
	@rm slhaspectrum.in

%.mg5: %.spec_for_mg5
	echo "import model MSSM_SLHA2-full\ncompute_widths all --path=$< --body_decay=3.0025 --output=$@" | $(MG5aMC)

%.slha: %.sdecay %.in
	yaslha extract SphenoLowEnergy,GM2MassInsertion $*.in | yaslha merge -e $< sm_particles.patch > $@

clean:
	@rm -f $(TARGETS)

grid/tab1_%.in:
	M2=`echo $* | sed 's/_.*//' ` ;\
	ML=`echo $* | sed 's/.*_//' ` ;\
	./gen_grid.wls tab1 $$M2 $$ML

grid/tab2_%.in:
	M2=`echo $* | sed 's/_.*//' ` ;\
	ML=`echo $* | sed 's/.*_//' ` ;\
	./gen_grid.wls tab2 $$M2 $$ML

grid/tab3_%.in:
	M2=`echo $* | sed 's/_.*//' ` ;\
	ML=`echo $* | sed 's/.*_//' ` ;\
	./gen_grid.wls tab3 $$M2 $$ML

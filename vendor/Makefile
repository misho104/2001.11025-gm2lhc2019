.PHONY: relax init freeze
PYTHON2=`pyenv versions | grep 2\.\[67\]\. | sed 's/.*\(2\.[67]\.[0-9]*\).*/\1/'`

relax:
	@echo "usage: make GM2Calc"
	@echo "       make init"

GM2Calc:
	mkdir -p GM2Calc
	cd GM2Calc && cmake ../_GM2Calc

init: requirements.txt ../.gitmodules
	pip install --upgrade pip
	pip install -r requirements.txt
	git submodule init
	git submodule update
	make -C GM2Calc
	make -C SUSY-HIT
	# MG5
	echo $(PYTHON2) > MG5_aMC/.python-version
	# -patch -N -p1 -d MG5_aMC < MG5_aMC.patch

freeze:
	mv -f requirements.txt requirements.bak
	pip freeze -r requirements.bak > requirements.txt

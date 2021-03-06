# term2048's Makefile
#
SRC=term2048
VENV=venv
BINUTILS=$(VENV)/bin

PIP=$(BINUTILS)/pip

COVERFILE:=.coverage
COVERAGE_REPORT:=report -m

PY_VERSION:=$(subst ., ,$(shell python --version 2>&1 | cut -d' ' -f2))
PY_VERSION_MAJOR:=$(word 1,$(PY_VERSION))
PY_VERSION_MINOR:=$(word 2,$(PY_VERSION))
PY_VERSION_SHORT:=$(PY_VERSION_MAJOR).$(PY_VERSION_MINOR)

ifdef TRAVIS_PYTHON_VERSION
PY_VERSION_SHORT:=$(TRAVIS_PYTHON_VERSION)
endif

.DEFAULT: check-versions
.PHONY: check check-versions stylecheck covercheck

deps: $(VENV)
	$(PIP) install -qr requirements.txt
ifeq ($(PY_VERSION_SHORT),2.6)
	$(PIP) install -qr py26-requirements.txt
endif
ifneq ($(PY_VERSION_SHORT),3.3)
ifneq ($(PY_VERSION_SHORT),3.4)
	$(PIP) install -q wsgiref==0.1.2
endif
endif

$(VENV):
	virtualenv $@

check: deps
	$(BINUTILS)/python tests/test.py

check-versions: deps
	$(BINUTILS)/tox

stylecheck: deps
	$(BINUTILS)/pep8 $(SRC)

covercheck: deps
	$(BINUTILS)/coverage run --source=term2048 tests/test.py
	$(BINUTILS)/coverage $(COVERAGE_REPORT)

coverhtml:
	@make COVERAGE_REPORT=html covercheck
	@echo '--> open htmlcov/index.html'

clean:
	rm -f *~ */*~
	rm -f $(COVERFILE)

publish: deps check-versions
	$(BINUTILS)/python setup.py sdist upload

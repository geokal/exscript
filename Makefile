NAME=exscript
VERSION=`python setup.py --version`
PACKAGE=$(NAME)-$(VERSION)-1
PREFIX=/usr/local/
DISTDIR=/pub/code/releases/$(NAME)

###################################################################
# Standard targets.
###################################################################
.PHONY : clean
clean:
	find . -name "*.pyc" -o -name "*.pyo" | xargs -n1 rm -f
	rm -Rf build src/*.egg-info
	cd doc; make clean

.PHONY : dist-clean
dist-clean: clean
	rm -Rf dist $(PACKAGE)*

.PHONY : doc
doc:
	./version.sh
	cd doc; make
	./version.sh --reset

install:
	python setup.py install --prefix $(PREFIX)

uninstall:
	# Sorry, Python's distutils support no such action yet.

.PHONY : tests
tests:
	find tests -name run_suite.py | while read i; do \
		cd `dirname $$i`; \
		./`basename $$i`; \
		cd -; \
	done

###################################################################
# Package builders.
###################################################################
targz:
	./version.sh
	python setup.py sdist --formats gztar
	./version.sh --reset

tarbz:
	./version.sh
	python setup.py sdist --formats bztar
	./version.sh --reset

deb:
	./version.sh
	debuild -S -sa
	cd ..; sudo pbuilder build $(NAME)_$(VERSION)-0ubuntu1.dsc; cd -
	./version.sh --reset

dist: targz tarbz

###################################################################
# Publishers.
###################################################################
dist-publish: dist
	mkdir -p $(DISTDIR)/
	for i in dist/*; do \
		mv $$i $(DISTDIR)/`basename $$i | tr '[:upper:]' '[:lower:]'`; \
	done

.PHONY : doc-publish
doc-publish:
	./version.sh
	cd doc; make publish
	./version.sh --reset

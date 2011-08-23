NAME		:= dpkg
SVNURL		:= https://eris.llnl.gov/svn/lclocal/public/dpkg
BUILDURL	:= https://eris.llnl.gov/svn/buildfarm/trunk/build
VERSION 	:= $(shell awk '/[Vv]ersion:/ {print $$2}' META)
RELEASE		:= $(shell awk '/[Rr]elease:/ {print $$2}' META)
TRUNKURL	:= $(SVNURL)/trunk
TAGURL		:= $(SVNURL)/tags/$(VERSION)-$(RELEASE)
CONFIGOPTS	:= $(shell scripts/configopts.sh) --sysconfdir=/etc \
		   --mandir=/usr/share/man

all: $(NAME)+chaos .config
	make -C $(NAME)+chaos 

quilt $(NAME)+chaos: patches/series
	make clean	
	@scripts/quilt.sh -p $(NAME) -q -e chaos

.config: $(NAME)+chaos
	pushd $(NAME)+chaos && ./configure $(CONFIGOPTS) && popd
	touch .config
	
rpms-working: clean build
	make clean
	./build --snapshot . 
rpms-trunk: build
	./build --snapshot $(TRUNKURL)
rpms-release: build
	./build --project-release=$(RELEASE) $(TAGURL)
tagrel:
	svn copy $(TRUNKURL) $(TAGURL)
build:
	svn cat $(BUILDURL) >$@
	chmod +x $@

clean:
	rm -rf $(NAME)+chaos
	rm -f .config
	rm -f *.rpm *.bz2
	
veryclean: clean
	rm -f build

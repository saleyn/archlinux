ifneq (,$(package))
  PACKAGE=$(package)
else ifneq (,$(p))
  PACKAGE=$(p)
else
  $(error Missing 'package=' option!)
endif

all: build

build: build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst

ci ic: clear install

c clear remove:
	./install.sh -c -p $(PACKAGE)

i inst install: build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst
	[ -f build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst ] && \
    sudo pacman -U build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst --noconfirm

build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst:
	./install.sh --force -p $(PACKAGE)$(if $(noextract), -e)$(if $(jobs), -j $(jobs))

help:
	@echo "Make/install package:"
	@echo "  make [install] [noextract=1] package=Package"
	@echo "  make [install] [noextract=1] p=Package"
	@echo
	@echo "This will just repackage without rebuilding:"
	@echo "  SKIP_BUILD=1 make noextract=1 p=Package"

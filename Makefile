ifneq (,$(package))
  PACKAGE=$(package)
else ifneq (,$(p))
  PACKAGE=$(p)
else
  $(error Missing 'package=' option!)
endif

all:
	./install.sh --force -p $(PACKAGE)$(if $(noextract), -e)$(if $(jobs), -j $(jobs))

i inst install:
	[ -f build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst ] && \
    sudo pacman -U build/$(PACKAGE)/$(PACKAGE)-*.pkg.tar.zst --noconfirm

help:
	@echo "Make/install package:"
	@echo "  make [install] [noextract=1] package=Package"
	@echo "  make [install] [noextract=1] p=Package"
	@echo
	@echo "This will just repackage without rebuilding:"
	@echo "  SKIP_BUILD=1 make noextract=1 p=Package"

ifneq (,$(package))
  # ok
else ifneq (,$(p))
  # ok
else
  $(error Missing 'package=' option!)
endif

all:
	./install.sh --force -p $(package)$(p)$(if $(noextract), -e)$(if $(jobs), -j $(jobs))

i inst install:
	[ -f build/$(package)/$(package)-*.pkg.tar.zst ] && \
    sudo pacman -U build/$(package)/$(package)-*.pkg.tar.zst --noconfirm

help:
	@echo "make package=Package"
	@echo "make p=Package"



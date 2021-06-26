ifneq (,$(package))
  # ok
else ifneq (,$(p))
  # ok
else
  $(error Missing 'package=' option!)
endif

all:
	./install.sh --force -i -p $(package)$(p)

inst install:
	[ -f build/$(package)/$(package)-*.pkg.tar.zst ] && \
    sudo pacman -U build/$(package)/$(package)-*.pkg.tar.zst #--noconfirm

help:
	@echo "make package=Package"
	@echo "make p=Package"



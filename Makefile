ifneq (,$(package))
  # ok
else ifneq (,$(p))
  # ok
else
  $(error Missing 'package=' option!)
endif

all:
	./install.sh --force -i -p $(package)$(p)

help:
	@echo "make package=Package"
	@echo "make p=Package"



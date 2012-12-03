.PHONY: all clean testbench

VCDFILE = tmp
STOPTIME = 100ms
DEBUG = --vcd=$(VCDFILE) --stop-time=$(STOPTIME)
CLEANUP = rm -f $(VCDFILE)
OBJS = clock.o
TARGET =

all:
	make test

clean:
	ghdl --clean

test:
	ghdl -a *.vhd
	ghdl -e $(TARGET)
	ghdl -r $(TARGET) $(DEBUG)
	gtkwave $(VCDFILE)
	$(CLEANUP)

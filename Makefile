CC := g++
INCDIR := include
SRCDIR := src
BUILDDIR := build
BINDIR := bin
SRCEXT := cpp
CFLAGS := -g -Wall -Wno-psabi
LIB := -lwiringPi
INC := -I $(INCDIR)

# https://stackoverflow.com/a/39895302/570787
ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

# Add additional libs for building on travis
ifeq ($(TRAVIS),true)
	LIB := $(LIB) -lrt -lcrypt -pthread
endif

.PHONY: all
all: dirs $(BUILDDIR)/libhx711.a test hx711calibration main

.PHONY: dirs
dirs:
	mkdir -p $(BINDIR)
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/libhx711.a: $(BUILDDIR)/HX711.o
	ar rcs $(BUILDDIR)/libhx711.a $(BUILDDIR)/HX711.o
	ranlib $(BUILDDIR)/libhx711.a

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	$(CC) $(CFLAGS) $(INC) -c -o $@ $<

.PHONY: hx711calibration
hx711calibration: $(BUILDDIR)/Calibration.o
	$(CC) $(CFLAGS) $(INC) -o $(BINDIR)/hx711calibration $(BUILDDIR)/Calibration.o -L $(BUILDDIR)/ -lhx711 $(LIB)

.PHONY: test
test: $(BUILDDIR)/test.o
	$(CC) $(CFLAGS) $(INC) -o $(BINDIR)/test $(BUILDDIR)/test.o -L $(BUILDDIR)/ -lhx711 $(LIB)

.PHONY: main
main: $(BUILDDIR)/main.o
	$(CC) $(CFLAGS) $(INC) -o $(BINDIR)/main $(BUILDDIR)/main.o -L $(BUILDDIR)/ -lhx711 $(LIB)

.PHONY: clean
clean:
	$(RM) -r $(BUILDDIR)/*
	$(RM) -r $(BINDIR)/*

.PHONY: install
install: $(BUILDDIR)/libhx711.a $(BINDIR)/hx711calibration
	install -d $(DESTDIR)$(PREFIX)/lib/
	install -m 644 $(BUILDDIR)/libhx711.a $(DESTDIR)$(PREFIX)/lib/
	install -d $(DESTDIR)$(PREFIX)/include/
	install -m 644 $(INCDIR)/HX711.h $(DESTDIR)$(PREFIX)/include/

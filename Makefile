# write the path to the caml-light library here
LIBDIR:=$(shell ocamlc -where)
BINDIR:=$(shell bash script/bindir)
ROOTDIR:=$(shell bash script/dirname)

CAMLC = ocamlc -g
CAMLO = ocamlopt
CAMLDEP = ocamldep 
CAMLMKTOP = ocamlmktop
CAMLLIB = ocamlmklib
CFLAGS =

ZFLAGS =  
LINKFLAGS = unix.cma

LINKTMP =$(LINKFLAGS:.cmo=.cmx)
LINKFLAGSO = $(LINKTMP:.cma=.cmxa)

#you should not need any modification after this line

FILES = ptmap.ml bindlib.ml nvbindlib.ml

FILESI =  $(FILES:.ml=.mli)

FILESO =  $(FILES:.ml=.cmo)

FILESX = $(FILES:.ml=.cmx)

all: bindlib.cmxa bindlib.cma nvbindlib.cmxa nvbindlib.cma \
     camlp4bo camlp4nvbo camlp4bop camlp4nvbop

checkconfig:
	echo LIBDIR=$(LIBDIR); echo BINDIR=$(BINDIR)

bindlib.cmx: bindlib.cmi bindlib.ml
	$(CAMLO) -c -unsafe $(ZFLAGS) -inline 20 -c bindlib.ml

bindlib.cmo: bindlib.cmi bindlib.ml
	$(CAMLC) -c -unsafe $(ZFLAGS) -c bindlib.ml

bindlib.cma: bindlib.cmo ptmap.cmo
	$(CAMLC) -a -o bindlib.cma ptmap.cmo bindlib.cmo

bindlib.cmxa: bindlib.cmx ptmap.cmx
	$(CAMLO) -a -o bindlib.cmxa ptmap.cmx bindlib.cmx

nvbindlib.cmo: nvbindlib.ml nvbindlib.cmi
	$(CAMLC) -c $(ZFLAGS) -unsafe -c nvbindlib.ml

nvbindlib.cmx: nvbindlib.ml nvbindlib.cmi
	$(CAMLO) -c $(ZFLAGS) -unsafe -inline 20 -c nvbindlib.ml

nvbindlib.cma: nvbindlib.cmo ptmap.cmo
	$(CAMLC) -a -o nvbindlib.cma ptmap.cmo nvbindlib.cmo

nvbindlib.cmxa: nvbindlib.cmx ptmap.cmx
	$(CAMLO) -a -o nvbindlib.cmxa ptmap.cmx nvbindlib.cmx 

plexer.cmi: plexer.mli
	$(CAMLC) -pp "camlp4r -loc _loc"  -I +camlp4 -c plexer.mli

plexer.cmo: plexer.cmi plexer.ml
	$(CAMLC) -pp "camlp4r -loc _loc"  -I +camlp4 -c plexer.ml

pa_bindlib.cmo: bindlib.cmi pa_bindlib.ml plexer.cmo
	$(CAMLC) -pp "camlp4 ./plexer.cmo pa_o.cmo pa_extend.cmo q_MLast.cmo pr_dump.cmo -loc _loc"  -I +camlp4 -c pa_bindlib.ml

camlp4bo: pa_bindlib.cmo
	$(CAMLC) -linkall -I +camlp4 odyl.cma camlp4.cma ./plexer.cmo pa_o.cmo pa_bindlib.cmo pr_dump.cmo odyl.cmo -o camlp4bo

camlp4bop: pa_bindlib.cmo
	$(CAMLC) -linkall -I +camlp4 odyl.cma camlp4.cma ./plexer.cmo pa_o.cmo pa_op.cmo pa_bindlib.cmo pr_dump.cmo odyl.cmo -o camlp4bop

pa_nvbindlib.cmo: nvbindlib.cmi pa_nvbindlib.ml  plexer.cmo
	$(CAMLC) -pp "camlp4 ./plexer.cmo pa_o.cmo pa_extend.cmo q_MLast.cmo pr_dump.cmo -loc _loc"  -I +camlp4 -c pa_nvbindlib.ml

camlp4nvbo: pa_nvbindlib.cmo
	$(CAMLC) -linkall -I +camlp4 odyl.cma camlp4.cma ./plexer.cmo pa_o.cmo pa_nvbindlib.cmo pr_dump.cmo odyl.cmo -o camlp4nvbo

camlp4nvbop: pa_nvbindlib.cmo
	$(CAMLC) -linkall -I +camlp4 odyl.cma camlp4.cma ./plexer.cmo pa_o.cmo pa_op.cmo pa_nvbindlib.cmo pr_dump.cmo odyl.cmo -o camlp4nvbop

install: 
	cp bindlib.cmxa bindlib.a bindlib.cma bindlib.cmi bindlib.mli $(LIBDIR)
	cp nvbindlib.cmxa nvbindlib.a nvbindlib.cma nvbindlib.cmi nvbindlib.mli $(LIBDIR)
	cp pa_bindlib.cmo pa_nvbindlib.cmo $(LIBDIR)/camlp4
	cp camlp4bo camlp4nvbo camlp4bop camlp4nvbop $(BINDIR)

bench: dum
	cd bench; make bench benchopt

examples: dum
	cd examples; make all

depend:
	rm dependfile; \
	$(CAMLDEP) $(FILES) $(FILESI) > dependfile

clean:
	- rm *.cmx *.cmo *.cmi *.o *~ a.out *.cma *.cmxa *.a *.so \
          camlp4o camlp4nvbo camlp4op camlp4nvbop  \#*\#
	cd bench; make clean
	cd examples; make clean
	cd doc; make clean

.SUFFIXES : .mli .ml .cmi .cmx .cmo .o .mll .mly

.mli.cmi:
	$(CAMLC) $(ZFLAGS) -c $<

.ml.cmo:
	$(CAMLC) $(ZFLAGS) -c $<

.ml.cmx: 
	$(CAMLO) $(ZFLAGS) -c $<

.mll.ml:
	$(CAMLLEX) $<

.mly.ml:
	$(CAMLYACC) $<

check: all
	cd bench; make check
	cd examples; make check

compile-doc:
	cd doc; make

distrib: compile-doc clean
	cd ..; tar cvzf $(ROOTDIR)/archive/$(ROOTDIR).tgz \
	  --exclude cache --exclude pts --exclude archive\
	  --exclude _darcs $(ROOTDIR)

dum:

include dependfile



# write the path to the caml-light library here
LIBDIR =$(shell ocamlc -where)
BINDIR =$(shell bash script/bindir)
ROOTDIR =$(shell bash script/dirname)

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

FILESX = $(FILES:.ml=.cmx)

all: bindlib.cmxa bindlib.cma nvbindlib.cmxa nvbindlib.cma \
     pa_bindlib.cmo pa_nvbindlib.cmo \
     camlp4bo camlp4nvbo camlp4bof camlp4nvbof

pa_bindlib.ml: pa_bindlib-3.10.ml
	cp pa_bindlib-3.10.ml pa_bindlib.ml

pa_nvbindlib.ml: pa_nvbindlib-3.10.ml
	cp pa_nvbindlib-3.10.ml pa_nvbindlib.ml

checkconfig:
	echo LIBDIR=$(LIBDIR); echo BINDIR=$(BINDIR)

bindlib.cmx: bindlib.cmi bindlib.ml
	$(CAMLO) -c $(ZFLAGS) -unsafe -inline 20 -c bindlib.ml

bindlib.cmo: bindlib.cmi bindlib.ml
	$(CAMLC) -c $(ZFLAGS) -c bindlib.ml

bindlib.cma: bindlib.cmo ptmap.cmo
	$(CAMLC) -a -o bindlib.cma ptmap.cmo bindlib.cmo

bindlib.cmxa: bindlib.cmx ptmap.cmx
	$(CAMLO) -a -o bindlib.cmxa ptmap.cmx bindlib.cmx

nvbindlib.cmo: nvbindlib.ml nvbindlib.cmi
	$(CAMLC) -c $(ZFLAGS) -c nvbindlib.ml

nvbindlib.cmx: nvbindlib.ml nvbindlib.cmi
	$(CAMLO) -c $(ZFLAGS) -unsafe -inline 20 -c nvbindlib.ml

nvbindlib.cma: nvbindlib.cmo ptmap.cmo
	$(CAMLC) -a -o nvbindlib.cma ptmap.cmo nvbindlib.cmo

nvbindlib.cmxa: nvbindlib.cmx ptmap.cmx
	$(CAMLO) -a -o nvbindlib.cmxa ptmap.cmx nvbindlib.cmx 

pa_bindlib.cmo: bindlib.cmi pa_bindlib.ml
	$(CAMLC) -pp "camlp4orf"  -I +camlp4 -c pa_bindlib.ml

pa_nvbindlib.cmo: nvbindlib.cmi pa_nvbindlib.ml
	$(CAMLC) -pp "camlp4orf"  -I +camlp4 -c pa_nvbindlib.ml

camlp4bo: pa_bindlib.cmo
	$(CAMLC) -linkall -I +camlp4 dynlink.cma camlp4lib.cma                 \
        unix.cma                                               \
        Camlp4Parsers/Camlp4OCamlRevisedParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4QuotationCommon.cmo         \
        camlp4/Camlp4Parsers/Camlp4QuotationExpander.cmo       \
        camlp4/Camlp4Parsers/Camlp4OCamlParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4OCamlRevisedParserParser.cmo \
        camlp4/Camlp4Parsers/Camlp4OCamlParserParser.cmo       \
        camlp4/Camlp4Parsers/Camlp4GrammarParser.cmo           \
        pa_bindlib.cmo                                         \
        Camlp4Printers/Camlp4AutoPrinter.cmo                   \
        Camlp4Bin.cmo -o camlp4bo

camlp4bof: pa_bindlib.cmo
	$(CAMLC) -linkall -I +camlp4 dynlink.cma camlp4lib.cma                 \
        unix.cma                                               \
        Camlp4Parsers/Camlp4OCamlRevisedParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4QuotationCommon.cmo         \
        camlp4/Camlp4Parsers/Camlp4QuotationExpander.cmo       \
        camlp4/Camlp4Parsers/Camlp4OCamlParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4OCamlRevisedParserParser.cmo \
        camlp4/Camlp4Parsers/Camlp4OCamlParserParser.cmo       \
        camlp4/Camlp4Parsers/Camlp4GrammarParser.cmo           \
        camlp4/Camlp4Parsers/Camlp4MacroParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4ListComprehension.cmo       \
        pa_bindlib.cmo                                         \
        Camlp4Printers/Camlp4AutoPrinter.cmo                   \
        Camlp4Bin.cmo -o camlp4bof

camlp4nvbo: pa_nvbindlib.cmo
	$(CAMLC) -linkall -I +camlp4 dynlink.cma camlp4lib.cma                 \
        unix.cma                                               \
        Camlp4Parsers/Camlp4OCamlRevisedParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4QuotationCommon.cmo         \
        camlp4/Camlp4Parsers/Camlp4QuotationExpander.cmo       \
        camlp4/Camlp4Parsers/Camlp4OCamlParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4OCamlRevisedParserParser.cmo \
        camlp4/Camlp4Parsers/Camlp4OCamlParserParser.cmo       \
        camlp4/Camlp4Parsers/Camlp4GrammarParser.cmo           \
        pa_nvbindlib.cmo                                       \
        Camlp4Printers/Camlp4AutoPrinter.cmo                   \
        Camlp4Bin.cmo -o camlp4nvbo

camlp4nvbof: pa_nvbindlib.cmo
	$(CAMLC) -linkall -I +camlp4 dynlink.cma camlp4lib.cma                 \
        unix.cma                                               \
        Camlp4Parsers/Camlp4OCamlRevisedParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4QuotationCommon.cmo         \
        camlp4/Camlp4Parsers/Camlp4QuotationExpander.cmo       \
        camlp4/Camlp4Parsers/Camlp4OCamlParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4OCamlRevisedParserParser.cmo \
        camlp4/Camlp4Parsers/Camlp4OCamlParserParser.cmo       \
        camlp4/Camlp4Parsers/Camlp4GrammarParser.cmo           \
        camlp4/Camlp4Parsers/Camlp4MacroParser.cmo             \
        camlp4/Camlp4Parsers/Camlp4ListComprehension.cmo       \
        pa_nvbindlib.cmo                                       \
        Camlp4Printers/Camlp4AutoPrinter.cmo                   \
        Camlp4Bin.cmo -o camlp4nvbof

install: 
	if [ ! -d $(LIBDIR) ]; then mkdir -p $(LIBDIR); fi
	if [ ! -d $(LIBDIR)/camlp4 ]; then mkdir -p $(LIBDIR)/camlp4; fi
	if [ ! -d $(BINDIR) ]; then mkdir -p $(BINDIR); fi
	cp bindlib.cmxa bindlib.a bindlib.cma bindlib.cmi bindlib.mli $(LIBDIR)
	cp nvbindlib.cmxa nvbindlib.a nvbindlib.cma nvbindlib.cmi nvbindlib.mli $(LIBDIR)
	cp pa_bindlib.cmo pa_nvbindlib.cmo $(LIBDIR)/camlp4
	cp camlp4bo camlp4nvbo camlp4bof camlp4nvbof $(BINDIR)


bench: dum
	cd bench; make bench benchopt

examples: dum
	cd examples; make all

depend:
	rm dependfile; \
	$(CAMLDEP) $(FILES) $(FILESI) > dependfile

clean:
	- rm *.cmx *.cmo *.cmi *.o *~ a.out *.cma *.cmxa *.a *.so \
          camlp4bo camlp4nvbo camlp4bof camlp4nvbof \
	  pa_bindlib.ml  pa_nvbindlib.ml \#*\#
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
	- rm Makefile
	cd ..; tar cvzf $(ROOTDIR)/archive/$(ROOTDIR).tar.gz \
	  --exclude cache --exclude archive\
	  --exclude _darcs $(ROOTDIR)

dum:

include dependfile


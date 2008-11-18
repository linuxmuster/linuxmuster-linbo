.EXPORT_ALL_VARIABLES:

TOPDIR		= ./
TEXFILES	= $(wildcard *.tex)
PDFFILES	= $(TEXFILES:.tex=.pdf)

all: $(PDFFILES)

%.pdf : %.tex
	pdflatex $<
	grep -q Rerun $(<:.tex=.log) && pdflatex $< || true

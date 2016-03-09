TEX_FILE_NAME=slides

default: all

all: 
	make clean
	make compile
	make clean

compile:
	pdflatex ${TEX_FILE_NAME}
	pdflatex ${TEX_FILE_NAME}

clean:
	rm -f *.acn *.alg *.aux *.bbl *.blg *.brf *.glsdefs *.fls *.glo *.ilg *.ind *.ist *.lof *.log *.lol *.lot *.maf *.mtc* *.nav *.out *.snm *.spl *.synctex.* *.toc *.upa *.upb *.vrb 2> /dev/null
	@find . -name "*.fdb_latexmk" -exec rm -rf {} \;

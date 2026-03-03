# Makefile для презентации

.PHONY: all pdf clean

all: pdf

pdf:
	@echo "📄 Компиляция презентации..."
	pandoc presentation.md -t beamer -o presentation.pdf \
		--pdf-engine=lualatex \
		-V theme:metropolis \
		-V classoption:utf8 \
		--citeproc
	@echo "✅ Презентация создана: presentation.pdf"
	@xdg-open presentation.pdf

xelatex:
	@echo "📄 Компиляция презентации через xelatex..."
	pandoc presentation.md -t beamer -o presentation.pdf \
		--pdf-engine=xelatex \
		-V theme:metropolis \
		-V classoption:utf8 \
		--citeproc
	@echo "✅ Презентация создана: presentation.pdf"
	@xdg-open presentation.pdf

simple:
	@echo "📄 Компиляция без beamer (простой PDF)..."
	pandoc presentation.md -o presentation.pdf \
		--pdf-engine=lualatex
	@echo "✅ PDF создан: presentation.pdf"
	@xdg-open presentation.pdf

clean:
	rm -f presentation.pdf

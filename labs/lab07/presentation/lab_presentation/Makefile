# Makefile для презентации

.PHONY: all pdf html clean

all: pdf html

pdf:
	@echo "📄 Компиляция презентации в PDF..."
	pandoc presentation.md -t beamer -o presentation.pdf \
		--pdf-engine=lualatex \
		-V theme:metropolis \
		-V classoption:utf8 \
		--citeproc
	@echo "✅ PDF создан: presentation.pdf"
	@xdg-open presentation.pdf 2>/dev/null || open presentation.pdf 2>/dev/null || echo "   PDF: presentation.pdf"

# Компиляция в HTML (слайд-шоу)
html:
	@echo "🌐 Компиляция презентации в HTML..."
	pandoc presentation.md -t slidy -o presentation.html \
		--self-contained \
		--citeproc
	@echo "✅ HTML создан: presentation.html"
	@xdg-open presentation.html 2>/dev/null || open presentation.html 2>/dev/null || echo "   HTML: presentation.html"

# Альтернативные форматы HTML
html-revealjs:
	@echo "🌐 Компиляция в reveal.js HTML..."
	pandoc presentation.md -t revealjs -o presentation-revealjs.html \
		--self-contained \
		--citeproc \
		-V theme:white
	@echo "✅ reveal.js HTML создан: presentation-revealjs.html"
	@xdg-open presentation-revealjs.html 2>/dev/null || open presentation-revealjs.html 2>/dev/null || echo "   HTML: presentation-revealjs.html"

html-dzslides:
	@echo "🌐 Компиляция в dzslides HTML..."
	pandoc presentation.md -t dzslides -o presentation-dzslides.html \
		--self-contained \
		--citeproc
	@echo "✅ dzslides HTML создан: presentation-dzslides.html"
	@xdg-open presentation-dzslides.html 2>/dev/null || open presentation-dzslides.html 2>/dev/null || echo "   HTML: presentation-dzslides.html"

# Компиляция через xelatex (запасной вариант для PDF)
xelatex:
	@echo "📄 Компиляция презентации через xelatex..."
	pandoc presentation.md -t beamer -o presentation.pdf \
		--pdf-engine=xelatex \
		-V theme:metropolis \
		-V classoption:utf8 \
		--citeproc
	@echo "✅ PDF создан: presentation.pdf"
	@xdg-open presentation.pdf 2>/dev/null || open presentation.pdf 2>/dev/null || echo "   PDF: presentation.pdf"

# Простой PDF (без beamer)
simple:
	@echo "📄 Компиляция простого PDF..."
	pandoc presentation.md -o presentation.pdf \
		--pdf-engine=lualatex \
		--citeproc
	@echo "✅ PDF создан: presentation.pdf"
	@xdg-open presentation.pdf 2>/dev/null || open presentation.pdf 2>/dev/null || echo "   PDF: presentation.pdf"

# Очистка
clean:
	@echo "🧹 Очистка..."
	rm -f presentation.pdf presentation.html presentation-revealjs.html presentation-dzslides.html
	@echo "✅ Готово"

# Справка
help:
	@echo "Доступные команды:"
	@echo "  make              - компиляция PDF и HTML (slidy)"
	@echo "  make all          - компиляция PDF и HTML (slidy)"
	@echo "  make pdf          - компиляция PDF (beamer)"
	@echo "  make html         - компиляция HTML (slidy)"
	@echo "  make html-revealjs - компиляция HTML (reveal.js)"
	@echo "  make html-dzslides - компиляция HTML (dzslides)"
	@echo "  make xelatex      - компиляция PDF через xelatex"
	@echo "  make simple       - компиляция простого PDF"
	@echo "  make clean        - очистка созданных файлов"
	@echo "  make help         - показать эту справку"

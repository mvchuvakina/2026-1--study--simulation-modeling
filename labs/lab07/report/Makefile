# Makefile для компиляции отчёта через pandoc

.PHONY: all pdf docx clean help

# Исходный файл
SOURCE = report.qmd
OUTPUT_PDF = report.pdf
OUTPUT_DOCX = report.docx

# Цель по умолчанию
all: pdf docx

# Компиляция PDF через pandoc
pdf:
	@echo "📄 Компиляция PDF через pandoc..."
	pandoc $(SOURCE) \
		--filter pandoc-crossref \
		--pdf-engine=lualatex \
		--pdf-engine-opt=--shell-escape \
		--citeproc \
		--number-sections \
		--bibliography=bib/cite.bib \
		-V mainfont="FreeSerif" \
		-V sansfont="FreeSans" \
		-V monofont="FreeMono" \
		-V mathfont="FreeSerif" \
		--include-in-header=preamble.tex \
		-o $(OUTPUT_PDF)
	@echo "✅ PDF создан: $(OUTPUT_PDF)"
	@xdg-open $(OUTPUT_PDF) 2>/dev/null || open $(OUTPUT_PDF) 2>/dev/null || echo "   PDF создан: $(OUTPUT_PDF)"

# Компиляция DOCX через pandoc
docx:
	@echo "📄 Компиляция DOCX через pandoc..."
	pandoc $(SOURCE) \
		--filter pandoc-crossref \
		--citeproc \
		--number-sections \
		--bibliography=bib/cite.bib \
		-o $(OUTPUT_DOCX)
	@echo "✅ DOCX создан: $(OUTPUT_DOCX)"
	@xdg-open $(OUTPUT_DOCX) 2>/dev/null || open $(OUTPUT_DOCX) 2>/dev/null || echo "   DOCX создан: $(OUTPUT_DOCX)"

# Очистка
clean:
	@echo "🧹 Очистка..."
	rm -f $(OUTPUT_PDF) $(OUTPUT_DOCX)
	rm -f *.aux *.log *.out *.toc *.synctex.gz
	@echo "✅ Готово!"

# Справка
help:
	@echo "Доступные команды:"
	@echo "  make        - компиляция PDF и DOCX"
	@echo "  make pdf    - компиляция только PDF"
	@echo "  make docx   - компиляция только DOCX"
	@echo "  make clean  - очистить созданные файлы"
	@echo "  make help   - показать эту справку"

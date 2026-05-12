# Makefile для компиляции отчёта

.PHONY: all pdf docx clean

all: pdf docx

pdf:
	@echo "📄 Компиляция PDF..."
	pandoc "report.md" \
		--filter pandoc-crossref \
		--pdf-engine=lualatex \
		--pdf-engine-opt=--shell-escape \
		--citeproc \
		--number-sections \
		--bibliography=bib/cite.bib \
		-o "report.pdf"
	@echo "✅ PDF создан: report.pdf"
	@xdg-open report.pdf || open report.pdf || start report.pdf

docx:
	@echo "📄 Компиляция DOCX..."
	pandoc "report.md" \
		--filter pandoc-crossref \
		--citeproc \
		--number-sections \
		--bibliography=bib/cite.bib \
		-o "report.docx"
	@echo "✅ DOCX создан: report.docx"

clean:
	@echo "🧹 Очистка..."
	rm -f *.aux *.log *.out *.toc *.synctex.gz
	rm -f report.pdf report.docx
	@echo "✅ Готово"
	


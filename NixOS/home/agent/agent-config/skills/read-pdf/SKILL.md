---
name: read-pdf
description: Inspect and understand PDF documents using metadata inspection, text extraction, page rendering, and OCR. Use when answering questions about a PDF, summarizing a PDF, locating claims or passages, or interpreting equations, figures, tables, scans, and complex page layouts in PDF files.
---

# Read PDF

Extract searchable text first, then visually verify every part whose meaning
depends on layout. Preserve the source PDF and put derived files in a temporary
directory.

## Workflow

1. Inspect the document before reading it.

    ```bash
    pdfinfo document.pdf
    ```

    Record the page count and check for encryption.
    Do not attempt to bypass access controls.

2. Extract text while retaining approximate layout.

    ```bash
    workdir="$(mktemp -d)"
    pdftotext -layout document.pdf "$workdir/document.txt"
    ```

    Search the extracted text to locate relevant sections. Treat extraction order
    as provisional for multi-column pages, footnotes, tables, and marginal text.

3. Detect image-only or poorly extracted documents. If the extracted text is
   empty, severely garbled, or clearly incomplete, create a searchable copy with
   OCR and extract from that copy.

    ```bash
    ocrmypdf --skip-text -l jpn+eng document.pdf "$workdir/document-ocr.pdf"
    pdftotext -layout "$workdir/document-ocr.pdf" "$workdir/document-ocr.txt"
    ```

    Select only the languages supported by the installed OCR data and actually
    present in the document. Clearly label text inferred from OCR because it may
    contain recognition errors.

4. Render relevant pages whenever layout affects interpretation.

    ```bash
    pdftoppm -png -r 150 -f 3 -l 3 document.pdf "$workdir/page"
    ```

    Inspect the resulting image directly. Always perform visual verification for:

    - equations and mathematical notation;
    - figures, diagrams, plots, and captions;
    - tables and aligned columns;
    - multi-column reading order;
    - footnotes, annotations, and unusual typography;
    - passages on which a precise quotation or important conclusion depends.

5. Answer from the verified content. Distinguish the document's explicit claims
   from interpretation or inference. Include PDF page numbers for important
   claims and quotations. If printed page labels differ from the PDF page index,
   identify which numbering system is used.

## Reliability Rules

- Do not infer missing symbols or table cells solely from `pdftotext` output.
- Do not present OCR output as an exact quotation without checking the page image.
- Use short quotations only when needed; otherwise paraphrase faithfully.
- State which pages or sections could not be read.
- Remove the temporary directory after completing the task unless its artifacts
  are needed for continuing work.

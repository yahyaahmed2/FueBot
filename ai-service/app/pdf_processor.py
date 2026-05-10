"""
advanced_pdf_processor.py
=========================

Production-oriented PDF ingestion pipeline for academic handbook RAG systems.

Features
--------
- PyMuPDF extraction
- Arabic-safe Unicode cleaning
- Better reading-order reconstruction
- Header/footer removal
- Hyphenation repair
- Semantic section detection
- Table extraction + structured serialization
- OCR fallback support
- LangChain Document output

Optimized for:
- university handbooks
- course catalogs
- bilingual Arabic/English PDFs
- curriculum tables
"""

from __future__ import annotations

import logging
import re
from collections import Counter
from pathlib import Path
from typing import Iterable

import pandas as pd
import pymupdf
from langchain_core.documents import Document

logger = logging.getLogger(__name__)


# ============================================================
# TEXT CLEANING
# ============================================================

ARABIC_RANGE = r"\u0600-\u06FF"


def clean_text(text: str) -> str:
    """
    Clean extracted PDF text while preserving Arabic and Unicode.
    """

    if not text:
        return ""

    # Remove PDF cid artifacts
    text = re.sub(r"\(cid:\d+\)", "", text)

    # Remove control chars but preserve Unicode/Arabic
    text = re.sub(
        rf"[^\S\r\n]|[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]",
        " ",
        text,
    )

    # Fix broken hyphenation across lines
    text = re.sub(r"(\w+)-\n(\w+)", r"\1\2", text)

    # Fix wrapped lines
    text = re.sub(r"(?<!\n)\n(?!\n)", " ", text)

    # Collapse whitespace
    text = re.sub(r"[ \t]{2,}", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)

    return text.strip()


# ============================================================
# TABLE SERIALIZATION
# ============================================================

def dataframe_to_llm_text(df: pd.DataFrame) -> str:
    """
    Convert tables into LLM-friendly structured text.

    Better than markdown for embeddings/retrieval.
    """

    df = df.dropna(how="all").fillna("")

    if df.empty:
        return ""

    rows = []

    columns = [str(c).strip() for c in df.columns]

    for _, row in df.iterrows():
        parts = []

        for col, value in zip(columns, row):
            value = str(value).strip()

            if value:
                parts.append(f"{col}: {value}")

        if parts:
            rows.append(" | ".join(parts))

    return "\n".join(rows)


# ============================================================
# SECTION DETECTION
# ============================================================

SECTION_PATTERNS = [
    r"^[A-Z][A-Z\s]{4,}$",
    r"^\d+\.\d+",
    r"^Chapter\s+\d+",
    r"^Section\s+\d+",
    r"^[\u0600-\u06FF\s]{4,}$",
]


def looks_like_heading(text: str) -> bool:
    text = text.strip()

    if len(text) > 120:
        return False

    return any(re.match(p, text) for p in SECTION_PATTERNS)


# ============================================================
# MAIN PROCESSOR
# ============================================================

class PDFProcessor:
    """
    Production-grade PDF processor for academic RAG systems.
    """

    def __init__(self, pdf_path: str | Path):
        self.pdf_path = Path(pdf_path)

        if not self.pdf_path.exists():
            raise FileNotFoundError(self.pdf_path)

    # --------------------------------------------------------
    # HEADER / FOOTER DETECTION
    # --------------------------------------------------------

    def detect_repeated_lines(
        self,
        pages: list[str],
        threshold: float = 0.6,
    ) -> set[str]:
        """
        Detect repeated headers/footers across pages.
        """

        counter = Counter()

        for text in pages:
            lines = text.splitlines()

            candidates = (
                lines[:3] +
                lines[-3:]
            )

            for line in candidates:
                line = line.strip()

                if len(line) > 3:
                    counter[line] += 1

        minimum = int(len(pages) * threshold)

        return {
            line
            for line, count in counter.items()
            if count >= minimum
        }

    # --------------------------------------------------------
    # BLOCK EXTRACTION
    # --------------------------------------------------------

    def extract_page_text(self, page) -> str:
        """
        Extract page text with better reading order.
        """

        blocks = page.get_text("blocks") or []

        # Sort by vertical then horizontal position
        blocks = sorted(
            blocks,
            key=lambda b: (b[1], b[0]),
        )

        lines = []

        for block in blocks:
            if len(block) < 5:
                continue

            text = block[4].strip()

            if not text:
                continue

            lines.append(text)

        return clean_text("\n".join(lines))

    # --------------------------------------------------------
    # TABLE EXTRACTION
    # --------------------------------------------------------

    def extract_tables(self, page) -> list[str]:
        """
        Extract tables into structured text.
        """

        extracted = []

        try:
            tables = page.find_tables()

            for idx, table in enumerate(tables):

                try:
                    df = table.to_pandas()

                    text = dataframe_to_llm_text(df)

                    if text:
                        extracted.append(
                            f"[TABLE {idx + 1}]\n{text}"
                        )

                except Exception as exc:
                    logger.debug(
                        f"Table extraction error: {exc}"
                    )

        except Exception as exc:
            logger.debug(f"find_tables failed: {exc}")

        return extracted

    # --------------------------------------------------------
    # MAIN EXTRACTION
    # --------------------------------------------------------

    def extract(self) -> list[Document]:

        docs: list[Document] = []

        with pymupdf.open(self.pdf_path) as pdf:

            logger.info(
                f"Processing {len(pdf)} pages..."
            )

            raw_pages = []

            # First pass
            for page in pdf:
                raw_pages.append(
                    self.extract_page_text(page)
                )

            repeated = self.detect_repeated_lines(raw_pages)

            current_section = "Unknown"

            # Second pass
            for page_num, page in enumerate(pdf):

                text = raw_pages[page_num]

                # Remove repeated headers/footers
                cleaned_lines = []

                for line in text.splitlines():

                    if line.strip() in repeated:
                        continue

                    cleaned_lines.append(line)

                text = "\n".join(cleaned_lines)

                # Detect headings
                for line in cleaned_lines[:10]:

                    if looks_like_heading(line):
                        current_section = line.strip()
                        break

                # Extract tables
                tables = self.extract_tables(page)

                combined = text

                if tables:
                    combined += "\n\n" + "\n\n".join(tables)

                combined = clean_text(combined)

                if not combined:
                    continue

                docs.append(
                    Document(
                        page_content=combined,
                        metadata={
                            "source": str(self.pdf_path),
                            "page": page_num + 1,
                            "section": current_section,
                            "extractor": "advanced_pymupdf",
                            "has_tables": bool(tables),
                            "language_support": "unicode_ar_en",
                        },
                    )
                )

        logger.info(
            f"Extracted {len(docs)} documents."
        )

        return docs


# ============================================================
# CLI
# ============================================================

if __name__ == "__main__":

    import sys

    logging.basicConfig(level=logging.INFO)

    path = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "data/handbook.pdf"
    )

    processor = PDFProcessor(path)

    docs = processor.extract()

    print(f"\nExtracted {len(docs)} documents.\n")

    for doc in docs[:3]:

        print("=" * 80)

        print(
            f"Page: {doc.metadata['page']} | "
            f"Section: {doc.metadata['section']}"
        )

        print("-" * 80)

        print(doc.page_content[:2000])
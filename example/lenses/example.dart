import 'package:dartz/dartz.dart';

// Technique: Declare immutable model

class Article {
  final String _title;
  final IMap<String, Section> _sections;
  Article(this._title, this._sections);
  // Technique: Copy "constructor" for concise partial updates
  Article copy({String? title, IMap<String, Section>? sections}) => new Article(title ?? this._title, sections ?? this._sections);
  @override String toString() => "Article(title=$_title, sections=$_sections)";

  // Technique: Lenses for accessing/updating relevant properties
  static final title = lensS<Article, String>((article) => article._title, (article, title) => article.copy(title: title));
  static final sections = lensS<Article, IMap<String, Section>>((article) => article._sections, (article, sections) => article.copy(sections: sections));
  static final section = (String id) => sections.andThenE<Section, String>(imapLensE(id, () => "No section '$id'"));
}

class Section {
  final String _title;
  final IVector<Paragraph> _paragraphs;
  Section(this._title, this._paragraphs);
  Section copy({String? title, IVector<Paragraph>? paragraphs}) => new Section(title ?? this._title, paragraphs ?? this._paragraphs);
  @override String toString() => "Section(title=$_title, paragraphs=$_paragraphs)";

  static final title = lensS<Section, String>((section) => section._title, (section, title) => section.copy(title: title));
  static final paragraphs = lensS<Section, IVector<Paragraph>>((section) => section._paragraphs, (section, paragraphs) => section.copy(paragraphs: paragraphs));
  static final paragraph = (int index) => paragraphs.andThenE<Paragraph, String>(ivectorLensE(index, () => "No paragraph $index"));
}

class Paragraph {
  final IVector<String> _sentences;
  Paragraph(this._sentences);
  Paragraph copy({IVector<String>? sentences}) => new Paragraph(sentences ?? this._sentences);
  @override String toString() => "Paragraph(sentences=\n${_sentences.intercalate(StringMi, "\n")})";

  static final sentences = lensS<Paragraph, IVector<String>>((paragraph) => paragraph._sentences, (paragraph, sentences) => paragraph.copy(sentences: sentences));
  static final sentence = (int index) => sentences.andThenE<String, String>(ivectorLensE(index, () => "No sentence $index"));
}

// Technique: Composed lenses for accessing/updating various parts of an article
final firstParagraph = Section.paragraph(0);
final firstParagraphSentences = firstParagraph.eAndThen<IVector<String>>(Paragraph.sentences);
final EitherLens<Section, String, String> firstParagraphThirdSentence = Section.paragraph(0).eAndThenE<String>(Paragraph.sentence(2));
final abstractSection = Article.section("abstract");
final abstractSectionTitle = abstractSection.eAndThen<String>(Section.title);
final abstractSectionFirstParagraphSentences = abstractSection.eAndThenE<IVector<String>>(firstParagraphSentences);
final abstractSectionFirstParagraphThirdSentence = abstractSection.eAndThenE<String>(firstParagraphThirdSentence);
final missingSection = Article.section("5: A Tempest, A Shipwreck, An Earthquake, And What Else Befell Dr. Pangloss, Candide, And James The Anabaptist");
final missingSectionFirstParagraphThirdSentence = missingSection.eAndThenE(firstParagraphThirdSentence);


void main() {
  final lensArticle = new Article(
      "Lenses",
      imap({"abstract": new Section("Abstract",
          ivector([new Paragraph(
              ivector([
                "Immutable data structures simplify reasoning, concurrency, testability and modularity.",
                "However, traversing and updating deeply nested immutable structures can give rise to cumbersome, repetitive code.",
                "This article describes lenses, a generic solution for inspecting and updating nested immutable data structures."])
          )])
      )})
  );

  print("--- ORIGINAL ---");
  print(lensArticle);

  print("\n--- MORE CORPORATE ---");
  print(abstractSectionTitle.set(lensArticle, "EXECUTIVE SUMMARY"));

  print("\n--- PANICKY ---");
  print(abstractSectionFirstParagraphThirdSentence.set(lensArticle, "AAAAAH!!! COBRAS!!!!!!"));

  print("\n--- TL;DR ---");
  print(abstractSectionFirstParagraphSentences.modifyE(lensArticle, (sentences) {
    final wordCount = sentences.foldMap(IntSumMi, (sentence) => sentence.split(" ").length);
    return ivector(["${wordCount} words... TL;DR"]);
  }));

  print("\n--- MISSING SECTION ---");
  print(missingSectionFirstParagraphThirdSentence.set(lensArticle, "The vessel was a total wreck."));
}
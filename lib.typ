#import "@preview/codelst:2.0.1": *
//#import "acronym-lib.typ": init-acronyms, print-acronyms, gls, acrpl, gls-short, acrspl, acrl, acrlpl, acrf, acrfpl
#import "@preview/glossarium:0.4.1": *
#import "titlepage.typ": *
#import "confidentiality-statement.typ": *
#import "declaration-of-authorship.typ": *
#import "check-attributes.typ": *
#import "@preview/hydra:0.5.1": hydra


// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let supercharged-dhbw(
  title: none,
  authors: (),
  language: none,
  at-university: none,
  type-of-thesis: none,
  type-of-degree: none,
  show-confidentiality-statement: true,
  confidential: true,
  show-confidentiality-marker: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-acronyms: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-code-snippets: true,
  show-appendix: false,
  show-abstract: true,
  show-header: true,
  numbering-alignment: center,
  toc-depth: 2,
  acronym-spacing: 5em,
  abstract: none,
  appendix: none,
  acronyms: none,
  confidentiality-statement-content: none,
  university: none,
  university-location: none,
  city: none,
  supervisor: (:),
  date: none,
  date-format: "[day].[month].[year]",
  bibliography: none,
  bib-style: "ieee",
  logo-left: image("dhbw.svg"),
  logo-right: none,
  logo-size-ratio: "1:1",
  body,
) = {
  // check required attributes
  check-attributes(
    title,
    authors,
    language,
    at-university,
    type-of-thesis,
    type-of-degree,
    show-confidentiality-statement,
    show-declaration-of-authorship,
    show-table-of-contents,
    show-acronyms,
    show-list-of-figures,
    show-list-of-tables,
    show-code-snippets,
    show-appendix,
    show-abstract,
    show-header,
    numbering-alignment,
    toc-depth,
    acronym-spacing,
    abstract,
    appendix,
    acronyms,
    university,
    university-location,
    supervisor,
    date,
    city,
    bibliography,
    bib-style,
    logo-left,
    logo-right,
    logo-size-ratio,
  )

  // set the document's basic properties
  set document(title: title, author: authors.map(author => author.name))
  let many-authors = authors.len() > 3

  //init-acronyms(acronyms)

  // define logo size with given ration
  let left-logo-height = 2.4cm // left logo is always 2.4cm high
  let right-logo-height = 2.4cm // right logo defaults to 1.2cm but is adjusted below
  let logo-ratio = logo-size-ratio.split(":")
  if (logo-ratio.len() == 2) {
    right-logo-height = right-logo-height * (float(logo-ratio.at(1)) / float(logo-ratio.at(0)))
  }

  // save heading and body font families in variables
  let body-font = "Open Sans"
  let heading-font = "Open Sans"
  
  // customize look of figure
  set figure.caption(separator: [ --- ], position: bottom)

  // set body font family
  set text(font: body-font, lang: language, 12pt)
  show heading: set text(weight: "semibold", font: heading-font)

  //heading numbering
 
  // set link style for links that are not acronyms
  show link: it => if (
    true
    //str(it.dest) not in (acronyms.keys().map(gls => ("acronym-" + gls)))
  ) {
    text(fill: black, it)
  } else {
    itew
  }
  
  // show heading.where(level: 1): it => {
  //   pagebreak(weak: true)
  //   v(2em) + it + v(1em)
  // }
  show heading.where(level: 2): it => v(1em) + it + v(0.5em)
  show heading.where(level: 3): it => v(0.5em) + it + v(0.25em)

  titlepage(
    authors,
    date,
    heading-font,
    language,
    left-logo-height,
    logo-left,
    logo-right,
    many-authors,
    right-logo-height,
    supervisor,
    title,
    type-of-degree,
    type-of-thesis,
    university,
    university-location,
    at-university,
    date-format,
    confidential,
    show-confidentiality-marker,
  )

  set page(
    margin: (top: 8em, bottom: 8em),
    header: context {
      if (show-header) {
        grid(
          columns: (1fr, auto),
          align: (left, right),
          gutter: 2em,
          text(size: 10pt,  {
            let headings = query(heading.where(level: 1))
            //[#here().page()]
            if not here().page() in (3, 12, ) {
              if headings.len() > 0 and not headings.any(it => it.location().page() == here().page() - 1) {
                hydra(1, skip-starting: true)
              }
            } 
          }),
          stack(dir: ltr,
            spacing: 2em,
            if logo-left != none {
              set image(height: left-logo-height / 2)
              logo-left
            },
            if logo-right != none {
              //set image(height: 5%)
              //logo-right

              image("/assets/hensoldt-cyber-square.png", width: 50pt, height: 50pt)
            }
          )
        )
        v(-0.75em)
        line(length: 100%, stroke: 0.5pt + black.lighten(10%))
      }
    }
  )

  // set page numbering to roman numbering
  set page(
    numbering: "I",
    number-align: numbering-alignment,
  )
  counter(page).update(1)

  if (not at-university and show-confidentiality-statement) {
    confidentiality-statement(
      authors,
      title,
      confidentiality-statement-content,
      university,
      university-location,
      date,
      language,
      many-authors,
      date-format
    )
  }
  

  if (show-declaration-of-authorship) {
    declaration-of-authorship(
      authors,
      title,
      date,
      language,
      many-authors,
      at-university,
      city,
      date-format
    )
  }

  pagebreak()

  context {
  set par(justify: true, leading: 1em)
  set block(spacing: 2em)

  if (show-abstract and abstract != none) {
    align(center + horizon, heading(level: 1, numbering: none)[Abstract])
    text(abstract)
  }
  }


  pagebreak()

  show outline.entry.where(
    level: 1,
  ): it => {
    v(18pt, weak: true)
    strong(it)
  }

  show heading.where(level: 1): it =>{
    it
    v(25pt)
  }
  
  if (show-table-of-contents) {
    outline(title: [#if (language == "de") {
      [Inhaltsverzeichnis]
    } else {
      [Table of Contents]
    }], indent: auto, depth: toc-depth)
  }

  pagebreak()

  if (show-acronyms and acronyms != none and acronyms.len() > 0) {
    heading(level: 1, outlined: false, numbering: none)[List of Acronyms]
    show: make-glossary
    print-glossary(acronyms, disable-back-references: true)
  }

  pagebreak()

  context {
    let elems = query(figure.where(kind: table), here())
    let count = elems.len()

    if (show-list-of-tables and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Tabellenverzeichnis]
        } else {
          [List of Tables]
        }]],
        target: figure.where(kind: table),
      )
    }
  }

  pagebreak()

  context {
    let elems = query(figure.where(kind: image), here())
    let count = elems.len()
    
    if (show-list-of-figures and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Abbildungsverzeichnis]
        } else {
          [List of Figures]
        }]],
        target: figure.where(kind: image),
      )
    }
  }


  pagebreak()

  context {
    let elems = query(figure.where(kind: raw), here())
    let count = elems.len()

    if (show-code-snippets and count > 0) {
      outline(
        title: [#heading(level: 3)[#if (language == "de") {
          [Codeverzeichnis]
        } else {
          [Code Snippets]
        }]],
        target: figure.where(kind: raw),
      )
    }
  }


  
  // set page numbering to arabic numbering
  set heading(numbering: "1.")

  // reset page numbering and set to arabic numbering
  
  
  set page(
    numbering: "1",
    footer: context align(numbering-alignment, numbering(
    "1 / 1", 
    ..counter(page).get(),
    ..counter(page).at(<end>),
    ))
  ) 
  counter(page).update(1) 


  body

  [#metadata(none)<end>]
  // reset page numbering and set to alphabetic numbering
  set page(
    numbering: "a",
    footer: context align(numbering-alignment, numbering(
      "a", 
      ..counter(page).get(),
    ))
  )
  counter(page).update(1)

  // Display bibliography.
  if bibliography != none {
    set std-bibliography(title: [#if (language == "de") {
      [Literatur]
    } else {
      [References]
    }], style: bib-style)
    bibliography
  }

  pagebreak()

  if (show-appendix and appendix != none) {
    // heading(level: 1, numbering: none)[#if (language == "de") {
    //   [Anhang]
    // } else {
    //   [Appendix]
    // }]
    include appendix
  }
  
}
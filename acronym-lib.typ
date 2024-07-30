#let prefix = "acronym-state-"
#let acros = state("acronyms", none)

#let init-acronyms(acronyms) = {
  acros.update(acronyms)
}

// Check if an acronym exists
#let is-valid(gls) = {
  // acros.display(acronyms => {
  //   if gls not in acronyms {
  //     panic(gls + " is not a key in the acronyms dictionary.")
  //     return false
  //   }
  // })
  return true
}

// Display acronym as clickable link
#let display-link(gls, text) = {
  if is-valid(gls) {
    link(label("acronym-" + gls), text)
  }
}

// Display acronym
#let display(gls, text, link: true) = {
  if link {
    display-link(gls, text)
  } else {
    text
  }
}

// Display acronym in short form
#let gls-short(gls, plural: false, link: true) = {
  if plural {
    display(gls, gls + "s", link: link)
  } else {
    display(gls, gls, link: link)
  }
}
// Display acronym in short plural form
#let acrspl(gls, link: true) = {
  gls-short(gls, plural: true, link: link)
}

// Display acronym in long form
#let acrl(gls, plural: false, link: true) = {
  acros.display(acronyms => {
    //is-valid(gls)
    let defs = acronyms.at(gls)
    if type(defs) == "string" {
      if plural {
        display(gls, defs + "s", link: link)
      } else {
        display(gls, defs, link: link)
      }
    } else if type(defs) == "array" {
      if defs.len() == 0 {
        panic("No definitions found for acronym " + gls + ". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
      }
      if plural {
        if defs.len() == 1 {
          display(gls, defs.at(0) + "s", link: link)
        } else if defs.len() == 2 {
          display(gls, defs.at(1), link: link)
        } else {
          panic("Definitions should be arrays of one or two strings. Definition of " + gls + " is: " + type(defs))
        }
      } else {  
        display(gls, defs.at(0), link: link)
      }
    } else {
      panic("Definitions should be arrays of one or two strings. Definition of " + gls + " is: " + type(defs))
    }
    
  })
}
// Display acronym in long plural form
#let acrlpl(gls, link: true) = {
  acrl(gls, plural: true, link: link)
}

// Display acronym for the first time
#let acrf(gls, plural: false, link: true) = {
  if plural {
    display(gls, [#acrlpl(gls) (#gls\s)], link: link)
  } else {
    display(gls, [#acrl(gls) (#gls)], link: link)
  }
  state(prefix + gls, false).update(true)
}
// Display acronym in plural form for the first time
#let acrfpl(gls, link: true) = {
  acrf(gls, plural: true, link: link)
}

// Display acronym. Expands it if used for the first time
#let gls(gls, plural: false, link: true) = {
  state(prefix + gls, false).display(seen => {
    if seen {
      if plural {
        acrspl(gls, link: link)
      } else {
        gls-short(gls, link: link)
      }
    } else {
      if plural {
        acrfpl(gls, link: link)
      } else {
        acrf(gls, link: link)
      }
    }
  })
}

// Display acronym in the plural form. Expands it if used for the first time. 
#let acrpl(acronym, link: true) = {
  gls(acronym, plural: true, link: link)
}

// Print an index of all the acronyms and their definitions.
#let print-acronyms(language, acronym-spacing) = {
  heading(level: 1, outlined: false, numbering: none)[#if (language == "de") {
    [Abkürzungsverzeichnis]
  } else {
    [List of Acronyms]
  }]

  acros.display(acronyms=>{
    let acronym-keys = acronyms.keys()

    let max-width = 0pt
    for gls in acronym-keys {
      let result = measure(gls).width

      if (result > max-width) {
        max-width = result
      }
    }

    let gls-list = acronym-keys.sorted()

    for gls in gls-list{
      grid(
        columns: (max-width + 0.5em, auto),
        gutter: acronym-spacing,
        [*#gls#label("acronym-" + gls)*], [#acrl(gls, link: false)]
      )
    }
  })
}
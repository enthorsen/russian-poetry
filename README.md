russian-poetry
======================

For Russian-language scansion and analysis

Directory Navigation

  stage0_PoemXML contains poems that have metadata and structural mark-up: poem, divs [chapters, sections], line groups [epigraph, stanzas], l, and w elements with two tiered child elements containing orthographic presentation and stress information, respectively.
  
  stage1_PoemXML contains poems that have been processed by Stage1_MeterPhoneticTransformation.xsl. This stylesheet derives the metrical characteristics of the poem, propagates stress information to monosyllabic words on the basis of ambient meter, and renders a crude phonetic presentation of words.
  
  stage2_PoemXML contains poems that have been processed from stage1_PoemXML by Stage2_RhymeTransformation.xsl. This stylesheet checks for repetition of consonants around the final stressed vowel and adds informational attributes to line and line group elements about where matches occur within the line group.
  
  stage3_PoemXHTML contains poems that have been processed from stage2_PoemXML by Stage3_XMLToXHTML. These are XHTML presentations of the base information acquired in processing the XML in stages 1 and 2. Currently, the XHTML contains a verse table presenting stress, meter, rhyme, and stressed vowel information, and a graph presenting the stress frequency on each vowel for an isometrical (or nearly isosyllabic) poem.

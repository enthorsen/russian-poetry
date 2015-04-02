<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="word" as="element(w)">
        <w>
            <orth>Нарвала</orth>
            <str> н <vowel stress="-1">а</vowel> рв <vowel stress="1">а</vowel> л <vowel stress="-1"
                    >а</vowel>
            </str>
        </w>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:apply-templates select="$word"/>
    </xsl:template>
    <xsl:template match="w">
        <xsl:variable name="explodedOrth"
            select="for $char in string-to-codepoints(orth) return codepoints-to-string($char)"
            as="xs:string+"/>
        <xsl:variable name="stressPos"
            select="sum(str/node()[following-sibling::vowel[@stress eq '1']]/string-length(normalize-space(.))) + 1"/>
        <xsl:copy>
            <xsl:sequence select="string-join($explodedOrth[position() lt $stressPos],'')"/>
            <stress>
                <xsl:sequence select="$explodedOrth[$stressPos]"/>
            </stress>
            <xsl:sequence select="string-join($explodedOrth[position() gt $stressPos],'')"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>

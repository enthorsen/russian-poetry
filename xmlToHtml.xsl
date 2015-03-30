<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">
    <xsl:output method="xhtml" indent="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Checking the poem</title>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="poem/@title"/>
                </h1>
                <table>
                    <tr>
                        <th>Line</th>
                        <th>Text</th>
                        <th>Meter</th>
                        <th>Rhyme</th>
                    </tr>
                    <xsl:apply-templates select="//lg" mode="table"/>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="lg" mode="table">
        <xsl:variable name="matchingLines" select="tokenize(@ambRhyme, ',')" as="xs:string+"/>
        <xsl:variable name="numberMatches">
            <xsl:value-of select="count($matchingLines)"/>
        </xsl:variable>

        <xsl:for-each select="l">
            <tr>
                <td>
                    <xsl:value-of
                        select="count(parent::lg/preceding-sibling::lg/l) + count(preceding-sibling::l)+1"
                    />
                </td>
                <td>
                    <xsl:value-of select="string-join(w/@orth, ' ')"/>
                </td>
                <td>
<xsl:variable name="stressString">                    <xsl:for-each select="w/v">
                        <xsl:variable name="currentPos">
                            <xsl:value-of
                                select="1 + count(preceding-sibling::v) + count(parent::w/preceding-sibling::w/v)"
                            />
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="@stress = '1'">
                                <xsl:text>x</xsl:text>
                            </xsl:when>
                            <xsl:when test="@stress = '-1'">
                                <xsl:text>o</xsl:text>
                            </xsl:when>
                            <xsl:when test="@stress = '0'">
                                <xsl:text>w</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="ancestor::l/@ambientMeter='binary'">
                                <xsl:if test="$currentPos div 2 = round($currentPos div 2)">
                                    <xsl:text>|</xsl:text>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="ancestor::l/@ambientMeter='ternary'">
                                <xsl:if test="$currentPos div 3 = round($currentPos div 3)">
                                    <xsl:text>|</xsl:text>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>

               
                    </xsl:for-each>
</xsl:variable>
                    <xsl:message><xsl:value-of select="xs:string($stressString)"/></xsl:message>
                    <xsl:variable name="feet" select="tokenize(normalize-space(xs:string($stressString)), '\|')"/>
                        <xsl:for-each select="$feet"><span>
                            <xsl:attribute name="class" select="current()"/>
                            <xsl:value-of select="."/>
                            <xsl:if test="not(position() = count($feet))">
                                <xsl:text>|</xsl:text>
                            </xsl:if>
                        </span></xsl:for-each>
                    
                </td>
                <td>
                    <xsl:variable name="lineLevelRhyme" select="@matchingLines"/>
                    <xsl:message>
                        <xsl:value-of select="$lineLevelRhyme"/>
                    </xsl:message>
                    <xsl:variable name="rhymePrimacy">
                        <xsl:value-of select="index-of($matchingLines, $lineLevelRhyme)"/>
                    </xsl:variable>
                    <xsl:message>
                        <xsl:value-of select="$rhymePrimacy"/>
                    </xsl:message>
                    <xsl:choose>
                        <xsl:when test="@posRhyme='0'">
                            <xsl:value-of select="translate($rhymePrimacy,'[1234567]','[abcdefg]')"
                            />
                        </xsl:when>
                        <xsl:when test="@posRhyme='1'">
                            <xsl:value-of select="translate($rhymePrimacy,'[1234567]','[ABCDEFG]')"
                            />
                        </xsl:when>
                        <xsl:when test="xs:integer(@posRhyme) gt 1">
                            <xsl:value-of
                                select="concat(translate($rhymePrimacy,'[1234567]','[ABCDEFG]'),'&#x2032;')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:for-each>
        <tr height="15px"/>


    </xsl:template>
</xsl:stylesheet>

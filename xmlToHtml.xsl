<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">
    <xsl:output method="xhtml" indent="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <link href="http://www.obdurodon.org/css/style.css" rel="stylesheet" type="text/css"/>
                <link rel="stylesheet" type="text/css" href="css/verseTableCSS.css"/>
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
                <xsl:variable name="lineNum"
                    select="count(parent::lg/preceding-sibling::lg/l) + count(preceding-sibling::l)+1"/>
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="round($lineNum div 2) = $lineNum div 2">
                            <xsl:text>even</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>odd</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <td align="right">
                    <xsl:value-of select="$lineNum"/>
                </td>
                <td>
                    <xsl:for-each select="w">
                        <xsl:choose>
                            <xsl:when test="v[@stress eq '1']">
                                <xsl:variable name="explodedOrth"
                                    select="for $char in string-to-codepoints(@orth) return codepoints-to-string($char)"
                                    as="xs:string+"/>
                                <xsl:variable name="stressPos" as="xs:integer">
                                    <xsl:choose>
                                        <xsl:when test="contains(@orth, ' ')">
                                            <xsl:value-of
                                                select="sum((cons|v)[following-sibling::v[@stress eq '1']]/string-length(normalize-space(translate(.,'j', ''))))+2"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="sum((cons|v)[following-sibling::v[@stress eq '1']]/string-length(normalize-space(translate(.,'j', ''))))+1"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>

                                <xsl:sequence
                                    select="string-join($explodedOrth[position() lt $stressPos],'')"/>
                                <span class="stress">
                                    <xsl:sequence select="$explodedOrth[$stressPos]"/>
                                </span>
                                <xsl:sequence
                                    select="string-join($explodedOrth[position() gt $stressPos],'')"
                                />
                                <xsl:if test="not($explodedOrth[last()] eq '-')"><xsl:text>&#160;</xsl:text></xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@orth,' ')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </td>
                <td>
                    <xsl:variable name="stressString">
                        <xsl:for-each select="w/v">
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
                                    <xsl:text>u</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="ancestor::l/@ambientMeter='binary'">
                                    <xsl:if test="$currentPos div 2 = floor($currentPos div 2)">
                                        <xsl:text> | </xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="ancestor::l/@ambientMeter='ternary'">
                                    <xsl:if test="$currentPos div 3 = floor($currentPos div 3)">
                                        <xsl:text>|</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="feet"
                        select="tokenize(normalize-space(xs:string($stressString)), '\|')"/>
                    <xsl:for-each select="$feet">
                        <span>
                            <xsl:attribute name="class" select="current()"/>
                            <xsl:value-of select="."/>
                        </span>
                        <xsl:if test="not(position() = count($feet))">
                            <xsl:text>|</xsl:text>
                        </xsl:if>
                    </xsl:for-each>

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
                            <xsl:value-of select="translate($rhymePrimacy,'123456789','abcdefghi')"
                            />
                        </xsl:when>
                        <xsl:when test="@posRhyme='1'">
                            <xsl:value-of select="translate($rhymePrimacy,'123456789','ABCDEFGHI')"
                            />
                        </xsl:when>
                        <xsl:when test="xs:integer(@posRhyme) gt 1">
                            <xsl:value-of
                                select="concat(translate($rhymePrimacy,'123456789','ABCDEFGHI'),'&#x2032;')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:for-each>
        <xsl:if test="following-sibling::lg">
            <tr class="blank" height="15px">
                <td/>
                <td/>
                <td/>
                <td/>
            </tr>
        </xsl:if>


    </xsl:template>
</xsl:stylesheet>

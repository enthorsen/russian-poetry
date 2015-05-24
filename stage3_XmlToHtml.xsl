<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:djb="http://www.obdurodon.org/" exclude-result-prefixes="xs" version="2.0">
    <xsl:output doctype-system="about:legacy-compat" indent="no" method="xml"/>

    <xsl:variable name="root" select="." as="document-node()"/>

    <xsl:template match="/">

        <html>
            <xsl:comment>#set var="title" value="Verse Table"</xsl:comment>
            <xsl:comment>#config timefmt="%Y-%m-%dT%X%z"</xsl:comment>
            <head>
                <xsl:comment>#include virtual="../inc/poetry-header.html"</xsl:comment>
                <link rel="stylesheet" type="text/css" href="../css/verseTableCSS.css"/>
                <title><xsl:value-of select="poem/@author"/>: <xsl:value-of select="poem/@title"/></title>
            </head>
            <body>
                <xsl:comment>#include virtual="../inc/poetry-boilerplate.html"</xsl:comment>

                <h2>
                    <span id="title">
                        <xsl:value-of select="poem/@title"/>
                    </span>
                    <xsl:text> (</xsl:text>
                    <span id="author">
                        <xsl:value-of select="poem/@author"/>
                    </span>
                    <xsl:text>)</xsl:text>
                </h2>
                <div class="verseTable">
                    <xsl:for-each select="poem/divs">
                        <xsl:variable name="divType" select="@type"/>
                        <xsl:if test="count(parent::poem/divs) gt 1">
                            <h5>
                                <xsl:value-of select="@type"/>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:value-of
                                    select="count(preceding-sibling::divs[@type = $divType]) + 1"/>
                            </h5>
                        </xsl:if>
                        <table>
                            <tr>
                                <th>Line</th>
                                <th>Text</th>
                                <th>Meter</th>
                                <th>Rhyme</th>
                                <th>Stressed<br/>Vowels</th>
                            </tr>
                            <xsl:apply-templates select="lg" mode="table"/>
                        </table>
                    </xsl:for-each>
                </div>
                <div class="svg">
                    <xsl:apply-templates select="poem" mode="stressGraph"/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="lg[@type = 'epigraph']" mode="table">
        <xsl:for-each select="l">
            <tr class="epigraph">
                <td/>
                <td class="epigraph">
                    <xsl:value-of select="string-join(w/@orth, ' ')"/>
                </td>
                <td/>
                <td/>
                <td/>
            </tr>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="lg[@type = 'stanza']" mode="table">
        <xsl:variable name="matchingLines" select="tokenize(@ambRhyme, ',')" as="xs:string+"/>
        <xsl:variable name="numberMatches">
            <xsl:value-of select="count($matchingLines)"/>
        </xsl:variable>

        <xsl:for-each select="l">
            <tr>
                <xsl:variable name="lineNum"
                    select="count(parent::lg/preceding-sibling::lg[@type = 'stanza']/l) + count(preceding-sibling::l) + 1"/>
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
                <td class="number">
                    <xsl:value-of select="$lineNum"/>
                </td>
                <td>
                    <xsl:for-each select="w">
                        <xsl:choose>
                            <xsl:when test="v[@stress eq '1']">
                                <xsl:variable name="explodedOrth"
                                    select="
                                        for $char in string-to-codepoints(@orth)
                                        return
                                            codepoints-to-string($char)"
                                    as="xs:string+"/>
                                <xsl:variable name="posAdjust" as="xs:integer">
                                    <xsl:value-of
                                        select="1 + string-length(replace(@orth, '[А-ЯЁа-яё]+[\p{P}]*', ''))"
                                    />
                                </xsl:variable>
                                <xsl:variable name="encliticAdjust" as="xs:integer">
                                    <xsl:choose>
                                        <xsl:when
                                            test="matches(@orth, '^([\p{P}А-ЯЁа-яё]*\s)?[\p{P}А-ЯЁа-яё]+[\s](л[иь]|б[ы]|-то|ж[е])$')">
                                            <xs:integer>1</xs:integer>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xs:integer>0</xs:integer>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="doubleLettersAdjust">
                                    <xsl:variable name="prePostDoubles"
                                        select="tokenize(@orth, '([а-я])\1')"/>
                                    <xsl:choose>
                                        <xsl:when
                                            test="string-length($prePostDoubles[1]) lt sum((v[@stress = '1']/preceding-sibling::*/string-length(normalize-space(replace(replace(translate(., 'j', ''), 'ts', 'c'), 'šč', 'š')))))">
                                            <xs:integer>1</xs:integer>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xs:integer>0</xs:integer>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>

                                <xsl:variable name="stressPos" as="xs:integer">
                                    <xsl:value-of
                                        select="sum((v[@stress = '1']/preceding-sibling::*/string-length(normalize-space(replace(replace(translate(., 'j', ''), 'ts', 'c'), 'šč', 'š'))))) + $posAdjust - $encliticAdjust + $doubleLettersAdjust"
                                    />
                                </xsl:variable>

                                <xsl:sequence
                                    select="string-join($explodedOrth[position() lt $stressPos], '')"/>
                                <span class="stress">
                                    <xsl:sequence select="$explodedOrth[$stressPos]"/>
                                </span>
                                <xsl:sequence
                                    select="string-join($explodedOrth[position() gt $stressPos], '')"/>
                                <xsl:if test="not(@orth/ends-with(., '-'))">
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@orth, ' ')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </td>
                <td class="meter">
                    <xsl:variable name="firstStress">
                        <xsl:choose>
                            <xsl:when test="@ambientMeter = 'binary'">
                                <xsl:variable name="head"
                                    select="ancestor::divs//l/count(w/v[following::v[@stress = '1'][1] is ancestor::l/(w/v[@stress = '1'])[1]])"/>
                                <xsl:variable name="trochee" select="count($head[. = 0 or . = 2])"/>
                                <xsl:variable name="iamb" select="count($head[. = 1 or . = 3])"/>
                                <xsl:message>
                                    <xsl:value-of select="$head"/>
                                    <xsl:value-of select="$trochee"/>
                                    <xsl:value-of select="$iamb"/>
                                </xsl:message>
                                <xsl:choose>
                                    <xsl:when test="$trochee gt $iamb">
                                        <xsl:text>head-Zero</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$iamb gt $trochee">
                                        <xsl:text>head-One</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$iamb eq $trochee">
                                        <xsl:text>indeter</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="@ambientMeter = 'ternary'">
                                <xsl:variable name="head"
                                    select="ancestor::divs//l/count(w/v[following::v[@stress = '1'][1] is ancestor::l/(w/v[@stress = '1'])[1]])"/>
                                <xsl:variable name="dactyl" select="count($head[. = 0 or . = 3])"/>
                                <xsl:variable name="amphi" select="count($head[. = 1 or . = 4])"/>
                                <xsl:variable name="anap" select="count($head[. = 2 or . = 5])"/>
                                <xsl:choose>
                                    <xsl:when test="$dactyl gt ($amphi + $anap)">
                                        <xsl:text>head-Zero</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$amphi gt ($dactyl + $anap)">
                                        <xsl:text>head-One</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$anap gt ($dactyl + $amphi)">
                                        <xsl:text>head-Two</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>indeter</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="totSyll" as="xs:integer" select="count(w/v)"/>
                    <xsl:variable name="posFinalStress" as="xs:integer"
                        select="
                            (w/v[@stress = '1'])[last()]/sum((count(preceding-sibling::v),
                            count(parent::w/preceding-sibling::w/v))) + 1"/>
                    <xsl:message select="$posFinalStress"/>
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
                                <xsl:when test="ancestor::l/@ambientMeter = 'binary'">
                                    <xsl:if test="$currentPos div 2 = floor($currentPos div 2)">
                                        <xsl:choose>
                                            <xsl:when
                                                test="following-sibling::v[@stress = '1'] or parent::w/following-sibling::w/v[@stress = '1']">
                                                <xsl:text>|</xsl:text>
                                            </xsl:when>
                                            <xsl:when
                                                test="(following-sibling::v or parent::w/following-sibling::w/v) and $currentPos = (ceiling($posFinalStress div 2) * 2)">
                                                <xsl:text>(</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="ancestor::l/@ambientMeter = 'ternary'">
                                    <xsl:if test="$currentPos div 3 = floor($currentPos div 3)">
                                        <xsl:choose>
                                            <xsl:when
                                                test="following-sibling::v[@stress = '1'] or parent::w/following-sibling::w/v[@stress = '1']">
                                                <xsl:text>|</xsl:text>
                                            </xsl:when>
                                            <xsl:when
                                                test="(following-sibling::v or parent::w/following-sibling::w/v) and $currentPos = (ceiling($posFinalStress div 3) * 3)">
                                                <xsl:text>(</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:if test=". is (ancestor::l//v)[last()]">
                                <xsl:if
                                    test="
                                        (ancestor::l[@ambientMeter = 'binary'] and $currentPos * 1 gt (ceiling($posFinalStress div 2) * 2)) or
                                        (ancestor::l[@ambientMeter = 'ternary'] and $currentPos * 1 gt (ceiling($posFinalStress div 3) * 3))">
                                    <xsl:text>)</xsl:text>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:message select="$stressString"/>
                    <xsl:variable name="feet"
                        select="tokenize(normalize-space(xs:string($stressString)), '\|')"/>
                    <xsl:for-each select="$feet">
                        <xsl:choose>
                            <xsl:when test="not(contains(., '('))">
                                <span>
                                    <xsl:attribute name="data-meter" select="$firstStress"/>
                                    <xsl:attribute name="class" select="current()"/>
                                    <xsl:value-of select="."/>
                                </span>
                                <xsl:if test="not(position() = count($feet))">
                                    <xsl:text>|</xsl:text>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="preHyperMetrical" select="tokenize(., '\(')"/>
                                <span>
                                    <xsl:attribute name="class" select="$preHyperMetrical[1]"/>
                                    <xsl:attribute name="data-meter" select="$firstStress"/>
                                    <xsl:value-of select="$preHyperMetrical[1]"/>
                                </span>
                                <span class="hypermetric">
                                    <xsl:value-of select="concat('(', $preHyperMetrical[2])"/>
                                </span>
                                <xsl:text/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:if test="not(@ambientMeter = parent::lg/@ambientMeter)">
                        <xsl:text>*</xsl:text>
                    </xsl:if>
                </td>
                <td>
                    <xsl:variable name="lineLevelRhyme" select="@matchingLines"/>
                    <xsl:variable name="rhymePrimacy" as="xs:integer">
                        <xsl:value-of select="index-of($matchingLines, $lineLevelRhyme)"/>
                    </xsl:variable>
                    <xsl:variable name="rhymeAdjust" as="xs:integer">
                        <xsl:choose>
                            <xsl:when test="xs:integer($rhymePrimacy) gt 9">
                                <xs:integer>9</xs:integer>
                            </xsl:when>
                            <xsl:otherwise>
                                <xs:integer>0</xs:integer>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:message>
                        <xsl:value-of select="$rhymePrimacy"/>
                    </xsl:message>
                    <xsl:choose>
                        <xsl:when test="@posRhyme = '0'">
                            <xsl:value-of
                                select="translate(xs:string($rhymePrimacy - $rhymeAdjust), '123456789', 'abcdefghi')"
                            />
                        </xsl:when>
                        <xsl:when test="@posRhyme = '1'">
                            <xsl:value-of
                                select="translate(xs:string($rhymePrimacy - $rhymeAdjust), '123456789', 'ABCDEFGHI')"
                            />
                        </xsl:when>
                        <xsl:when test="xs:integer(@posRhyme) gt 1">
                            <xsl:value-of
                                select="concat(translate(xs:string($rhymePrimacy - $rhymeAdjust), '123456789', 'ABCDEFGHI'), '&#x2032;')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </td>
                <td>
                    <xsl:for-each select="w/v[@stress = '1']">
                        <span>
                            <xsl:attribute name="class" select="concat('vowel', text())"/>
                            <xsl:value-of select="upper-case(.)"/>
                            <xsl:text>&#160;</xsl:text>
                        </span>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:for-each>
        <xsl:if test="following-sibling::lg">
            <tr class="blank">
                <td/>
                <td/>
                <td/>
                <td/>
                <td/>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="poem" mode="stressGraph">
        <xsl:variable name="valueCount" select="count($stressValences)" as="xs:integer"/>
        <xsl:variable name="xScale" select="20" as="xs:integer"/>
        <xsl:variable name="yScale" select="20" as="xs:integer"/>
        <xsl:variable name="yTop" select="10.5 * $yScale" as="xs:double"/>
        <svg xmlns="http://www.w3.org/2000/svg" height="{$yTop + 70}"
            width="{($valueCount + 3) * $xScale}">
            <g transform="translate(30,{11 * $yScale})">
                <line x1="0" y1="0" x2="{($valueCount + 1) * $xScale}" y2="0" stroke="black"
                    stroke-width="1"/>
                <line x1="0" y1="0" x2="0" y2="-{$yTop}" stroke="black" stroke-width="1"/>
                <text x="{$xScale * ($valueCount + 1) div 2}" y="40" text-anchor="middle"
                    >Syllable</text>
                <xsl:for-each select="1 to 10">
                    <line x1="0" y1="-{current() * $yScale}" x2="{($valueCount + 1) * $xScale}"
                        y2="-{current() * $yScale}" stroke="lightgray" stroke-width="1"/>
                    <text x="-5" y="-{current() * $yScale - 5}" text-anchor="end">
                        <xsl:value-of select="current() * 10"/>
                    </text>
                </xsl:for-each>
                <xsl:for-each select="1 to $valueCount">
                    <xsl:variable name="currentX" select="current() * $xScale" as="xs:integer"/>
                    <xsl:variable name="currentY"
                        select="$stressValences[current()] * $yScale * -10" as="xs:double"/>
                    <xsl:if test="position() ne last()">
                        <xsl:variable name="nextX" select="(current() + 1) * $xScale"
                            as="xs:integer"/>
                        <xsl:variable name="nextY"
                            select="$stressValences[current() + 1] * $yScale * -10" as="xs:double"/>
                        <line x1="{$currentX}" y1="{$currentY}" x2="{$nextX}" y2="{$nextY}"
                            stroke="black" stroke-width="1"/>
                    </xsl:if>
                    <line x1="{$currentX}" y1="0" x2="{$currentX}" y2="-{$yTop}" stroke="lightgray"
                        stroke-width="1"/>
                    <circle cx="{$currentX}" cy="{$currentY}" r="3" fill="red">
                        <title>
                            <xsl:value-of select="round($stressValences[current()] * 100)"/>
                        </title>
                    </circle>
                    <text x="{$currentX}" y="20" text-anchor="middle">
                        <xsl:value-of select="current()"/>
                    </text>
                    <!--<text x="{$currentX}" y="20" text-anchor="middle">
                        <xsl:value-of select="round($stressValences[current()] * 100)"/>
                    </text>-->
                </xsl:for-each>
            </g>
        </svg>

    </xsl:template>

    <xsl:variable name="maxVowelPosition" as="xs:double">
        <xsl:value-of
            select="max(.//lg[@type = 'stanza']/l[@ambientMeter = parent::lg/@ambientMeter]/count(.//v))"
        />
    </xsl:variable>

    <xsl:variable name="stressValences" as="xs:double*">
        <xsl:for-each select="1 to xs:integer($maxVowelPosition)">
            <xsl:sequence select="djb:stressPercentage(current())"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:function name="djb:stressPercentage" as="xs:double*">
        <xsl:param name="stressPosition"/>
        <xsl:variable name="totalLines" select="count($root//lg[@type = 'stanza']/l)"/>
        <xsl:variable name="vowels"
            select="$root//lg[@type = 'stanza']/l/descendant::v[position() eq $stressPosition]"
            as="element(v)+"/>
        <xsl:variable name="stressed" select="count($vowels[@stress eq '1'])" as="xs:integer"/>
        <xsl:variable name="unstressed" select="count($vowels[@stress eq '-1'])" as="xs:integer"/>
        <xsl:variable name="total" select="$stressed + $unstressed" as="xs:integer"/>
        <xsl:sequence select="$stressed div count($vowels)"/>
    </xsl:function>



</xsl:stylesheet>

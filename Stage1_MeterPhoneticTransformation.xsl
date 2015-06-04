<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:djb="http://www.obdurodon.org/"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Moves contextual information (title, attributed date, attributed place) to attributes in the root node-->

    <xsl:template match="poem">
        <poem author="{author}">
            <xsl:attribute name="title">
                <xsl:choose>
                    <xsl:when test="@title">
                        <xsl:value-of select="@title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="title"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="date">
                <xsl:choose>
                    <xsl:when test="@date">
                        <xsl:value-of select="@date"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="date"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="placeAttr">
                <xsl:choose>
                    <xsl:when test="@placeAttr">
                        <xsl:value-of select="@placeAttr"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="place"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="author">
                <xsl:choose>
                    <xsl:when test="@author">
                        <xsl:value-of select="@author"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="author"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:variable name="divsPreCaesura">
                <xsl:apply-templates select="divs" mode="first"/>
            </xsl:variable>
            <xsl:apply-templates select="$divsPreCaesura" mode="second"/>
            <xsl:apply-templates select="source"/>
        </poem>

    </xsl:template>

    <xsl:template match="poem/date|poem/place|poem/title|poem/author"/>

    <xsl:template match="divs" mode="first">
        <divs>
            <xsl:apply-templates select="lg" mode="preAmbient"/>
        </divs>
    </xsl:template>

    <xsl:template match="divs" mode="second">
        <divs>
            <xsl:variable name="lgCaesuraed">
                <xsl:apply-templates select="lg" mode="caesura"/>
            </xsl:variable>
            <xsl:variable name="lgMetered">
                <xsl:apply-templates select="$lgCaesuraed" mode="findMeter"/>
            </xsl:variable>
            <xsl:variable name="lgAmbientMeter">
                <xsl:apply-templates select="$lgMetered" mode="ambientMeter"/>
            </xsl:variable>
            <xsl:variable name="lgMeterPropagated">
                <xsl:apply-templates select="$lgAmbientMeter" mode="propagateMeter"/>
            </xsl:variable>
            <xsl:variable name="lgMeterOrphansRescued">
                <xsl:apply-templates select="$lgMeterPropagated" mode="meterCheck"/>
            </xsl:variable>
            <xsl:apply-templates select="$lgMeterOrphansRescued" mode="postAmbient"/>
        </divs>
    </xsl:template>

    <xsl:template match="lg[@type='stanza']" mode="meterCheck">
        <lg ambientMeter="{@ambientMeter}" type="{@type}" caesura="{@caesura}">
            <xsl:apply-templates select="l" mode="meterCheck"/>
        </lg>
    </xsl:template>

    <xsl:template match="l" mode="meterCheck">
        <xsl:variable name="total">
            <xsl:value-of select="count(descendant::v)"/>
        </xsl:variable>

        <!--        <xsl:variable name="avgDistanceBinary" select="djb:avgDistanceBinary(0, $total, .)"/>
        <xsl:variable name="avgDistanceTernary" select="djb:avgDistanceTernary(0, $total, .)"/>
-->
        <l rhythm="{@rhythm}">
            <xsl:attribute name="ambientMeter">
                <!--<xsl:choose>
                    <xsl:when test="$avgDistanceBinary = 0">
                        <xsl:text>binary</xsl:text>
                    </xsl:when>
                    <xsl:when test="$avgDistanceTernary = 0">
                        <xsl:text>ternary</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="parent::lg/@ambientMeter"/>
                    </xsl:otherwise>
                </xsl:choose>-->
                <xsl:text>binary</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </l>
    </xsl:template>


    <xsl:template match="lg" mode="preAmbient">
        <lg>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="@type">
                        <xsl:value-of select="@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>stanza</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="l" mode="stress"/>
        </lg>
    </xsl:template>

    <xsl:template match="lg[@type='stanza']" mode="caesura">
        <xsl:variable name="currentLG" select="."/>
        <xsl:variable name="numLines" select="count(l)"/>
        <xsl:variable name="threshold" select="($numLines - 1) div $numLines"/>
        <lg type="{@type}">
            <!--Check for Caesura-->
            <xsl:variable name="maxVowelPosition" as="xs:double*"
                select="max(l/count(descendant::v))"/>
            <xsl:variable name="wordBreaks" as="xs:double*">
                <xsl:for-each select="1 to xs:integer($maxVowelPosition)">
                    <xsl:sequence select="djb:wordBreakPositions(current(), $currentLG)"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each select="2 to xs:integer($maxVowelPosition) - 2 ">
                <xsl:if test="$wordBreaks[current()] ge (($numLines - 1) div $numLines)">
                    <xsl:attribute name="caesura" select="xs:integer(current())"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <xsl:template match="lg[@type='stanza']" mode="findMeter">
        <lg type="{@type}">
            <xsl:attribute name="caesura">
                <xsl:choose>
                    <xsl:when test="@caesura">
                        <xsl:value-of select="@caesura"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>none</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Check for Meter -->
            <xsl:apply-templates select="l" mode="meter"/>
        </lg>
    </xsl:template>
    <xsl:template match="lg[not(@type = 'stanza')]">
        <lg type="{@type}">
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <xsl:template match="lg[@type='stanza']" mode="ambientMeter">
        <lg type="{@type}" caesura="{@caesura}">
            <xsl:attribute name="ambientMeter">
                <xsl:choose>
                    <xsl:when
                        test="count(l[@ambientMeter = 'binary']) gt count(l[@ambientMeter = 'ternary'])">
                        <xsl:text>binary</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="count(l[@ambientMeter = 'binary']) lt count(l[@ambientMeter = 'ternary'])">
                        <xsl:text>ternary</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>indeterminate</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <xsl:template match="lg[@type='stanza']" mode="propagateMeter">
        <lg type="{@type}" ambientMeter="{@ambientMeter}" caesura="{@caesura}">
            <xsl:apply-templates select="l" mode="propagateMeter"/>
        </lg>
    </xsl:template>

    <xsl:template match="l" mode="propagateMeter">
        <l rhythm="{@rhythm}">
            <xsl:attribute name="ambientMeter">
                <xsl:choose>
                    <xsl:when test="not(parent::lg/@ambientMeter = 'indeterminate')">
                        <xsl:value-of select="parent::lg/@ambientMeter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@ambientMeter"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="w" mode="propagateMeter"/>
        </l>
    </xsl:template>

    <xsl:template match="w" mode="propagateMeter">
        <w orth="{@orth}">
            <xsl:choose>
                <xsl:when test="(count(v[@stress='0']) gt 0)">
                    <xsl:apply-templates select="*" mode="propagateMeter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </w>
    </xsl:template>

    <xsl:function name="djb:vowelPosition" as="xs:integer+">
        <xsl:param name="rootVowel" as="element(v)"/>
        <xsl:sequence
            select="sum((count($rootVowel/preceding-sibling::v), count($rootVowel/parent::w/preceding-sibling::w/v), 1))"
        />
    </xsl:function>

    <xsl:template match="v[@stress='0']" mode="propagateMeter">
        <v>
            <xsl:variable name="ancestorLG" select="ancestor::lg"/>
            <xsl:variable as="xs:integer" name="vowelPosition" select="djb:vowelPosition(.)"/>
            <xsl:variable name="maxVowelPosition" select="$ancestorLG/max(descendant::l/count(v))"/>
            <xsl:variable name="stressValences" as="xs:double*">
                <xsl:for-each select="1 to xs:integer($maxVowelPosition)">
                    <xsl:sequence select="djb:stressPercentage(current(), $ancestorLG)"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="stress">
                <xsl:choose>
                    <xsl:when
                        test="djb:strongWeak($vowelPosition, $ancestorLG, $stressValences) = true()">
                        <xs:integer>1</xs:integer>
                    </xsl:when>
                    <xsl:when
                        test="djb:strongWeak($vowelPosition, $ancestorLG, $stressValences) = false()">
                        <xs:integer>-1</xs:integer>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:integer>0</xs:integer>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </v>
    </xsl:template>

    <xsl:template match="l" mode="stress">
        <l>
            <!-- Stage Zero: currently when a word has no strong stress
             David's dictionary returns <str>none</str>-->
            <xsl:variable name="stage0output">
                <xsl:apply-templates select="w" mode="addStresses"/>
            </xsl:variable>

            <!-- Stage One: return w elements that have changed the
            orth/str siblings, each containing 
            different information (punctuation, stress)
            to a set of cons v siblings-->
            <xsl:variable name="stage1output">
                <xsl:apply-templates select="$stage0output" mode="strToConsVow"/>
            </xsl:variable>
            <!-- Stage Two: return w elements that have combined proclitics with 
             the words that follow them, 
             e.g. <w>nado</w><w>mnoi</w> becomes <w>nadomnoi</w>-->
            <xsl:variable name="stage2output">
                <xsl:apply-templates select="$stage1output" mode="proclitics"/>
            </xsl:variable>

            <!-- Stage Three: return w elements that have combined the contents 
            of neighboring cons elements
            e.g. <cons>d</cons><cons>r<cons> beomces <cons>dr</cons>-->
            <xsl:variable name="stage3output">
                <xsl:apply-templates select="$stage2output" mode="consProclitics"/>
            </xsl:variable>
            <xsl:apply-templates select="$stage3output"/>
        </l>
    </xsl:template>

    <xsl:template match="l" mode="meter">
        <xsl:variable name="total" as="xs:integer">
            <xsl:value-of select="count(w/v)"/>
        </xsl:variable>
        <!--
        <xsl:variable name="avgDistanceBinary" as="xs:double*">
            <xsl:choose>
                <xsl:when test="parent::lg/@caesura = 'none' or not(parent::lg/@caesura)">
                    <xsl:value-of select="abs(djb:avgDistanceBinary(0, $total, .))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="avgDistanceBinary1" as="xs:double*"
                        select="djb:avgDistanceBinary(0, xs:integer(parent::lg/@caesura), .)"/>
                    <xsl:variable name="avgDistanceBinary2" as="xs:double*"
                        select="djb:avgDistanceBinary(xs:integer(sum((parent::lg/@caesura,1))), $total, .)"/>
                    <xsl:value-of
                        select="(abs($avgDistanceBinary1) + abs($avgDistanceBinary2)) div 2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="avgDistanceTernary" as="xs:double*">
            <xsl:choose>
                <xsl:when test="parent::lg/@caesura = 'none' or not(parent::lg/@caesura)">
                    <xsl:value-of select="abs(djb:avgDistanceTernary(0, $total, .))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="avgDistanceTernary1" as="xs:double*"
                        select="abs(djb:avgDistanceTernary(0, xs:integer(parent::lg/@caesura), .))"/>
                    <xsl:variable name="avgDistanceTernary2" as="xs:double*"
                        select="abs(djb:avgDistanceTernary(xs:integer(sum((parent::lg/@caesura,1))), $total, .))"/>
                    <xsl:message>
                        <xsl:text>I didn't break at: </xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:message>
                    <xsl:value-of
                        select="(abs($avgDistanceTernary1) + abs($avgDistanceTernary2)) div 2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

-->
        <xsl:variable name="seq">
            <xsl:sequence select="w/v/@stress"/>
        </xsl:variable>

        <l rhythm="{$seq}">
            <xsl:attribute name="ambientMeter">                
             <xsl:value-of select="djb:findMeter(descendant::v, parent::lg/@caesura)"/>
            </xsl:attribute>


            <!--                <xsl:choose>
                    <xsl:when test="$avgDistanceBinary lt $avgDistanceTernary">
                        <xsl:text>binary</xsl:text>
                    </xsl:when>
                    <xsl:when test="$avgDistanceBinary gt $avgDistanceTernary">
                        <xsl:text>ternary</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>indeterminate</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
-->

            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <!-- Stage Zero: -->
    <xsl:template match="w" mode="addStresses">
        <w>
            <xsl:apply-templates select="orth"/>
            <xsl:choose>
                <xsl:when test="str/stress">
                    <xsl:apply-templates select="str"/>
                </xsl:when>
                <xsl:otherwise>
                    <str>
                        <xsl:analyze-string select="str" regex="\((.+)\)">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </str>
                </xsl:otherwise>
            </xsl:choose>
        </w>
    </xsl:template>

    <!-- Stage One: 
        w template in strToConsVows mode will return a 
        streamlined w to variable $stage1output
        Stress set transformations
        1) If str element has a stress child (i.e., is not an ambiguous monosyllable, preposition, or pronoun), identify all vowels in its text nodes as v with stress attribute of "0", for the time being. 
        2) If str element does not contain a stress, probability of vowels being stressed or unstressed between 0 and 1. Mark as something to refer meter to at later time.
        3) If a stress element, then wrap contents in v element with stress=1-->

    <xsl:template match="w" mode="strToConsVow">
        <w orth="{orth}">
            <xsl:apply-templates mode="consVowels"/>
        </w>
    </xsl:template>
    <xsl:template match="orth" mode="consVowels"/>
    <xsl:template match="stress" mode="consVowels">
        <v>
            <xsl:attribute name="stress">
                <xsl:value-of select="1"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </v>
    </xsl:template>
    <xsl:template match="str[child::stress]" mode="consVowels">
        <xsl:apply-templates select="stress|text()" mode="consVowels"/>
    </xsl:template>
    <xsl:template match="str[child::stress]/text()" mode="consVowels">
        <xsl:analyze-string select="." regex="([аэыоуяеиёю])">
            <xsl:matching-substring>
                <v stress="-1">
                    <xsl:value-of select="."/>
                </v>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:if test="not(. = '')">
                    <cons>
                        <xsl:value-of select="lower-case(.)"/>
                    </cons>
                </xsl:if>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="str[not(child::stress)]" mode="consVowels">
        <xsl:choose>
            <xsl:when test="contains(., 'ё')">
                <xsl:analyze-string select="." regex="[аэыоуяеиёюАЭЫОУЯЕИЁЮ]">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="matches(., 'ё')">
                                <v>
                                    <xsl:attribute name="stress">
                                        <xsl:value-of select="1"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </v>
                            </xsl:when>
                            <xsl:otherwise>
                                <v>
                                    <xsl:attribute name="stress">
                                        <xsl:value-of select="-1"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </v>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="\s+">
                            <xsl:matching-substring/>
                            <xsl:non-matching-substring>
                                <cons>
                                    <xsl:value-of select="lower-case(.)"/>
                                </cons>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="." regex="[аэыоуяеиёюАЭЫОУЯЕИЁЮ]">
                    <xsl:matching-substring>
                        <v>
                            <xsl:attribute name="stress">
                                <xsl:value-of select="0"/>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                        </v>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="\s+">
                            <xsl:matching-substring/>
                            <xsl:non-matching-substring>
                                <cons>
                                    <xsl:value-of select="lower-case(.)"/>
                                </cons>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Stage Two: Combine proclitics with following word -->
    <xsl:template match="w" mode="proclitics">
        <xsl:choose>
            <xsl:when
                test="matches(lower-case(@orth), '^(без|[в]?близ|в|в[о]?круг|да|для|[иа]|из|ис-под|ж[е]?|за|к|л[иь]|н[аеио]|над|о[тб]?|п[е]?ред|по|под|про|против|с|сквозь|сред[иь]|ч[е]?рез|у|-то|б[ы]?|л[иь]|ж[е])[о]?$')"/>
            <xsl:when
                test="./matches(lower-case((preceding-sibling::w[1])/@orth), '^(без|[в]?близ|в|в[о]?круг|да|для|[иа]|из|ис-под|за|к|н[аеио]|над|о[тб]?|п[е]?ред|по|под|про|против|с|сквозь|сред[иь]|ч[е]?рез|у)[о]?$')
                and ./matches(lower-case((preceding-sibling::w[2])/@orth), '^([иа]|н[еио])$')">
                <xsl:variable name="addDoubleProclitic">
                    <xsl:value-of
                        select="concat((preceding-sibling::w[2])/@orth, ' ', (preceding-sibling::w[1])/@orth, ' ', @orth)"
                    />
                </xsl:variable>
                <w orth="{$addDoubleProclitic}">
                    <xsl:apply-templates select="(preceding-sibling::w[2])/*" mode="unstressClitic"/>
                    <xsl:apply-templates select="(preceding-sibling::w[1])/*" mode="unstressClitic"/>
                    <xsl:apply-templates select="*"/>
                </w>
            </xsl:when>
            <xsl:when
                test="./matches(lower-case((preceding-sibling::w[1])/@orth), '^(без|[в]?близ|в|в[о]?круг|да|для|[иа]|из|за|ис-под|к|н[аеио]|над|о[тб]?|п[е]?ред|по|под|про|против|с|сквозь|сред[иь]|ч[е]?рез|у)[о]?$')">
                <xsl:variable name="addProclitic">
                    <xsl:value-of select="concat((preceding-sibling::w[1])/@orth, ' ', @orth)"/>
                </xsl:variable>
                <w orth="{$addProclitic}">
                    <xsl:apply-templates select="(preceding-sibling::w[1])/*" mode="unstressClitic"/>
                    <xsl:apply-templates select="*"/>
                </w>
            </xsl:when>
            <xsl:when test="./matches(following-sibling::w[1]/@orth, '^(-то|б[ы]?|л[иь]|ж[е]?)$')">
                <xsl:variable name="addEnclitic">
                    <xsl:value-of select="concat(@orth, ' ', (following-sibling::w[1])/@orth)"/>
                </xsl:variable>
                <w orth="{$addEnclitic}">
                    <xsl:apply-templates select="*"/>
                    <xsl:apply-templates select="following-sibling::w[1]/*" mode="unstressClitic"/>
                </w>
            </xsl:when>
            <xsl:otherwise>
                <w orth="{@orth}">
                    <xsl:if test="count(v) = 1">
                        <xsl:attribute name="stress">
                            <xsl:text>0</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="v" mode="unstressClitic">
        <v stress="-1">
            <xsl:value-of select="."/>
        </v>
    </xsl:template>

    <!-- Stage Three: Combine the contents of neighboring cons elements 
    (necessary after combining proclitics)-->
    <xsl:template match="w" mode="consProclitics">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="consProclitics"/>
        </w>
    </xsl:template>

    <xsl:template match="cons[preceding-sibling::*[1] is preceding-sibling::cons[1]]"
        mode="consProclitics">
        <cons>
            <xsl:value-of select="lower-case(concat(preceding-sibling::cons[1], .))"/>
        </cons>
    </xsl:template>

    <xsl:template match="cons[following-sibling::*[1] is following-sibling::cons[1]]"
        mode="consProclitics"/>

    <!-- From here, ambient meter has fixed non-proclitic monosyllables, phonetic tranformation continues -->
    <xsl:template match="lg" mode="postAmbient">
        <lg ambientMeter="{@ambientMeter}" type="{@type}" caesura="{@caesura}">
            <xsl:apply-templates select="l" mode="phonetic"/>
        </lg>
    </xsl:template>

    <xsl:template match="l" mode="phonetic">
        <l rhythm="{@rhythm}" ambientMeter="{@ambientMeter}">

            <!-- Stage Four: fix -ogo/-ego sounds -->
            <xsl:variable name="stage4output">
                <xsl:apply-templates select="w" mode="ogoego"/>
            </xsl:variable>

            <!-- Stage Five: map all soft vowels to j+hard vowel letter
            e.g. <cons>d</cons><v>ja</v> becomes <cons>dj</cons><v>a</v>-->
            <xsl:variable name="stage5output">
                <xsl:apply-templates select="$stage4output" mode="softVowels"/>
            </xsl:variable>


            <!-- Stage Six: work out compound letters (shch, ts); 
            remove soft sign after unpaired hard cons (zhj becomes zh);
            add soft sign after unpaired soft cons (ch becomes chj);-->
            <xsl:variable name="stage6output">
                <xsl:apply-templates select="$stage5output" mode="unpairedCons"/>
            </xsl:variable>

            <!-- Stage Seven: reduce unstressed vowels after j to и -->
            <xsl:variable name="stage7output">
                <xsl:apply-templates select="$stage6output" mode="reduceVowels"/>
            </xsl:variable>

            <!-- Stage Eight: devoice final consonants -->
            <xsl:variable name="stage8output">
                <xsl:apply-templates select="$stage7output" mode="devoiceFinal"/>
            </xsl:variable>

            <!-- Stage Nine: voice and devoice consonant clusters -->
            <xsl:variable name="stage9output">
                <xsl:apply-templates select="$stage8output" mode="voicingClusters"/>
            </xsl:variable>

            <!-- Stage Ten: convert all Cyrillic to Latin -->
            <xsl:variable name="stage10output">
                <xsl:apply-templates select="$stage9output" mode="latinize"/>
            </xsl:variable>
            <xsl:apply-templates select="$stage10output"/>
        </l>
    </xsl:template>

    <xsl:template match="w" mode="ogoego">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="ogoego"/>
        </w>
    </xsl:template>

    <xsl:template match="cons[text() = 'г']" mode="ogoego">
        <cons>
            <xsl:choose>
                <xsl:when
                    test="(preceding-sibling::v[1])/matches(., '[еэо]') and (following-sibling::v[1])/matches(., 'о') and following-sibling::v[1] is following-sibling::*[last()] and parent::w/@orth/not(matches(., '[Сс]трого|[Мм]ного|[Дд]орого|[Бб]ого[а-яё]+'))">
                    <xsl:text>в</xsl:text>
                </xsl:when>
                <xsl:when test="parent::w/@orth/matches(., '^[Бб]ог$')">
                    <xsl:text>х</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </cons>
    </xsl:template>

    <!-- Stage Four: Map soft vowels to 'j'+hard paired vowel
        This leaves things "incorrect" for a while.
    -->
    <xsl:template match="w" mode="softVowels">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="palatComps"/>
        </w>
    </xsl:template>
    <xsl:template
        match="cons[following-sibling::*[1] is following-sibling::v[1][matches(., '^[яеиёю]$')]]"
        mode="palatComps">
        <cons surface="{.}">
            <xsl:value-of select="concat(., 'j')"/>
        </cons>
    </xsl:template>
    <xsl:template
        match="v[matches(., '^[яиеёю]$') and preceding-sibling::*[1] is preceding-sibling::cons[1]]"
        mode="palatComps">
        <v stress="{@stress}" surface="{.}">
            <xsl:value-of select="translate(., 'яиеёю', 'аыэоу')"/>
        </v>
    </xsl:template>
    <xsl:template match="v[matches(., '^[яиеёю]$') and count(preceding-sibling::*)=0]">
        <xsl:if test="not(. = 'и')">
            <cons>
                <xsl:text>j</xsl:text>
            </cons>
        </xsl:if>
        <v stress="{@stress}" surface="{.}">
            <xsl:value-of select="translate(., 'яеёю', 'аэоу')"/>
        </v>
    </xsl:template>
    <xsl:template
        match="v[preceding-sibling::*[1] is preceding-sibling::v[1]][matches(., '^[яиеёю]$')]"
        mode="palatComps">
        <cons>j</cons>
        <v stress="{@stress}" surface="{.}">
            <xsl:value-of select="translate(., 'яиеёю', 'аыэоу')"/>
        </v>
    </xsl:template>

    <!-- Stage Five: Remove soft sign or 'j' after unpaired hard consonant
        Replace soft sign or add 'j' after unpaired soft consonant.
        This is a convenient place to fix up compound letters: щ->шч, т(ь)с(ь)->ц
    -->
    <xsl:template match="w" mode="unpairedCons">
        <w orth="{@orth}">
            <xsl:apply-templates mode="unpairedCons"/>
        </w>
    </xsl:template>

    <xsl:template match="cons" mode="unpairedCons">
        <xsl:variable name="reflexiveToHardTs">
            <xsl:value-of select="replace(., 'т[jь]?с[jь]?', 'ц')"/>
        </xsl:variable>
        <xsl:variable name="alwaysHardSoft">
            <xsl:analyze-string select="$reflexiveToHardTs" regex="^(.*)([жшчцщ])([jь]?)$">
                <xsl:matching-substring>
                    <xsl:choose>
                        <xsl:when test="matches(., '^(.*)([жшц])([jь]?)$')">
                            <xsl:value-of select="concat(regex-group(1), regex-group(2))"/>
                        </xsl:when>
                        <xsl:when test="matches(., '^(.*)([чщ])([jь]?)$')">
                            <xsl:value-of select="concat(regex-group(1), regex-group(2), 'j')"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <cons>
            <xsl:value-of select="replace(replace($alwaysHardSoft, 'ц', 'тс'), 'щ','шч')"/>
        </cons>
    </xsl:template>

    <!-- Stage Six: Reduce unstressed vowels -->
    <xsl:template match="w" mode="reduceVowels">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="reduceVowels"/>
        </w>
    </xsl:template>

    <xsl:template match="v[not(@stress = '1')]" mode="reduceVowels">
        <v stress="{@stress}">
            <xsl:choose>
                <!-- Reduce 'o' to 'a' in absolute initial position and directly before stressed vowel,
                in approximation of [ɐ]-->
                <xsl:when test="contains(preceding-sibling::cons[1], 'j')">
                    <xsl:value-of select="translate(., 'аоэ','иии')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when
                            test="following-sibling::v[@stress='1'] or not(preceding-sibling::v)">
                            <xsl:value-of select="translate(., 'аоу', 'аaу')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="translate(., 'эо','иа')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </v>
    </xsl:template>

    <!-- Stage Seven: Devoice final consonants-->
    <xsl:template match="w" mode="devoiceFinal">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="devoiceFinal"/>
        </w>
    </xsl:template>
    <xsl:template match="cons[not(following-sibling::*)]" mode="devoiceFinal">
        <cons>
            <xsl:analyze-string select="." regex="(.*)([бвгдзж]+)([jь]?)">
                <xsl:matching-substring>
                    <xsl:value-of
                        select="concat(regex-group(1), translate(regex-group(2),'[бвгдзж]','[пфктсш]'), regex-group(3))"
                    />
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </cons>
    </xsl:template>

    <!-- Stage Eight: Voice and devoice consonant clusters  -->
    <xsl:template match="w" mode="voicingClusters">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="voicingClusters"/>
        </w>
    </xsl:template>
    <xsl:template match="cons" mode="voicingClusters">
        <cons>
            <xsl:analyze-string select="." regex="([а-я]*)([пфктсш]+[бгдзж]+)([a-z]*)">
                <xsl:matching-substring>
                    <xsl:value-of
                        select="concat(regex-group(1), translate(regex-group(2), 'пфктсш', 'бвгдзж'),  regex-group(3))"
                    />
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="([а-я]*)([бвгдзж]+[пфктсшц]+)([a-z]*)">
                        <xsl:matching-substring>
                            <xsl:value-of
                                select="concat(regex-group(1),translate(regex-group(2), 'бвгдзж', 'пфктсш'),  regex-group(3))"
                            />
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </cons>
    </xsl:template>

    <!-- Stage Nine: Convert Cyrillic to Latin -->
    <xsl:template match="w" mode="latinize">
        <w orth="{@orth}">
            <xsl:apply-templates select="*" mode="latinize"/>
        </w>
    </xsl:template>
    <xsl:template match="cons" mode="latinize">
        <cons>
            <xsl:value-of
                select="replace(translate(., 'бвгдзжйклмнпрстфцхчшьъ','bvgdzžqklmnprstfcxčšq″'),'([a-zžčš])\1','$1')"
            />
        </cons>
    </xsl:template>
    <xsl:template match="v" mode="latinize">
        <v stress="{@stress}">
            <xsl:value-of select="translate(lower-case(.), 'аэиыоу', 'aeiiou')"/>
        </v>
    </xsl:template>

    <!--Functions-->
    <xsl:function name="djb:avgDistanceBinary" as="xs:double*">
        <xsl:param name="begin" as="xs:integer"/>
        <xsl:param name="end" as="xs:integer"/>
        <xsl:param name="line" as="element(l)"/>
        <xsl:variable name="vowels" as="element(v)+"
            select="for $i in ($begin to $end) return $line/descendant::v[$i]"/>
        <xsl:choose>
            <xsl:when test="($end - $begin) le 4 and ($end - $begin) gt 0">
                <xsl:variable name="stressNumber" select="count($vowels[@stress eq '1'])"/>
                <xsl:variable name="postCaesuraHead"
                    select="($vowels[@stress eq '1'])[last()]/sum((count(preceding-sibling::v), count(parent::w/preceding-sibling::w/v)))- $begin"/>
                <xsl:choose>
                    <xsl:when
                        test="$stressNumber = 1 and $postCaesuraHead = djb:headLength($line/parent::lg)">
                        <xs:double>.001</xs:double>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:double>.80</xs:double>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="avg(for $i in (3+$begin to $end) return $vowels[$i]/@stress - $vowels[$i - 1]/@stress)"/>
                <xsl:value-of
                    select="avg(for $i in (3+$begin to $end) return $vowels[$i]/@stress - $vowels/(w/v)[$i - 1]/@stress)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="djb:avgDistanceTernary" as="xs:double*">
        <xsl:param name="begin" as="xs:integer"/>
        <xsl:param name="end" as="xs:integer"/>
        <xsl:param name="line" as="element(l)"/>
        <xsl:variable name="vowels" as="element(v)+"
            select="for $i in ($begin to $end) return $line/descendant::v[$i]"/>
        <xsl:choose>
            <xsl:when test="($end - $begin le 3) and ($end - $begin ge 1)">
                <xsl:variable name="stressNumber" select="count($vowels[@stress eq '1'])"/>
                <xsl:variable name="postCaesuraHead"
                    select="($vowels[@stress eq '1'])[last()]/sum((count(preceding-sibling::v), count(parent::w/preceding-sibling::w/v)))- $begin"/>
                <xsl:choose>
                    <xsl:when
                        test="$stressNumber = 1 and $postCaesuraHead = djb:headLength($line/parent::lg)">
                        <xs:double>.001</xs:double>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:double>.80</xs:double>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="avg(for $i in (4+$begin to $end) return $vowels[$i]/@stress - $vowels[$i - 2]/@stress)"/>
                <xsl:value-of
                    select="avg(for $i in (4+$begin to $end) return $vowels[$i]/@stress - $vowels[$i - 2]/@stress)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="djb:headLength" as="xs:double*">
        <xsl:param name="lg" as="element(lg)"/>
        <xsl:variable name="lineCount" select="count($lg/l)"/>
        <xsl:variable name="headLengths"
            select="$lg/l/(v[@stress='1'])[1]/sum((count(preceding-sibling::v), count(parent::w/preceding-sibling::w/v)))"/>
        <xsl:value-of select="sum($headLengths) div $lineCount"/>
        <xsl:message>
            <xsl:value-of select="sum($headLengths) div $lineCount"/>
        </xsl:message>
    </xsl:function>

    <xsl:function name="djb:stressPercentage" as="xs:double*">
        <xsl:param name="stressPosition" as="xs:integer"/>
        <xsl:param name="lgContext" as="element(lg)"/>
        <xsl:variable name="totalLines" select="count($lgContext/l)"/>
        <xsl:variable name="vowels"
            select="$lgContext/descendant::v[djb:vowelPosition(.) eq $stressPosition]"
            as="element(v)*"/>
        <xsl:choose>
            <xsl:when test="count($vowels) gt 0">
                <xsl:variable name="stressed" select="count($vowels[@stress eq '1'])"
                    as="xs:integer"/>
                <xsl:variable name="unstressed" select="count($vowels[@stress eq '-1'])"
                    as="xs:integer"/>
                <xsl:variable name="total" select="$stressed + $unstressed" as="xs:integer"/>
                <xsl:sequence select="$stressed div $total"/>
            </xsl:when>
            <xsl:otherwise>
                <xs:integer>0</xs:integer>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="djb:strongWeak" as="xs:boolean">
        <xsl:param name="stressPosition" as="xs:integer"/>
        <xsl:param name="lgContext" as="element(lg)"/>
        <xsl:param name="stressValences" as="xs:double*"/>
        <xsl:variable name="current"
            select="(djb:stressPercentage($stressPosition, $lgContext),0)[1]" as="xs:double"/>
        <xsl:variable name="preceding"
            select="(djb:stressPercentage($stressPosition - 1, $lgContext),0)[1]" as="xs:double"/>
        <xsl:variable name="following"
            select="(djb:stressPercentage($stressPosition + 1, $lgContext),0)[1]" as="xs:double"/>
        <xsl:variable name="result" as="xs:boolean">
            <xsl:choose>
                <!-- LHL HHL LHH; HLH LLH HLL; LLL HHH-->
                <!-- LHL = strong -->
                <xsl:when test="($current gt $preceding) and ($current gt $following)">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <!-- HLH = weak -->
                <xsl:when test="($current lt $preceding) and ($current lt $following)">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="djb:wordBreakPositions">
        <xsl:param name="vowelPosition" as="xs:double*"/>
        <xsl:param name="lg" as="element(lg)"/>
        <xsl:variable name="vowels"
            select="$lg/descendant::v[djb:vowelPosition(.) = $vowelPosition]" as="element(v)+"/>
        <xsl:variable name="wordBreak" select="count($vowels[not(following-sibling::v)])"
            as="xs:integer"/>
        <xsl:variable name="notWordBreak" select="count($vowels[following-sibling::v])"
            as="xs:integer"/>
        <!--    <xsl:variable name="total" select="$wordBreak + $notWordBreak" as="xs:integer"/>-->
        <xsl:sequence select="$wordBreak div count($vowels)"/>
    </xsl:function>

    <xsl:function name="djb:findMeter">
        <xsl:param name="vowels" as="element(v)+"/>
        <xsl:param name="caesura" as="xs:integer"/>

    </xsl:function>


</xsl:stylesheet>

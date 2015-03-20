<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Moves contextual information (title, attributed date, attributed place) to attributes in the root node-->

    <xsl:template match="poem">

        <poem title="{title}" dateAttr="{date}" placeAttr="{place}">
            <xsl:apply-templates/>
        </poem>

    </xsl:template>

    <xsl:template match="date|place|title"/>

    <xsl:template match="divs">
        <divs>
            <xsl:variable name="lgPreAmbient">
                <xsl:apply-templates select="lg" mode="preAmbient"/>
            </xsl:variable>
            <xsl:variable name="lgAmbientMeter">
                <xsl:apply-templates select="$lgPreAmbient" mode="ambientMeter"/>
            </xsl:variable>
            <xsl:variable name="lgMeterCorrected">
                <xsl:apply-templates select="$lgAmbientMeter" mode="propagateMeter"/>
            </xsl:variable>
            <xsl:apply-templates select="$lgMeterCorrected" mode="postAmbient"/>
        </divs>
    </xsl:template>

    <xsl:template match="lg" mode="preAmbient">
        <lg>
            <xsl:variable name="lgStress">
                <xsl:apply-templates select="l" mode="stress"/>
            </xsl:variable>
            <!-- Check for Meter -->
            <xsl:variable name="meter1">
                <xsl:apply-templates select="$lgStress" mode="meter"/>
            </xsl:variable>
            <xsl:apply-templates select="$meter1"/>
        </lg>
    </xsl:template>

    <xsl:template match="lg" mode="ambientMeter">
        <lg>
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

    <xsl:template match="lg" mode="propagateMeter">
        <lg ambientMeter="{@ambientMeter}">
            <xsl:apply-templates select="l" mode="propagateMeter"/>
        </lg>
    </xsl:template>

    <xsl:template match="l" mode="propagateMeter">
        <l rhythm="{@rhythm}" ambientMeter="{@ambientMeter}">
            <xsl:apply-templates select="w" mode="propagateMeter"/>
        </l>
    </xsl:template>

    <xsl:template match="w" mode="propagateMeter">
        <w orth="{@orth}" stressGiven="{@stressGiven}">
            <xsl:choose>
                <xsl:when test="(@monosyllable = '1' or count(v) = 1) and @stressGiven='0'">
                    <xsl:attribute name="corr">Corrected</xsl:attribute>
                    <xsl:apply-templates select="*" mode="propagateMeter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </w>
    </xsl:template>

    <xsl:template match="v" mode="propagateMeter">
        <xsl:variable name="posUltStress">
            <xsl:value-of
                select="ancestor::l/(descendant::v[@stress='1'])[last()]/sum((count(preceding-sibling::v), count(parent::w/preceding-sibling::w/v)))"
            />
        </xsl:variable>
        <xsl:variable name="posCurrent">
            <xsl:value-of
                select="sum((count(preceding-sibling::v), count(parent::w/preceding-sibling::w/v)))"
            />
        </xsl:variable>

        <v>
            <xsl:attribute name="stress">
                <xsl:choose>
                    <xsl:when test="ancestor::lg/@ambientMeter='binary'">
                        <xsl:choose>
                            <xsl:when
                                test="round(($posUltStress - $posCurrent) div 2) = (($posUltStress - $posCurrent) div 2)">
                                <xs:integer>1</xs:integer>
                            </xsl:when>
                            <xsl:otherwise>
                                <xs:integer>0</xs:integer>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::lg/@ambientMeter='ternary'">
                        <xsl:choose>
                            <xsl:when
                                test="round(($posUltStress - $posCurrent) div 3) = (($posUltStress - $posCurrent) div 3)">
                                <xs:integer>1</xs:integer>
                            </xsl:when>
                            <xsl:otherwise>
                                <xs:integer>0</xs:integer>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
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
        <xsl:variable name="total">
            <xsl:value-of select="count(w/v)"/>
        </xsl:variable>
        
        <xsl:variable name="avgDistanceBinary">
            <xsl:value-of
                select="avg(for $i in (3 to $total) return abs((w/v)[$i]/@stress - (w/v)[$i - 2]/@stress))"
            />
        </xsl:variable>
        <xsl:variable name="avgDistanceTernary">
            <xsl:value-of
                select="avg(for $i in (4 to $total) return abs((w/v)[$i]/@stress - (w/v)[$i - 3]/@stress))"
            />
        </xsl:variable>
        
        <xsl:variable name="seq">
            <xsl:for-each select="w/v">
                <xsl:choose>
                    <xsl:when test="@stress = 'probability'">
                        <xs:integer>0</xs:integer>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@stress"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:message>
            <xsl:text>Binary: </xsl:text>
            <xsl:value-of select="$avgDistanceBinary"/>
            <xsl:text>Ternary: </xsl:text>
            <xsl:value-of select="$avgDistanceTernary"/>
            <xsl:text>Rhythm: </xsl:text>
            <xsl:value-of select="$seq"/>
        </xsl:message>
        
        <l rhythm="{$seq}">
            <xsl:attribute name="ambientMeter">
                <xsl:choose>
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
            </xsl:attribute>
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
        <w orth="{orth}" stressGiven="{count(str/stress)}">
            <xsl:apply-templates mode="consVowels"/>
        </w>
    </xsl:template>

    <xsl:template match="orth" mode="consVowels"/>

    <xsl:template match="stress" mode="consVowels">
        <v stress="1">
            <xsl:apply-templates/>
        </v>
    </xsl:template>
    
    <xsl:template match="str[child::stress]" mode="consVowels">
        <xsl:apply-templates select="stress|text()" mode="consVowels"/>
    </xsl:template>
    
    <xsl:template match="str[child::stress]/text()" mode="consVowels">
        <xsl:analyze-string select="." regex="([аэыоуяеиёю])">
            <xsl:matching-substring>
                <v stress="0">
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
                                <v stress="1">
                                    <xsl:value-of select="."/>
                                </v>
                            </xsl:when>
                            <xsl:otherwise>
                                <v stress="0">
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
                        <v stress="0">
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
                test="matches(lower-case(@orth), '^(без|[в]?близ|в|в[о]?круг|да|[иа]|из|ис-под|к|н[аеи]|над|о[тб]?|п[е]?ред|под|про|против|с|сквозь|сред[иь]|ч[е]?рез|у|то|б[ы]?|л[иь]|ж[е])[о]?$')"/>
            <xsl:when
                test="./matches(lower-case((preceding-sibling::w[1])/@orth), '^(без|[в]?близ|в|в[о]?круг|да|[иа]|из|ис-под|к|н[аеи]|над|о[тб]?|п[е]?ред|под|про|против|с|сквозь|сред[иь]|ч[е]?рез|у)[о]?$')">
                <xsl:variable name="addProclitic">
                    <xsl:value-of
                        select="lower-case(concat((preceding-sibling::w[1])/@orth, ' ', @orth))"/>
                </xsl:variable>
                <w orth="{$addProclitic}" stressGiven="{@stressGiven}">
                    <xsl:if test="count(v) = 1">
                        <xsl:attribute name="monosyllable">
                            <xsl:text>1</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="(preceding-sibling::w[1])/*"/>
                    <xsl:apply-templates select="*"/>
                </w>
            </xsl:when>
            <xsl:when test="./matches((following-sibling::w[1])/@orth, '^(то|б[ы]?|л[иь]|ж[е])$')">
                <xsl:variable name="addEnclitic">
                    <xsl:value-of select="concat(@orth, ' ', (following-sibling::w[1])/@orth)"/>
                </xsl:variable>
                <w orth="{$addEnclitic}" stressGiven="{@stressGiven}">
                    <xsl:if test="count(v) = 1">
                        <xsl:attribute name="monosyllable">
                            <xsl:text>1</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="*"/>
                    <xsl:apply-templates select="(following-sibling::w[1])/*"/>
                </w>
            </xsl:when>
            <xsl:otherwise>
                <w orth="{@orth}" stressGiven="{@stressGiven}">
                    <xsl:if test="count(v) = 1">
                        <xsl:attribute name="monosyllable">
                            <xsl:text>1</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Stage Three: Combine the contents of neighboring cons elements 
    (necessary after combining proclitics)-->
    <xsl:template match="w" mode="consProclitics">
        <w orth="{@orth}" stressGiven="{@stressGiven}" monosyllable="{@monosyllable}">
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
        <lg ambientMeter="{@ambientMeter}">
            <xsl:apply-templates select="l" mode="phonetic"/>
        </lg>
    </xsl:template>

    <xsl:template match="l" mode="phonetic">
        <l rhythm="{@rhythm}" ambientMeter="{@ambientMeter}">


            <!-- Stage Four: map all soft vowels to j+hard vowel letter
            e.g. <cons>d</cons><v>ja</v> becomes <cons>dj</cons><v>a</v>-->
            <xsl:variable name="stage4output">
                <xsl:apply-templates select="w" mode="softVowels"/>
            </xsl:variable>

            <!-- Stage Five: work out compound letters (shch, ts); 
            remove soft sign after unpaired hard cons (zhj becomes zh);
            add soft sign after unpaired soft cons (ch becomes chj);-->
            <xsl:variable name="stage5output">
                <xsl:apply-templates select="$stage4output" mode="unpairedCons"/>
            </xsl:variable>

            <!-- Stage Six: reduce unstressed vowels after j to и -->
            <xsl:variable name="stage6output">
                <xsl:apply-templates select="$stage5output" mode="reduceVowels"/>
            </xsl:variable>

            <!-- Stage Seven: devoice final consonants -->
            <xsl:variable name="stage7output">
                <xsl:apply-templates select="$stage6output" mode="devoiceFinal"/>
            </xsl:variable>

            <!-- Stage Eight: voice and devoice consonant clusters -->
            <xsl:variable name="stage8output">
                <xsl:apply-templates select="$stage7output" mode="voicingClusters"/>
            </xsl:variable>

            <!-- Stage Nine: convert all Cyrillic to Latin -->
            <xsl:variable name="stage9output">
                <xsl:apply-templates select="$stage8output" mode="latinize"/>
            </xsl:variable>
            <xsl:apply-templates select="$stage9output"/>
        </l>
    </xsl:template>

    
    <!-- Stage Four: Map soft vowels to 'j'+hard paired vowel
        This leaves things "incorrect" for a while.
    -->
    <xsl:template match="w" mode="softVowels">
        <w orth="{@orth}" stressGiven="{@stressGiven}">
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
        <w orth="{@orth}" stressGiven="{@stressGiven}">
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
        <w orth="{@orth}" stressGiven="{@stressGiven}">
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
        <w orth="{@orth}" stressGiven="{@stressGiven}">
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
        <w orth="{@orth}" stressGiven="{@stressGiven}">
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
        <w orth="{@orth}" stressGiven="{@stressGiven}">
            <xsl:apply-templates select="*" mode="latinize"/>
        </w>
    </xsl:template>

    <xsl:template match="cons" mode="latinize">
        <cons>
            <xsl:value-of
                select="replace(translate(., 'бвгдзжйклмнпрстфцхчшьъ','bvgdzžjklmnprstfcxčšj″'),'([a-zžčš])\1','$1')"
            />
        </cons>
    </xsl:template>
    <xsl:template match="v" mode="latinize">
        <v stress="{@stress}">
            <xsl:value-of select="translate(lower-case(.), 'аэиыоу', 'aeiiou')"/>
        </v>
    </xsl:template>

</xsl:stylesheet>

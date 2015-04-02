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

    <xsl:template match="divs">
        <divs>
            <xsl:variable name="ambRhyme1">
                <xsl:apply-templates select="lg" mode="setUp"/>
            </xsl:variable>
            <xsl:variable name="ambRhyme2">
                <xsl:apply-templates select="$ambRhyme1" mode="match"/>
            </xsl:variable>
            <xsl:variable name="ambRhyme3">
                <xsl:apply-templates select="$ambRhyme2" mode="stanzaAmbient"/>
            </xsl:variable>
            <xsl:apply-templates select="$ambRhyme3" mode="divsAmbient"/>
        </divs>
    </xsl:template>

    <xsl:template match="lg" mode="setUp">
        <lg>
            <!-- Rhyme Stage One: Determine if possible rhyme is masc, 
                fem, dactylic -->
            <xsl:apply-templates select="l" mode="rhymeContext"/>

        </lg>
    </xsl:template>

    <xsl:template match="lg" mode="match">
        <lg>
            <!-- Rhyme Stage Three: Return lines which are exact matches-->
            <xsl:apply-templates select="l" mode="rhymeMatch"/>
        </lg>
    </xsl:template>

    <xsl:template match="lg" mode="stanzaAmbient">
        <xsl:variable name="noMatchingLines">
            <xsl:value-of select="avg(l/count(tokenize(@matchingLines, ' ')))"/>
        </xsl:variable>


        <xsl:variable name="ambientRhyme">
            <xsl:value-of select="string-join(distinct-values(l/@matchingLines), ',')"/>
        </xsl:variable>
        <lg ambRhyme="{$ambientRhyme}" avgLPerRhyme="{$noMatchingLines}">
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <!-- Rhyme Stage Two: Create "exact" match context for rhyme-->
    <xsl:template match="l" mode="rhymeContext">
        <xsl:variable name="position">
            <xsl:value-of select="(w/v[@stress = '1'])[last()]/(count(following-sibling::v)+count(parent::w/following-sibling::w/v))"/>
        </xsl:variable>
        <xsl:message>
            <xsl:value-of select="$position"/>
        </xsl:message>
        <xsl:variable name="context">
            <xsl:choose>
                <xsl:when test="(w/v[@stress = '1'])[last()] is w[last()]/child::*[last()]">
                    <xsl:value-of
                        select="string-join(w[last()]/cons[last()]/text(), w[last()]/v[last()]/text())"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="w[last()]/v[@stress='1']/concat(., string-join(following-sibling::cons|v['u']/text(), ''), string-join(parent::w/following-sibling::w/cons|v['u'],''))"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <l posRhyme="{$position}" compText="{$context}" rhythm="{@rhythm}" ambientMeter="{@ambientMeter}">
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <!-- Rhyme Stage Three: Return lines which are exact matches-->
    <xsl:template match="l" mode="rhymeMatch">
        <xsl:variable name="currentPosRhyme">
            <xsl:value-of select="@posRhyme"/>
        </xsl:variable>
        <xsl:variable name="currentCompText">
            <xsl:value-of select="@compText"/>
        </xsl:variable>
        <xsl:variable name="matchingLines">
            <xsl:value-of
                select="string-join(parent::lg/l[@compText = $currentCompText][@posRhyme=$currentPosRhyme]/string(count(preceding-sibling::l)+1), ' ')"
            />
        </xsl:variable>

        <l posRhyme="{$currentPosRhyme}" compText="{$currentCompText}" matchingLines="{$matchingLines}"  rhythm="{@rhythm}" ambientMeter="{@ambientMeter}">
            <xsl:apply-templates/>
        </l>
    </xsl:template>
</xsl:stylesheet>

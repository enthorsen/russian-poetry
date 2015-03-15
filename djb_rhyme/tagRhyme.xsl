<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="l">
        <xsl:copy>
            <xsl:attribute name="rhymeSet">
                <xsl:sequence
                    select="for $i in ../l[descendant::stress[last()] = (current()//stress)[last()]] return $i/count(preceding-sibling::l) + 1"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
        <xsl:message>
            <xsl:sequence select="../l/descendant::stress[last()]"/>
        </xsl:message>
    </xsl:template>
</xsl:stylesheet>

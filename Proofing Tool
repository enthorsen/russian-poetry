<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="html" indent="yes"
        />
    
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <html><head/>
        <body><xsl:apply-templates/></body></html>
    </xsl:template> 
    
    <xsl:template match="lg">
        <p><xsl:apply-templates select="l"/></p>
    </xsl:template>
    
    <xsl:template match="l">
        <xsl:apply-templates mode="orth"/><br/>
        <xsl:apply-templates mode="phon"/><br/>
    </xsl:template>
    
    <xsl:template match="w" mode="orth">
        <xsl:value-of select="concat(@orth, ' ')"/> 
    </xsl:template>
    
    <xsl:template match="w" mode="phon">
        <xsl:value-of select="concat(string(.), ' ')"/>
    </xsl:template>
    
</xsl:stylesheet>

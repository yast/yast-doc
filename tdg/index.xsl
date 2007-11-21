<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <!-- main template -->
    <xsl:template match="/set">
    <set>
	<xsl:apply-templates select="./setinfo"/>
	<xsl:for-each select="./book">
	    <book>
		<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
		<xsl:call-template name="book"/>
	    </book>
	</xsl:for-each>
    </set>
    </xsl:template>
    <!-- main template -->
    
    <xsl:template match="setinfo">
	<xsl:copy-of select="." disable-output-escaping="yes" />
    </xsl:template>

    <xsl:template name="book">
	<xsl:copy-of select="./bookinfo" disable-output-escaping="yes" />
    </xsl:template>

</xsl:stylesheet>
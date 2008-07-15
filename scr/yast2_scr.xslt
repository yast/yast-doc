<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- Main document //-->
    <xsl:template match="/scrdoc">
	<article>
	    <xsl:call-template name="general-header"/>
	    <xsl:apply-templates select="./mountpoints"/>
	</article>
    </xsl:template>

    <!-- Header of the document //-->
    <xsl:template name="general-header">
	<title>YaST SCR Agents</title>
	<abstract><para>Attention! API of all SCR Agents is still marked unstable
	and could change without any preceding warning.</para></abstract>
    </xsl:template>

    <xsl:template match="mountpoints">
	<xsl:for-each select="./mountpoint_item">
	    <xsl:sort order="ascending" select="./mountpoint"/>
	    <sect1>
		<xsl:attribute name="id">
		    <xsl:number/>
		    <xsl:value-of select="./mountpoint"/>
		</xsl:attribute>
		<title>
		    <xsl:choose>
			<xsl:when test="./mountpoint">
			    <xsl:value-of select="./mountpoint"/>
			</xsl:when>
			<xsl:otherwise>
			    Unknown (<xsl:number/>)
			</xsl:otherwise>
		    </xsl:choose>
		</title>
		<xsl:call-template name="scr-summary"/>
		<sect3>
		    <title>Description</title>
		    <xsl:call-template name="scr-general"/>
		    <xsl:call-template name="scr-access"/>
		    <xsl:call-template name="scr-file"/>
		    <xsl:call-template name="scr-see"/>
		</sect3>
		<xsl:call-template name="scr-example"/>
	    </sect1>
	</xsl:for-each>
    </xsl:template>

    <xsl:template name="scr-summary">
	<!-- If has summary //-->
	<xsl:if test="./summary">
	    <para>
		<xsl:value-of select="./summary"/>
	    </para>
	</xsl:if>
    </xsl:template>

    <xsl:template name="scr-general">
	<!-- If has access //-->
	<xsl:if test="./general">
	    <para>
		<xsl:value-of select="./general"/>
	    </para>
	</xsl:if>
    </xsl:template>

    <xsl:template name="scr-access">
	<!-- If has access //-->
	<xsl:if test="./access">
	    <para>
		Access type: 
		<xsl:value-of select="./access"/>
	    </para>
	</xsl:if>
    </xsl:template>

    <xsl:template name="scr-file">
	<!-- If has file //-->
	<xsl:if test="./file">
	    <para>
		File Name: 
		<literal>
		    <xsl:value-of select="./file"/>
		</literal>
	    </para>
	</xsl:if>
    </xsl:template>

    <xsl:template name="scr-see">
	<!-- If has see //-->
	<xsl:if test="./see">
	    <para>
		See also: 
		<programlisting>
		    <xsl:value-of select="./see"/>
		</programlisting>
	    </para>
	</xsl:if>
    </xsl:template>

    <xsl:template name="scr-example">
	<!-- If has example //-->
	<xsl:if test="./example">
	    <sect3>
		<title>Usage</title>
		<para>
		    <example>
			<programlisting>
			    <xsl:value-of select="./example"/>
			</programlisting>
		    </example>
		</para>
	    </sect3>
	</xsl:if>
    </xsl:template>

</xsl:stylesheet>
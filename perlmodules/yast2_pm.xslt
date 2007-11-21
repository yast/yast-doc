<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="yes"/>

    <!-- Main document //-->
    <xsl:template match="/Document">
	<!-- <article> //-->
	    <xsl:call-template name="module-header"/>
	<!-- </article> //-->
    </xsl:template>

    <!-- Header of the document //-->
    <xsl:template name="module-header">
	<sect1>
	    <xsl:attribute name="id">
		<xsl:call-template name="module-id"/>
	    </xsl:attribute>
	    <title>
		<xsl:call-template name="module-title"/>
	    </title>
	    <para>
		<xsl:call-template name="module-description"/>
	    </para>
	    <sect2>
		<title>List of Global Functions</title>
		<itemizedlist>
		<xsl:for-each select="./over-bullet/item-bullet">
		    <listitem>
			<para>
			    <ulink>
				<xsl:attribute name="url">
				    <xsl:value-of select="concat('#',generate-id())"/>
				</xsl:attribute>
				<xsl:value-of select="."/>
			    </ulink>
			</para>
		    </listitem>
		</xsl:for-each>
		</itemizedlist>
	    </sect2>
	    <sect2>
		<title>Functions</title>
		<xsl:call-template name="global-functions"/>
	    </sect2>
	</sect1>
    </xsl:template>

    <!-- Small hack: Creating ID (for filename) from the NAME //-->
    <xsl:template name="module-id">
	<xsl:for-each select="./head1">
	    <xsl:if test=".='NAME'">
		<xsl:value-of select="substring-before(translate(concat(following::Para,' '),':','-'),' ')"/>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>
    
    <!-- Searching for the NAME (removing ) //-->
    <xsl:template name="module-title">
	<xsl:for-each select="./head1">
	    <xsl:if test=".='NAME'">
		<xsl:value-of select="substring-before(concat(following::Para,' '),' ')"/>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>

    <!-- Searching for the PREFACE (Module description) //-->
    <xsl:template name="module-description">
	<xsl:for-each select="./head1">
	    <xsl:if test=".='PREFACE'">
		<xsl:value-of select="following::Para"/>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>

    <!-- Searching for functions declarations //-->
    <xsl:template name="global-functions">
	<xsl:for-each select="./head1">
	    <xsl:if test=".='DESCRIPTION'">
		<xsl:for-each select="following::item-bullet">
		    <sect3>
			<!-- ID is used as the target of the link //-->
			<xsl:attribute name="id">
			    <xsl:value-of select="generate-id()"/>
			</xsl:attribute>
			<title>
			    <xsl:value-of select="."/>
			</title>
			<para>
			    <xsl:value-of select="following::Para"/>
			    <!--
				Ugly HACK!!!
				    It finds next <item-bullet> and then goes through the document,
				    generates examples until it find the <item-bullet>.
				
				If you have a better idea, which works, please, let me know.
			    //-->
			    
			    <xsl:variable name="exit" select="substring-after(generate-id(following::item-bullet),'id')"/>
			    <xsl:for-each select="following::Para | following::Verbatim">
				<xsl:choose>
				    <xsl:when test="substring-after((generate-id()),'id')&gt;$exit">
				    </xsl:when>
				    <xsl:otherwise>
					<!-- Verbatim == Example //-->
					<xsl:if test="name()='Verbatim'">
					    <example>
						<programlisting>
						    <xsl:value-of select="."/>
						</programlisting>
					    </example>
					</xsl:if>
				    </xsl:otherwise>
				</xsl:choose>
			    </xsl:for-each>
			</para>
		    </sect3>
		</xsl:for-each>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
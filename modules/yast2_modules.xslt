<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" encoding="UTF-8"/>



    <!-- MAIN DOCUMENT STARTS HERE //-->

    <!-- Main document //-->
    <xsl:template match="/ycpdoc">
	<article>
	    <xsl:call-template name="general-header"/>
	    <xsl:apply-templates select="./files"/>
	</article>
    </xsl:template>

    <!-- All Modules //-->
    <xsl:template match="files">
	<xsl:for-each select="./file_item">
	    <xsl:sort order="ascending" select="./name"/>
	    <!-- Internal modules are not used for generation -->
	    <xsl:choose>
	    <xsl:when test="./header/internal=1">
		<!-- Internal Module -->
	    </xsl:when>
	    <!-- Otherwise proceed -->
	    <xsl:otherwise>
		<sect1>
		    <xsl:for-each select="./requires/requires_item">
			<xsl:if test="./kind='module'">
			    <xsl:attribute name="id">
				<xsl:value-of select="./name"/>
			    </xsl:attribute>
			</xsl:if>
		    </xsl:for-each>

		    <xsl:call-template name="module-header"/>
		    <xsl:call-template name="module-provides"/>
		    <xsl:call-template name="module-requirements"/>
		</sect1>
	    </xsl:otherwise>
	    </xsl:choose>
	</xsl:for-each>
    </xsl:template>

    <!-- MAIN DOCUMENT ENDS HERE //-->



    <!-- Header of the document //-->
    <xsl:template name="general-header">
	<title>YaST Modules</title>
	<abstract><para>Attention! API of all YaST modules is still marked unstable
	and could change without any preceding warning.</para></abstract>
    </xsl:template>

    <!-- Module Requirements //-->
    <xsl:template match="file_item/requires">
	<xsl:call-template name="requirements"/>
    </xsl:template>

    <!-- Module Header //-->
    <xsl:template name="module-header">
	<!-- Funny, that the module name is in 'requires' instead of beeing in 'provides' //-->
	<!-- Module-Name //-->
	<title>
	    <xsl:for-each select="./requires/requires_item">
	    <xsl:if test="./kind='module'">
		<xsl:value-of select="./name"/>
	    </xsl:if>
	    </xsl:for-each>
	</title>
	<!-- Module-Name //-->
	<para>
	    <xsl:value-of select="./header/summary"/>
	</para>

	<!-- bnc #401680 - Documentation with info about maintainer -->
	<xsl:if test="./header/authors">
	<sect2>
	    <title>Authors</title>
	    <itemizedlist>
	    <xsl:for-each select="./header/authors/ITEM">
		<listitem><para><xsl:value-of select="."/></para></listitem>
	    </xsl:for-each>
	    </itemizedlist>
	</sect2>
	</xsl:if>
    </xsl:template>

    <!-- Module Provides... //-->
    <xsl:template name="module-provides">
	<sect2>
	    <title>Summary of Module Globals</title>
	    <sect3>
		<xsl:call-template name="global-functions-summary"/>
	    </sect3>
	    <sect3>
		<xsl:call-template name="global-variables-summary"/>
	    </sect3>
	</sect2>
	<sect2>
	    <title>Global Functions</title>
	    <xsl:call-template name="global-functions"/>
	</sect2>
	<sect2>
	    <title>Global Variables</title>
	    <xsl:call-template name="global-variables"/>
	</sect2>
    </xsl:template>




    <!-- Global variables of the Module //-->
    <xsl:template name="global-variables">
	<xsl:for-each select="./provides/provides_item">
	    <xsl:sort order="ascending" select="./name"/>
	    <xsl:if test="./global=1 and ./kind='variable'">
		<sect3>
		    <xsl:attribute name="id">
			<xsl:value-of select="./name"/>
		    </xsl:attribute>
		    <xsl:call-template name="global-variable-header"/>
		</sect3>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>

    <!-- Global Functions of the Module - Summary //-->
    <xsl:template name="global-functions-summary">
	<itemizedlist>
	<title>List of Global Functions</title>
	<xsl:for-each select="./provides/provides_item">
	    <xsl:sort order="ascending" select="./name"/>
	    <xsl:if test="./global=1 and ./kind='function'">
		<listitem>
		    <para>
			<ulink>
			    <xsl:attribute name="url">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="./name"/>
			    </xsl:attribute>
			    <xsl:value-of select="./name"/>
			</ulink>
			<xsl:text> - </xsl:text>
			<comment>
			    <xsl:value-of select="./short"/>
			</comment>
		    </para>
		</listitem>
	    </xsl:if>
	</xsl:for-each>
	</itemizedlist>
    </xsl:template>

    <!-- Global Variables of the Module - Summary //-->
    <xsl:template name="global-variables-summary">
	<itemizedlist>
	<title>List of Global Variables</title>
	<xsl:for-each select="./provides/provides_item">
	    <xsl:sort order="ascending" select="./name"/>
	    <xsl:if test="./global=1 and ./kind='variable'">
		<listitem>
		    <para>
			<ulink>
			    <xsl:attribute name="url">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="./name"/>
			    </xsl:attribute>
			    <xsl:value-of select="./name"/>
			</ulink>
			<xsl:text> - </xsl:text>
			<comment>
			    <xsl:value-of select="./short"/>
			</comment>
		    </para>
		</listitem>
	    </xsl:if>
	</xsl:for-each>
	</itemizedlist>
    </xsl:template>

    <!-- Global Function Header //-->
    <xsl:template name="global-variable-header">
	<!-- Module name and Description -->
	<title>
	    <xsl:value-of select="name"/>
	</title>
	<para>
	    <xsl:value-of select="short"/>
	</para>
	<para>
	    <xsl:value-of select="descr"/>
	</para>
	<xsl:call-template name="global-variable-scruple"/>
	<xsl:call-template name="global-xyz-see"/>
    </xsl:template>

    <!-- Global Variable Scruple //-->
    <xsl:template name="global-variable-scruple">
	<!-- If has example //-->
	<xsl:if test="./scruple!=''">
	    <para>
		<programlisting>
		    <xsl:value-of select="./scruple"/>
		</programlisting>
	    </para>
	</xsl:if>
    </xsl:template>

    <!-- Global functions of the Module -->
    <xsl:template name="global-functions">
	<xsl:for-each select="./provides/provides_item">
	    <xsl:sort order="ascending" select="./name"/>
	    <xsl:if test="./global=1 and ./kind='function'">
		<sect3>
		    <xsl:attribute name="id">
			<xsl:value-of select="./name"/>
		    </xsl:attribute>
		    <xsl:call-template name="global-function-header"/>
		    <xsl:call-template name="global-function-parameters"/>
		    <xsl:call-template name="global-function-returns"/>
		    <xsl:call-template name="global-function-scruple"/>
		    <xsl:call-template name="global-function-example"/>
		    <xsl:call-template name="global-xyz-see"/>
		</sect3>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>

    <!-- Global Function Header //-->
    <xsl:template name="global-function-header">
	<!-- Module name and Description -->
	<title>
	    <xsl:value-of select="./name"/>
	</title>
	<para>
	    <xsl:value-of select="./short"/>
	</para>
    </xsl:template>

    <!-- Global Function Parameters //-->
    <xsl:template name="global-function-parameters">
	<!-- If has param types //-->
	<xsl:if test="./parameters/parameters_item">
	    <itemizedlist>
		<title>Function parameters</title>
		<xsl:for-each select="./parameters/parameters_item">
		    <listitem>
			<para>
			    <emphasis>
				<xsl:value-of select="./type"/>
			    </emphasis>
			    <xsl:text> </xsl:text>
			    <xsl:value-of select="./name"/>
			    <xsl:if test="./descr">
				<xsl:text> - </xsl:text>
				<comment>
				    <xsl:value-of select="./descr"/>
				</comment>
			    </xsl:if>
			</para>
		    </listitem>
		</xsl:for-each>
	    </itemizedlist>
	</xsl:if>
    </xsl:template>

    <!-- Global Function Returns //-->
    <xsl:template name="global-function-returns">
	<!-- If has return type //-->
	<xsl:if test="./type">
	    <itemizedlist>
		<title>Return value</title>
		<listitem>
		    <para>
			<emphasis>
			    <xsl:value-of select="./type"/>
			</emphasis>
			<xsl:if test="./return">
			    <xsl:text> - </xsl:text>
			    <comment>
				<xsl:value-of select="./return"/>
			    </comment>
			</xsl:if>
		    </para>
		</listitem>
	    </itemizedlist>
	</xsl:if>
    </xsl:template>

    <!-- Global Function Scruple //-->
    <xsl:template name="global-function-scruple">
	<!-- If has example //-->
	<xsl:if test="./scruple!=''">
	    <para>
		<programlisting>
		    <xsl:value-of select="./scruple"/>
		</programlisting>
	    </para>
	</xsl:if>
    </xsl:template>

    <!-- Global Function Example //-->
    <xsl:template name="global-function-example">
	<!-- If has example //-->
	<xsl:if test="./example">
	    <para>
		<example>
		    <programlisting>
			<xsl:value-of select="./example"/>
		    </programlisting>
		</example>
	    </para>
	</xsl:if>
    </xsl:template>

    <!-- Function or variable @see -->
    <xsl:template name="global-xyz-see">
	<!-- If has some @see defined -->
	<xsl:if test="./see!=''">
	<para>
	    See also: 
	    <itemizedlist>
		<xsl:for-each select="./see/see_item">
		    <listitem><para><xsl:value-of select="."/></para></listitem>
		</xsl:for-each>
	    </itemizedlist>
	</para>
	</xsl:if>
    </xsl:template>

    <!-- Module Requirements (Imports and Includes) //-->
    <xsl:template name="module-requirements">
	<sect2>
	    <title>Module Requirements</title>
	    <xsl:choose>
		<!-- If Module imports or includes other ones //-->
		<!-- !!! The first 'requires_item' is the module name !!! //-->
		<xsl:when test="count(./requires/requires_item)>1">
		    <sect3>
			<title>Module Imports</title>
			<itemizedlist>
			    <xsl:for-each select="./requires/requires_item">
				<xsl:sort order="ascending" select="./name"/>
		    		<xsl:if test="./kind='import'">
				    <listitem>
					<xsl:variable name="has-imports" select="1"/>
					<xsl:value-of select="./name"/>
				    </listitem>
				</xsl:if>
			    </xsl:for-each>
			</itemizedlist>
		    </sect3>
		    <sect3>
			<title>Module Includes</title>
			<itemizedlist>
			    <xsl:for-each select="./requires/requires_item">
				<xsl:sort order="ascending" select="./name"/>
		    		<xsl:if test="./kind='include'">
				    <listitem>
					<xsl:value-of select="./name"/>
				    </listitem>
				</xsl:if>
			    </xsl:for-each>
			</itemizedlist>
		    </sect3>
		</xsl:when>
		<xsl:otherwise>
		    <para>none</para>
		</xsl:otherwise>
	    </xsl:choose>
	</sect2>
    </xsl:template>

</xsl:stylesheet>

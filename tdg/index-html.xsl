<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

   <xsl:import
       href="http://docbook.sourceforge.net/release/xsl/current/html/chunk.xsl"/>

  <!-- Output directory -->
  <xsl:param name="base.dir" select="'html/'"/>

  <!--- Number sections -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

  <xsl:param name="chunk.fast">1</xsl:param>
  
  <xsl:param name="generate.legalnotice.link">0</xsl:param>

  <!--
    book:	suppress list of figure,table,example
    chapter:	generate toc for each chapter
    see: http://www.sagehill.net/docbookxsl/TOCcontrol.html#TOCcomponents
  -->
<!--
  <xsl:param name="toc.section.depth">1</xsl:param>
  <xsl:param name="generate.toc">
    book toc,title,equation
    chapter toc,title
  </xsl:param>
-->

  <!-- use ids as filename instead of numbers -->
  <xsl:param name="use.id.as.filename" select="'1'"></xsl:param>

  <!-- draft mode? 
  <xsl:param name="draft.mode" select="'no'"></xsl:param>
  <xsl:param name="draft.watermark.image" select="'images/draft.png'"></xsl:param>
  -->
  <!-- deprecated
<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="border">0</xsl:attribute>
  <xsl:attribute name="width">100%</xsl:attribute>
  <xsl:attribute name="bgcolor">#E0E0E0</xsl:attribute>
</xsl:attribute-set>
-->

  <xsl:param name="navig.showtitles">1</xsl:param>
  <xsl:param name="html.extra.head.links" select="0"></xsl:param>

  <!-- use custom icons for navigation -->
  <xsl:param name="navig.graphics" select="1"/>
  <xsl:param name="navig.graphics.path">../images/</xsl:param>
  <xsl:param name="navig.graphics.extension" select="'.png'"/>

  <!-- use custom icons for admonition -->
  <xsl:param name="admon.graphics" select="1"/>
  <xsl:param name="admon.graphics.path">../images/</xsl:param>
  <xsl:param name="admon.graphic.width" select="32"/>
  <xsl:param name="admon.style" select="''"/>

  <!-- Use shade for verbatim environments -->
  <!-- 
  <xsl:param name="shade.verbatim" select="1"></xsl:param>
  -->

  <xsl:param name="header.rule" select="0"></xsl:param>
  <xsl:param name="footer.rule" select="0"></xsl:param>

  <!-- Show revisionflag -->
  <xsl:param name="show.revisionflag">1</xsl:param>

  <!-- shut up!  -->
  <xsl:param name="chunk.quietly" select="0"></xsl:param>

  <!-- include header.xsl -->
  <!--
  <xsl:include href="header.xsl" />
  -->

  <xsl:param name="funcsynopsis.style">ansi</xsl:param>
  <!--
  <xsl:param name="funcsynopsis.decoration">1</xsl:param>
  <xsl:param name="funcsynopsis.tabular.threshold" select="40"></xsl:param>
  -->
  <xsl:variable name="arg.choice.def.open.str"></xsl:variable>
  <xsl:variable name="arg.choice.def.close.str"></xsl:variable>
</xsl:stylesheet>

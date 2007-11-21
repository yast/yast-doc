<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <xsl:output method="html"/>

  <!--
    This function needs $search-path and $search-domain set on the commandline
  -->

  <xsl:template name="search_form">
    <div class="search_form">
      <form method="GET" action="http://www.google.com/custom">
        <input type="text"   name="q" size="12" maxlength="255" value="" class="search_form" />
        <input type="hidden" name="cof">
	    <xsl:attribute name="value">BIMG:<xsl:value-of select="$search-path"/>;L:<xsl:value-of select="$site-logo-url"/>;LW:<xsl:value-of select="$site-logo-x"/>;LH:<xsl:value-of select="$site-logo-y"/>;GALT:#333333;VLC:#CC0000;AH:left;BGC:#ffffff;LC:#CC0000;GFNT:#999999;ALC:#333333;T:#333333;GIMP:#CC0000;AWFID:23d9b5f3e6028ddd;</xsl:attribute>
	</input>
        <input type="hidden" name="domains"><xsl:attribute name="value"><xsl:value-of select="$search-domain"/></xsl:attribute></input>
        <input type="hidden" name="sitesearch"><xsl:attribute name="value"><xsl:value-of select="$search-domain"/></xsl:attribute></input>
        <input type="hidden" name="q"><xsl:attribute name="value">inurl:<xsl:value-of select="$search-path"/></xsl:attribute></input>
        <input type="submit" name="sa" value="Search" class="search_button" />
      </form>
    </div>
  </xsl:template>

</xsl:stylesheet>

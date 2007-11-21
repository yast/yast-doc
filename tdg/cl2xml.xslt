<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"  xmlns:cvs2cl="http://www.red-bean.com/xmlns/cvs2cl/">
    <xsl:output method="xml" encoding="UTF-8"/>
    <xsl:template match="/cvs2cl:changelog">
        <revhistory>
            <xsl:for-each select="cvs2cl:entry">
                <revision>
                    <date><xsl:value-of select="cvs2cl:date"/></date>
                    <revnumber></revnumber>
                    <authorinitials><xsl:value-of select="cvs2cl:author"/></authorinitials>
                    <revremark>
                        <itemizedlist>
                            <xsl:for-each select="cvs2cl:file">
                                <listitem><para><xsl:value-of select="cvs2cl:name"/></para></listitem>
                                <xsl:if test="position() != last()">, </xsl:if>
                            </xsl:for-each>
                        </itemizedlist>
                        <screen><xsl:value-of select="cvs2cl:msg"/></screen>

                    </revremark>
                </revision>
            </xsl:for-each>
        </revhistory>
    </xsl:template>
</xsl:stylesheet>

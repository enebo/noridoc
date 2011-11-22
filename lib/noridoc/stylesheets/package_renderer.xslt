<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
    <head>
      <link rel="stylesheet" href="file:///Users/enebo/work/noridoc/style.css"/>
    </head>
    <body>
      <xsl:apply-templates select="packages"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="packages">
  <xsl:apply-templates select="package"/>
</xsl:template>

<xsl:template match="package">
  <xsl:apply-templates select="containing_packages"/>
  <div class="package">
    <div class="package_list">
      <xsl:apply-templates select="class_list"/>
    </div>
  </div>
</xsl:template>

<xsl:template match="containing_packages">
  <xsl:for-each select="containing_package">
  <a class="package_name"><xsl:attribute name="href"><xsl:value-of select="@package_path"/>.html</xsl:attribute><xsl:value-of select="@name"/></a><span class="package_name"> </span>
    <xsl:if test="position() &lt; last()">
      <xsl:text>.</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match="class_list">
  <xsl:for-each select="class">
    <a><xsl:attribute name="href"><xsl:value-of select="@package_path"/>/<xsl:value-of select="@name"/>.html</xsl:attribute><xsl:value-of select="@name"/></a>
    <xsl:if test="position() &lt; last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet> 

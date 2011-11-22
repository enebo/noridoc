<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
    <head>
      <link rel="stylesheet" href="file:///Users/enebo/work/noridoc/style.css"/>
    </head>
    <body>
      <xsl:apply-templates select="class"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="class">
  <div class="left">
    <xsl:apply-templates select="all_packages"/>
    <div class="class_overview">
      <div class="method_title">Methods</div>
      <ul class="method_list">
        <xsl:apply-templates select="method_outline/method_item"/>
      </ul>
    </div>
  </div>
  <div class="class_header"><span class="package"><xsl:value-of select="@package"/></span>.<span class="class_name"><xsl:value-of select="@name"/></span>
  <xsl:apply-templates select="superclass"/>
  </div>
  <xsl:apply-templates select="method_details"/>
</xsl:template>

<xsl:template match="all_packages">
    <div class="upper_left">
      <a><xsl:attribute name="href"><xsl:value-of select="@path"/>/all_packages.html</xsl:attribute>All Packages</a>
    </div>
</xsl:template>

<xsl:template match="method_details">
  <div class="class_detail">
    <xsl:apply-templates select="method_detail"/>
  </div>
</xsl:template>

<xsl:template match="superclass">
  <span class="superclass_package">&lt; <xsl:value-of select="@package"/></span>.<span class="superclass_class_name"><xsl:value-of select="@name"/></span>
</xsl:template>

<xsl:template match="method_detail">
  <a><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute></a>
  <div class="method">
    <div class="method_header">
      <span class="method_name"><xsl:value-of select="@name"/></span>
      <span class="method_params">(<xsl:value-of select="@param_string"/>)</span>
      <xsl:apply-templates select="ruby_aliases"/>
    </div>
    <div class="method_description">
    </div>
    <xsl:apply-templates select="param"/>
    <xsl:apply-templates select="returns"/>
  </div>
</xsl:template>

<xsl:template match="ruby_aliases">
  <span class="aliases">aliases</span> <span class="method_aliases">
  <xsl:for-each select="ruby_alias">
    <xsl:value-of select="@name"/>
    <xsl:if test="position() &lt; last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
  </span>
</xsl:template>

<xsl:template match="param">
  <div class="method_param">
    <span class="param_name"><xsl:value-of select="@name"/></span><xsl:value-of select="."/>
  </div>
</xsl:template>

<xsl:template match="returns">
  <div class="method_return">
    <span class="return">returns</span><xsl:value-of select="."/>
  </div>
</xsl:template>

<xsl:template match="method_item">
  <a><xsl:attribute name="href">#<xsl:value-of select="@anchor"/></xsl:attribute><li><xsl:attribute name="class"><xsl:value-of select="@type"/>_method_name</xsl:attribute><xsl:value-of select="@name"/></li></a>
</xsl:template>
</xsl:stylesheet> 

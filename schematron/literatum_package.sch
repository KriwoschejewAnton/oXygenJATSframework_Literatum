<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:html="http://www.w3.org/1999/xhtml"
  queryBinding="xslt2">
  
  <ns prefix="c" uri="http://www.w3.org/ns/xproc-step"/>
  <ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
  <ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  
  <pattern id="input-file">
    <rule context="/*">
      <let name="top-level-files" value="c:file[not(@ignore = 'true')]"/>
      <!--<xsl:variable name="link" as="element(html:a)?">
        <a xmlns="http://www.w3.org/1999/xhtml" href="{$top-level-files/@target-uri}"><xsl:value-of select="$top-level-files/@name"/></a>
      </xsl:variable>-->
      <assert test="self::c:directory" role="fatal">Apparently, no directory listing could be produced.</assert>
      <assert test="count($top-level-files) = 1" role="fatal">There must be exactly one submission manifest file, called 'manifest.xml', as input.
      Are you sure that you are processing a manifest file?</assert>
      <report test="$top-level-files/c:errors" role="error">The submission manifest file must be valid against Atypon’s 'submissionmanifest.4.1.dtd'.
      <xsl:sequence select="$top-level-files/c:errors"/></report>
      <!--<assert test="if ($top-level-files) then $top-level-files/@name = 'manifest.xml' else true()" role="fatal">
        The input file must be called 'manifest.xml'. Found: '<xsl:sequence select="$link"/>'.
      </assert>-->
      
    </rule>
  </pattern>
  
  <xsl:template match="c:refd-files/*" xmlns="http://www.w3.org/1999/xhtml" mode="refd-files">
    <li>
      <xsl:value-of select="name(), @orig-href" separator=" "/>
    </li>
  </xsl:template>
  
  <pattern id="refd-files">
    <rule context="c:file[c:refd-files]">
      <let name="all-files" value="//c:file/@xlink:href"/>
      <let name="unresolved" value="c:refd-files/*[@xlink:href[not(. = $all-files)]]"/>
      <assert test="count($unresolved) = 0" role="error">
        The following files have been referenced in <value-of select="string-join(ancestor-or-self::*/@name, '/')"/>, but they are missing:
      <ul xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates select="$unresolved" mode="refd-files"/></ul></assert>
    </rule>
  </pattern>
  
  <pattern id="templates">
    <rule context="/c:directory/c:file/submission">
      <report test="@group-doi = '10.000/dummy'" role="error">Please fill in the 'group-doi' attribute in the manifest.</report>
      <assert test="@submission-type = 'full'" role="error">Only full submissions are currently supported.</assert>
      <assert test="exists(callback/email[normalize-space()])" role="warning">At least one mail address must be given if you want to receive a submission report.</assert>
    </rule>
  </pattern>
  
</schema>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
    xmlns:p="Pipeline" version="3.0">

    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="/">
        <xsl:apply-templates select="example/source" mode="#current">
            <xsl:with-param name="pipeline" select="example/p:pipeline" tunnel="true"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="text()[matches(., '\S')]">
        <xsl:param name="pipeline" tunnel="true"/>
        <xsl:call-template name="pipeline">
            <xsl:with-param name="input" select="." as="xs:string"/>
            <xsl:with-param name="pipeline" as="element()" select="$pipeline"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="pipeline" as="item()*">
        <xsl:param name="input" as="item()*"/>
        <xsl:param name="pipeline" as="element()"/>
        <xsl:iterate select="$pipeline/*">
            <xsl:param name="input" select="$input"/>
            <xsl:on-completion>
                <xsl:sequence select="$input"/>
            </xsl:on-completion>
            <xsl:next-iteration>
                <xsl:with-param name="input" as="item()*">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="input" select="$input"/>
                    </xsl:apply-templates>
                </xsl:with-param>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:template>

    <xsl:template match="p:tokenize" as="xs:string*">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:variable name="split" select="(@split, '\s+')[1]"/>
        <xsl:sequence select="tokenize($input, $split)"/>
    </xsl:template>

    <xsl:template match="p:string-join" as="xs:string">
        <xsl:param name="input" as="item()*"/>
        <xsl:variable name="sep" select="(@separator, ' ')[1]"/>
        <xsl:sequence select="string-join($input ! string(.), $sep)"/>
    </xsl:template>
    <xsl:template match="p:lower-case" as="xs:string*">
        <xsl:param name="input" as="item()*"/>
        <xsl:sequence select="$input ! string(.) ! lower-case(.)"/>
    </xsl:template>
    <xsl:template match="p:capitalize" as="xs:string*">
        <xsl:param name="input" as="item()*"/>
        <xsl:sequence
            select="$input ! string(.) ! (upper-case(substring(., 1, 1)) || lower-case(substring(., 2)))"
        />
    </xsl:template>

    <xsl:template match="p:reverse" as="item()*">
        <xsl:param name="input" as="item()*"/>
        <xsl:sequence select="reverse($input)"/>
    </xsl:template>
    <xsl:template match="p:remove" as="item()*">
        <xsl:param name="input" as="item()*"/>
        <xsl:variable name="match" select="(@match, ' ')[1]"/>
        <xsl:sequence select="$input[not(matches(., $match))]"/>
    </xsl:template>

    <xsl:template match="p:replace" as="xs:string*">
        <xsl:param name="input" as="item()*"/>
        <xsl:variable name="match" select="(@match, ' ')[1]"/>
        <xsl:variable name="replace" select="(@replace, ' ')[1]"/>
        <xsl:sequence select="$input ! string(.) ! replace(., $match, $replace)"/>
    </xsl:template>
    <xsl:template match="p:swap" as="xs:string*">
        <xsl:param name="input" as="item()*"/>
        <xsl:variable name="s1" select="@s1"/>
        <xsl:variable name="s2" select="@s2"/>
        <xsl:for-each select="$input">
            <xsl:variable name="parts" as="xs:string*">
                <xsl:analyze-string select="string(.)" regex="{$s1}|{$s2}">
                    <xsl:matching-substring>
                        <xsl:sequence
                            select="
                                if (. eq $s1) then
                                    $s2
                                else
                                    $s1"
                        />
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:sequence select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:sequence select="string-join($parts)"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="p:pipeline" as="item()*">
        <xsl:param name="input" as="item()*"/>
        <xsl:call-template name="pipeline">
            <xsl:with-param name="input" select="$input"/>
            <xsl:with-param name="pipeline" select="."/>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>


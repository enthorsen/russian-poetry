<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:djb="http://www.obdurodon.org" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="root" select="." as="document-node()"/>
    <xsl:variable name="maxVowelPosition"
        select="max(for $line in //l return count($line//v))" as="xs:integer"/>
    <xsl:function name="djb:stressPercentage" as="xs:double">
        <xsl:param name="stressPosition"/>
        <xsl:variable name="vowels"
            select="$root//l/descendant::v[position() eq $stressPosition]"
            as="element(v)+"/>
        <xsl:variable name="stressed" select="count($vowels[@stress eq '1'])" as="xs:integer"/>
        <xsl:variable name="unstressed" select="count($vowels[@stress eq '-1'])" as="xs:integer"/>
        <xsl:variable name="total" select="$stressed + $unstressed" as="xs:integer"/>
        <xsl:sequence select="$stressed div count($vowels)"/>
        <xsl:message>
            <xsl:sequence select="$vowels"/>
        </xsl:message>
    </xsl:function>
    <xsl:function name="djb:strongWeak" as="xs:boolean">
        <xsl:param name="stressPosition" as="xs:integer"/>
        <xsl:variable name="current" select="(djb:stressPercentage($stressPosition),0)[1]"
            as="xs:double"/>
        <xsl:variable name="preceding" select="(djb:stressPercentage($stressPosition - 1),0)[1]"
            as="xs:double"/>
        <xsl:variable name="following" select="(djb:stressPercentage($stressPosition + 1),0)[1]"
            as="xs:double"/>
        <xsl:variable name="result" as="xs:boolean">
            <xsl:choose>
                <!-- LHL HHL LHH; HLH LLH HLL; LLL HHH-->
                <!-- LHL = strong -->
                <xsl:when test="$current ge $preceding and $current le $following">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <!-- HLH = weak -->
                <xsl:when test="$current le $preceding and $current ge $following">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$result"/>
    </xsl:function>
    <xsl:variable name="stressValences" as="xs:double*">
        <xsl:for-each select="1 to $maxVowelPosition">
            <xsl:sequence select="djb:stressPercentage(current())"/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <!--#set var="title" value="Verse Table"-->
            <!--#config timefmt="%Y-%m-%dT%X%z"-->
            <head>
                <!--#include virtual="../inc/poetry-header.html"-->
                <link rel="stylesheet" type="text/css" href="../css/verseTableCSS.css"/>
                <link rel="stylesheet" type="text/css" href="style.css"/>
                <style type="text/css">
                    body{
                        display:flex;
                    }
                    svg{
                        float:right;
                        margin:0 0 1em 2em;
                    }
                    td{
                        white-space:nowrap;
                    }</style>
                <title>Александр Сергеевич Пушкин: К ***</title>
            </head>
            <body>
                <!--#include virtual="../inc/poetry-boilerplate.html"-->
                <div class="content">
                    <h3>К ***</h3>
                    <h4>Александр Сергеевич Пушкин</h4>
                    <table>
                        <tr>
                            <th>Line</th>
                            <th>Text</th>
                            <th>Meter</th>
                            <th>Rhyme</th>
                            <th>Stressed<br/>Vowels</th>
                        </tr>
                        <tr class="odd">
                            <td class="number">1</td>
                            <td>Я п<span class="stress">о</span>мню ч<span class="stress"
                                    >у</span>дное мгнов<span class="stress">е</span>нье: </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowelu">U </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">2</td>
                            <td>Передо мн<span class="stress">о</span>й яв<span class="stress"
                                    >и</span>лась т<span class="stress">ы</span>, </td>
                            <td class="meter"><span data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="odd">
                            <td class="number">3</td>
                            <td>Как мимол<span class="stress">ё</span>тное вид<span class="stress"
                                    >е</span>нье, </td>
                            <td class="meter"><span data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">4</td>
                            <td>Как г<span class="stress">е</span>ний ч<span class="stress"
                                    >и</span>стой красот<span class="stress">ы</span>. </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowele">E </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="blank">
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                        </tr>
                        <tr class="odd">
                            <td class="number">5</td>
                            <td>В томл<span class="stress">е</span>ньях гр<span class="stress"
                                    >у</span>сти безнад<span class="stress">е</span>жной, </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowele">E </span>
                                <span class="vowelu">U </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">6</td>
                            <td>В трев<span class="stress">о</span>гах ш<span class="stress"
                                    >у</span>мной сует<span class="stress">ы</span>, </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowelu">U </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="odd">
                            <td class="number">7</td>
                            <td>Звуч<span class="stress">а</span>л мне д<span class="stress"
                                    >о</span>лго г<span class="stress">о</span>лос н<span
                                    class="stress">е</span>жный </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowela">A </span>
                                <span class="vowelo">O </span>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">8</td>
                            <td>И сн<span class="stress">и</span>лись м<span class="stress"
                                    >и</span>лые черт<span class="stress">ы</span>. </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="blank">
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                        </tr>
                        <tr class="odd">
                            <td class="number">9</td>
                            <td>Шл<span class="stress">и</span> г<span class="stress"
                                    >о</span>ды. Б<span class="stress">у</span>рь пор<span
                                    class="stress">ы</span>в мят<span class="stress"
                                >е</span>жный </td>
                            <td class="meter"><span data-meter="head-One" class="xx">xx</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="voweli">I </span>
                                <span class="vowelo">O </span>
                                <span class="vowelu">U </span>
                                <span class="voweli">I </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">10</td>
                            <td>Расс<span class="stress">е</span>ял пр<span class="stress"
                                    >е</span>жние мечт<span class="stress">ы</span>, </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowele">E </span>
                                <span class="vowele">E </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="odd">
                            <td class="number">11</td>
                            <td>И <span class="stress">я</span> заб<span class="stress"
                                >ы</span>л твой г<span class="stress">о</span>лос н<span
                                    class="stress">е</span>жный, </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowela">A </span>
                                <span class="voweli">I </span>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">12</td>
                            <td>Тво<span class="stress">и</span> неб<span class="stress"
                                    >е</span>сные черт<span class="stress">ы</span>. </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="voweli">I </span>
                                <span class="vowele">E </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="blank">
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                        </tr>
                        <tr class="odd">
                            <td class="number">13</td>
                            <td>В глуш<span class="stress">и</span>, во мр<span class="stress"
                                    >а</span>ке заточ<span class="stress">е</span>нья </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="voweli">I </span>
                                <span class="vowela">A </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">14</td>
                            <td>Тян<span class="stress">у</span>лись т<span class="stress"
                                    >и</span>хо дн<span class="stress">и</span> мо<span
                                    class="stress">и</span> </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowelu">U </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="odd">
                            <td class="number">15</td>
                            <td>Без божеств<span class="stress">а</span>, без вдохнов<span
                                    class="stress">е</span>нья, </td>
                            <td class="meter"><span data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowela">A </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">16</td>
                            <td>Без с<span class="stress">л</span>ёз, без ж<span class="stress"
                                    >и</span>зни, без любв<span class="stress">и</span>. </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="blank">
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                        </tr>
                        <tr class="odd">
                            <td class="number">17</td>
                            <td>Душ<span class="stress">е</span> наст<span class="stress"
                                    >а</span>ло пробужд<span class="stress">е</span>нье: </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowele">E </span>
                                <span class="vowela">A </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">18</td>
                            <td>И в<span class="stress">о</span>т оп<span class="stress"
                                    >я</span>ть яв<span class="stress">и</span>лась т<span
                                    class="stress">ы</span>, </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowela">A </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="odd">
                            <td class="number">19</td>
                            <td>Как мимол<span class="stress">ё</span>тное вид<span class="stress"
                                    >е</span>нье, </td>
                            <td class="meter"><span data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">20</td>
                            <td>Как г<span class="stress">е</span>ний ч<span class="stress"
                                    >и</span>стой красот<span class="stress">ы</span>. </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowele">E </span>
                                <span class="voweli">I </span>
                                <span class="voweli">I </span>
                            </td>
                        </tr>
                        <tr class="blank">
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                            <td/>
                        </tr>
                        <tr class="odd">
                            <td class="number">21</td>
                            <td>И с<span class="stress">е</span>рдце бь<span class="stress"
                                >ё</span>тся в упо<span class="stress">е</span>нье </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowele">E </span>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">22</td>
                            <td>И для нег<span class="stress">о</span> воскр<span class="stress"
                                    >е</span>сли вн<span class="stress">о</span>вь </td>
                            <td class="meter"><span data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                                <span class="vowelo">O </span>
                            </td>
                        </tr>
                        <tr class="odd">
                            <td class="number">23</td>
                            <td>И божеств<span class="stress">о</span>, и вдохнов<span
                                    class="stress">е</span>нье, </td>
                            <td class="meter"><span data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span class="ox"
                                    data-meter="head-One">ox</span><span class="hypermetric"
                                    >(o)</span></td>
                            <td>A</td>
                            <td>
                                <span class="vowelo">O </span>
                                <span class="vowele">E </span>
                            </td>
                        </tr>
                        <tr class="even">
                            <td class="number">24</td>
                            <td>И ж<span class="stress">и</span>знь, и сл<span class="stress"
                                    >ё</span>зы, и люб<span class="stress">о</span>вь. </td>
                            <td class="meter"><span data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="ox">ox</span>|<span
                                    data-meter="head-One" class="oo">oo</span>|<span
                                    data-meter="head-One" class="ox">ox</span></td>
                            <td>b</td>
                            <td>
                                <span class="voweli">I </span>
                                <span class="vowelo">O </span>
                                <span class="vowelo">O </span>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="svg">
                    <xsl:variable name="valueCount" select="count($stressValences)" as="xs:integer"/>
                    <xsl:variable name="xScale" select="20" as="xs:integer"/>
                    <xsl:variable name="yScale" select="20" as="xs:integer"/>
                    <xsl:variable name="yTop" select="10.5 * $yScale" as="xs:double"/>
                    <svg xmlns="http://www.w3.org/2000/svg" height="{$yTop + 70}"
                        width="{($valueCount + 3) * $xScale}">
                        <g transform="translate(30,{11 * $yScale})">
                            <line x1="0" y1="0" x2="{($valueCount + 1) * $xScale}" y2="0"
                                stroke="black" stroke-width="1"/>
                            <line x1="0" y1="0" x2="0" y2="-{$yTop}" stroke="black" stroke-width="1"/>
                            <text x="{$xScale * ($valueCount + 1) div 2}" y="40"
                                text-anchor="middle">Syllable</text>
                            <xsl:for-each select="1 to 10">
                                <line x1="0" y1="-{current() * $yScale}"
                                    x2="{($valueCount + 1) * $xScale}" y2="-{current() * $yScale}"
                                    stroke="lightgray" stroke-width="1"/>
                                <text x="-5" y="-{current() * $yScale - 5}" text-anchor="end">
                                    <xsl:value-of select="current() * 10"/>
                                </text>
                            </xsl:for-each>
                            <xsl:for-each select="1 to $valueCount">
                                <xsl:variable name="currentX" select="current() * $xScale"
                                    as="xs:integer"/>
                                <xsl:variable name="currentY"
                                    select="$stressValences[current()] * $yScale * -10"
                                    as="xs:double"/>
                                <xsl:if test="position() ne last()">
                                    <xsl:variable name="nextX" select="(current() + 1) * $xScale"
                                        as="xs:integer"/>
                                    <xsl:variable name="nextY"
                                        select="$stressValences[current() + 1] * $yScale * -10"
                                        as="xs:double"/>
                                    <line x1="{$currentX}" y1="{$currentY}" x2="{$nextX}"
                                        y2="{$nextY}" stroke="black" stroke-width="1"/>
                                </xsl:if>
                                <line x1="{$currentX}" y1="0" x2="{$currentX}" y2="-{$yTop}"
                                    stroke="lightgray" stroke-width="1"/>
                                <circle cx="{$currentX}" cy="{$currentY}" r="3" fill="red">
                                    <title><xsl:value-of select="round($stressValences[current()] * 100)"/></title>
                                </circle>
                                <text x="{$currentX}" y="20" text-anchor="middle">
                                    <xsl:value-of select="current()"/>
                                </text>
                                <!--<text x="{$currentX}" y="20" text-anchor="middle">
                        <xsl:value-of select="round($stressValences[current()] * 100)"/>
                    </text>-->
                            </xsl:for-each>
                        </g>
                    </svg>

                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>

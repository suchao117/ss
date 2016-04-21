<%--
 - Copyright(C) 2010-2011 Fuji Xerox Co., Ltd.
 -
 - $Id: matrix.jsp 1515 2011-12-13 06:31:00Z msuzuki $
 --%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ include file="../mrv_include_required_params.jsp" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<link href="<s:url value="/css/matrix.css"/>" rel="stylesheet"></link>
<link href="<s:url value="/css/mrv_patient_link.css"/>" rel="stylesheet"></link>
<script type="text/javascript">
var ScriptRoot = "<s:url value="/js/" />";
</script>

<script src="<s:url value="/js/jquery.min.js" />"></script>
<script src="<s:url value="/js/Matrix/ContextMenu/ContextMenu.js" />"></script>
<script src="<s:url value="/js/Matrix/AccordionBox/AccordionBox.js" />"></script>
<script src="<s:url value="/js/Matrix/Dialog/Dialog.js" />"></script>
<script src="<s:url value="/js/Matrix/DivTable/DivTable.js" />"></script>
<script src="<s:url value="/js/Matrix/ComboBox/ComboBox.js" />"></script>
<script src="<s:url value="/js/Matrix/JobPalette/JobPalette.js" />"></script>
<script src="<s:url value="/js/Matrix/matrix.js" />"></script>
<script src="<s:url value="/js/mrvcookie.js" />"></script>
<script src="<s:url value="/js/mrvfont.js" />"></script>
<script src="<s:url value="/js/Matrix/Timeline/mv-timeline-api.js" />"></script>
    
<script type="text/javascript">
loginuuid = '<s:property value="%{loginuuid}"/>';
reqpi = '<s:property value="%{reqpi}"/>';
requuid = '<s:property value="%{requuid}"/>';
imgRoot = '<s:url value="/images/matrix/"/>';
downloadURL = '<s:url value="/archiveDownload.action"/>';
tagSettingPageInitPageUrl = '<s:url value="/tagOperate!tagSettingPageInit.action"/>';
linkPatientFlag = '<s:property value="%{#render.linkPatientFlag}"/>';
/**
 * 初期化データをロードする
 */
function loadInitData() {
    var settings = getXmlFromUrl('<s:url value="/matrix!settings.action"/>');
    if (settings == undefined) {
        return false;
    }
    var root = settings.childNodes[0].nodeTypeString === "processinginstruction"
                ? settings.childNodes[1] : settings.childNodes[0];
    var urlSet = {};
    for (var i = 0; i < root.childNodes.length; i++) {
        if (!(root.childNodes[i] instanceof Element)) {
            continue;
        }
        urlSet[root.childNodes[i].tagName] = root.childNodes[i].textContent;
    }

    propertyUrl = urlSet.Property;
    verifyUrl = urlSet.Verify;
    tagPropertyUrl = urlSet.TagProp;
    return getXmlFromUrl(urlSet.General, generalHandler)
        && getXmlFromUrl(urlSet.TextFormats, textFormatsHandler)
        && getXmlFromUrl(urlSet.Patient, patientHandler)
        && getXmlFromUrl(urlSet.Report, reportsHandler)
        && getXmlFromUrl(urlSet.DocCode, docCodeHandler)
        && getXmlFromUrl(urlSet.TreeCategory, treeCategoryHandler)
        && getXmlFromUrl(urlSet.DocumentData, documentDataHandler)
        && getXmlFromUrl(urlSet.CellNumbers, cellNumberHandler)
        && getXmlFromUrl(urlSet.PairData, pairDataHandler)
        && getXmlFromUrl(urlSet.Layer, layerHandler)
        && getXmlFromUrl(urlSet.Event, eventHandler);
}

/**
 * 画面初期化表示
 */
function initLayout() {
    document.body.scroll = "no";
    asyncInvoke(
        comboBoxLayout,
        comboBoxTagViewMode,
        sampleButtonLayout,
        departmentBoxLayout,
        docTypeBoxLayout,
        
        Timeline.Manager.setup,
        
      //  timeSelectorLayout,
     //   timeStrataLayout,
        jobPaletteLayout,
       // loadSampleDialog,
        loadTimelineCtxMenu,
        setWindowResizeEvent
        //viewPortLayout
       // layoutWindowHeight
      );
}

</script>


<style type="text/css">        
    .main{              
        float:left;
        width:100%;
    }
    
    .left,.right{
        float:left;
      /*  background:#F60;*/
    }
    
    .menu{
        width:200px;
        margin-left:-100%;
        z-index:200;
    }
    .mark-left{
        width:18px;
        padding-left:212px;
        margin-left:-100%;
        z-index:1;
    }    
    .mark-right{
        width:30px;
        margin-left:-30px;
    }
    
    .main_body{
        margin:0 30 0 230px;
      /*  background:#888; */
    }
    

      
#line{position: absolute; width:100%; height:4px;overflow:hidden;background:#959595;cursor:n-resize;}   
    
 #strata-splite{
    position: relative; 
    height:10px;
    overflow:hidden;
    background-image: URL("js/Matrix/Timeline/images/splite_line.png");
    background-position: center;
    background-repeat: no-repeat;
    cursor:n-resize;
    }  
</style> 
</head>
<body style="overflow: hidden">
    <div id="main" style="position: relative;">
    <s:hidden id="tagViewModeInfo" name="tagViewModeInfo" value="%{#render.tagViewModeInfoJson}" />
    <s:hidden id="tagDisplayFlag" name="tagViewModeInfo" value="%{#render.tagDisplayFlag}" />
        <!-- link menu create start -->
        <div id="linkMenuListDiv" class="linkMenuListDivStyle" style="display:none">
             <iframe id="linkMenuListDivIframe" name="linkMenuListDivIframe"
                src="" style="display:none" scrolling="no" frameborder="0"></iframe>
        </div>
        <!-- link menu create end -->
        <div id="head-area" style="position: absolute; top:10px;width:100%;">
            <div class="main">
                <div id="timeline-main" class="main_body" style="position: relative;min-height:60px;border: 1px solid black;border-top: none; border-top-left-radius: 6px;border-top-right-radius: 6px;"></div>
            </div>
            <div id="timeline-out-left" class="left mark-left"></div>
            <div class="left menu">
                <div id="comboboxArea"></div>
                <div id="sampleBtn" ></div>
                <div id="departmentArea" ></div>            
            </div>                  
            <div id="timeline-out-right" class="right mark-right"></div>
            <s:if test="%{#render.tagDisplayFlag == true and #render.tagViewModeInfo != null and #render.tagViewModeInfo.size > 0}">
            	<div id="comboboxTagViewMode" style="position:absolute;height:30; top:36;left:0" ></div>
            </s:if>
            <div style="clear:both"></div>              
        </div>
        <div id="mid-area" style="position: absolute;width:100%;z-index:400;background-color: #ededed;filter:alpha(opacity=100);">          
            <div class="main" style="z-index:400">
                <div id="strata-splite" class="main_body" style="position: relative;"></div>
                <div id="strata-main" class="main_body" style="position: relative;background:#888;"></div>
            </div>
            <div id="strata-out-left" class="left mark-left"></div>
            <div class="left menu">
                <div id="mid-left"></div>          
            </div>                  
            <div id="strata-out-right" class="right mark-right"></div>
            <div style="clear:both"></div> 
        </div>
        <div id="foot-area" style="position: absolute; bottom: 0px; padding-bottom: 10px; background:#ededed; max-height:163px;z-index:900"></div>
    </div>
    <div id="line" style="display:none; z-index:400"></div>
    <!-- mask div -->
    <div id="mainMaskDiv"></div>
    <!-- setup div -->
    <div id="patientLinkSetupTipDiv" class="patientLinkSetupTipDivStyle">
           <iframe id="patientlinkSetupIframe" name="patientlinkSetupIframe"
                src="" class="patientLinkSetupTipIframeStyle" style="display:none;" scrolling="no" frameborder="0"></iframe>
    </div>
    <fmt:setBundle basename="mrvmessage" />
    <input type="hidden" id="msg1001" value="<fmt:message key="MRV-1001"/>"/>
    <input type="hidden" id="msg1002" value="<fmt:message key="MRV-1002"/>"/>
    <input type="hidden" id="msg1003" value="<fmt:message key="MRV-1003"/>"/>
    <fmt:setBundle basename="mrvlabel" />
    <input type="hidden" id="mrvShibou" value="<fmt:message key="MRV-SHIBOU"/>"/>
    
    <s:hidden id="loginuuid" name="loginuuid" value="%{#loginuuid}"/>
	<s:hidden id="reqpi" name="reqpi" value="%{#reqpi}"/>
	<s:hidden id="requuid" name="requuid" value="%{#requuid}"/>
</body>
</html>

<%-- TEMPLATE HTML --%>
<script id="ComboBox" type="template">
<div unselectable='on' class="combobox">
    <div unselectable='on' class="combobox-header"
        onmouseover="this.style.backgroundImage='url(@basePath@images/ComboBoxButton_MouseOver.png)'"
        onmouseout="this.style.backgroundImage='url(@basePath@images/ComboBoxButton_Selectable.png)'"
        onmousedown="this.style.backgroundImage='url(@basePath@images/ComboBoxButton_Clicked.png)'"
        onmouseup="this.style.backgroundImage='url(@basePath@images/ComboBoxButton_Selectable.png)'">
    </div>
    <div unselectable='on' class="combobox-drop-area" style="position:absolute; left:12;top:36;z-index:1000"></div>
</div>
</script>

<script id="Dialog" type="template">
<div unselectable='on' class="dialog" style="z-index:1000">
    <div unselectable='on' class="dialog-title-bar">
        <span unselectable='on'></span>
        <div unselectable='on' class="dialog-title-close-btn"
            onmouseover="this.style.backgroundImage='url(@basePath@images/btn_close_mouseover.png)'"
            onmouseout="this.style.backgroundImage='url(@basePath@images/btn_close_selectable.png)'"
            onmouseup="this.style.backgroundImage='url(@basePath@images/btn_close_selectable.png)'"
            onmousedown="this.style.backgroundImage='url(@basePath@images/btn_close_cliced.png)'">
        </div>
    </div>
    <div unselectable='on' class="dialog-content"></div>
    <div unselectable='on' class="dialog-footer">
        <div unselectable='on' class="dialog-footer-btn"
            style="background-image: url(images/matrix/CommandButton_Selectable.png);"
            onmouseover="this.style.backgroundImage='url(images/matrix/CommandButton_MouseOver.png)';this.style.color='black'"
            onmouseout="this.style.backgroundImage='url(images/matrix/CommandButton_Selectable.png)';this.style.color='black'"
            onmouseup="this.style.backgroundImage='url(images/matrix/CommandButton_Selectable.png)';this.style.color='black'"
            onmousedown="this.style.backgroundImage='url(images/matrix/CommandButton_Clicked.png)';this.style.color='white'">
        </div>
    </div>
</div>
</script>

<script id="DivTable" type="template">
<div unselectable='on' class="divtable">
    <div unselectable='on' class="divtable-header"></div>
    <div unselectable='on' class="divtable-columns"></div>
</div>
</script>

<script id="Timeline" type="template">
<div unselectable='on' class="timeline">
    <div unselectable='on' class="timeline-header-l"></div>
    <div unselectable='on' class="timeline-header-body">
        <button class="timeline-btn-l"
            onmousedown="this.style.backgroundImage='url(@basePath@images/l_btn_down.png)'"
            onmouseup="this.style.backgroundImage='url(@basePath@images/l_btn_hover.png)'"
            onmouseover="this.style.backgroundImage='url(@basePath@images/l_btn_hover.png)'"
            onmouseout="this.style.backgroundImage='url(@basePath@images/l_btn_normal.png)'">
        </button>
        <div unselectable='on' class="timeline-header-content"></div>
        <button class="timeline-btn-r"
            onmousedown="this.style.backgroundImage='url(@basePath@images/r_btn_down.png)'"
            onmouseup="this.style.backgroundImage='url(@basePath@images/r_btn_hover.png)'"
            onmouseover="this.style.backgroundImage='url(@basePath@images/r_btn_hover.png)'"
            onmouseout="this.style.backgroundImage='url(@basePath@images/r_btn_normal.png)'">
        </button>
    </div>
    <div unselectable='on' class="timeline-header-r"></div>
    <br/>
    <div unselectable='on' class="timeline-waist"></div>
    <div unselectable='on' class="timeline-main"></div>
</div>
</script>

<script id="TodayFlag" type="template">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg"
        class='timeline-selector-today-flag'
        width="0" height="0">
    <text stroke="red" font-size="12">
        <tspan>@DateString@</tspan>
    </text>
    <polygon points="" fill="red" />
</svg>
</script>

<script id="ExpandCellContent" type="template">
<div unselectable='on' class="expand-cell-content">
    <div unselectable='on' class="expand-cell-content-header">
        <div unselectable='on' class="expand-cell-content-th" style="minWidth: @DOC_NAME_MIN_EXP_WIDTH@px;width: @DOC_NAME_DEF_EXP_WIDTH@px;">
            <span unselectable='on' class="expand-cell-content-title">@DOC_NAME@</span>
        </div>
        <div unselectable='on' class="expand-cell-content-th-separator"></div>
        <div unselectable='on' class="expand-cell-content-th" style="minWidth: @DOC_DATE_MIN_EXP_WIDTH@px;width: @DOC_DATE_DEF_EXP_WIDTH@px;">
            <span unselectable='on' class="expand-cell-content-title">@DOC_DATE@</span>
        </div>
        <div unselectable='on' class="expand-cell-content-th-separator"></div>
        <div unselectable='on' class="expand-cell-content-th" style="minWidth: @DOC_DEPT_MIN_EXP_WIDTH@px;width: @DOC_DEPT_DEF_EXP_WIDTH@px;">
            <span unselectable='on' class="expand-cell-content-title">@DOC_DEPT@</span>
        </div>
        <div unselectable='on' class="expand-cell-content-th-separator"></div>
        <div unselectable='on' class="expand-cell-content-th" style="minWidth: @DOC_STATUS_MIN_EXP_WIDTH@px;width: @DOC_STATUS_DEF_EXP_WIDTH@px;">
            <span unselectable='on' class="expand-cell-content-title">@DOC_STATUS@</span>
        </div>
        <div unselectable='on' class="expand-cell-content-fold-btn"></div>
    </div>
    <div unselectable='on' class="expand-cell-content-columns">
        <div unselectable='on' class="expand-cell-content-column" style="minWidth: @DOC_NAME_COL_MIN_EXP_WIDTH@px;width: @DOC_NAME_COL_DEF_EXP_WIDTH@px;"></div>
        <div unselectable='on' class="expand-cell-content-column" style="minWidth: @DOC_DATE_COL_MIN_EXP_WIDTH@px;width: @DOC_DATE_COL_DEF_EXP_WIDTH@px;"></div>
        <div unselectable='on' class="expand-cell-content-column" style="minWidth: @DOC_DEPT_COL_MIN_EXP_WIDTH@px;width: @DOC_DEPT_COL_DEF_EXP_WIDTH@px;"></div>
        <div unselectable='on' class="expand-cell-content-column" style="minWidth: @DOC_STATUS_COL_MIN_EXP_WIDTH@px;width: @DOC_STATUS_COL_DEF_EXP_WIDTH@px;"></div>
    </div>
</div>
</script>

<script id="DocProperties" type="template">
<div unselectable='on' class="docproperties">
    <div unselectable='on' class="docproperties-header"></div>
    <div unselectable='on' class="doc docproperties-waist">
        <div unselectable='on' class="docproperties-waist-th">@DOC_PROPERTY@</div>
        <div unselectable='on' class="docproperties-waist-th-separator"></div>
        <div unselectable='on' class="docproperties-waist-th">@DOC_VALUE@</div>
    </div>
    <div unselectable='on' class="doc docproperties-columns">
        <div unselectable='on' class="docproperties-column"></div>
        <div unselectable='on' class="docproperties-column"></div>
    </div>
	<div unselectable='on' class="tag tagproperties-waist" style="display:none">
        <div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_TIME_WIDTH@px;">@TAG_TIME@</div>
        <div unselectable='on' class="tagproperties-waist-th-separator"></div>
        <div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_USER_ID_WIDTH@px;">@TAG_USER_ID@</div>
		<div unselectable='on' class="tagproperties-waist-th-separator"></div>
		<div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_USER_NAME_WIDTH@px;">@TAG_USER_NAME@</div>
        <div unselectable='on' class="tagproperties-waist-th-separator"></div>
        <div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_DEPT_WIDTH@px;">@TAG_DEPT@</div>
        <div unselectable='on' class="tagproperties-waist-th-separator"></div>
        <div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_TYPE_WIDTH@px;">@TAG_TYPE@</div>
        <div unselectable='on' class="tagproperties-waist-th-separator"></div>
        <div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_COMMENT_WIDTH@px;">@TAG_COMMENT@</div>
        <div unselectable='on' class="tagproperties-waist-th-separator"></div>
        <div unselectable='on' class="tagproperties-waist-th" style="width: @TAG_OPTION_TYPE_WIDTH@px;">@TAG_OPTION_TYPE@</div>
    </div>
    <div unselectable='on' class="tag tagproperties-columns" style="display:none">
        <div unselectable='on' style="width:@TAG_TIME_COL_WIDTH@px;" class="tagproperties-column"></div>
        <div unselectable='on' style="width:@TAG_USER_ID_COL_WIDTH@px;"  class="tagproperties-column"></div>
        <div unselectable='on' style="width:@TAG_USER_NAME_COL_WIDTH@px;" class="tagproperties-column"></div>
        <div unselectable='on' style="width:@TAG_DEPT_COL_WIDTH@px;" class="tagproperties-column"></div>
        <div unselectable='on' style="width:@TAG_TYPE_COL_WIDTH@px;" class="tagproperties-column"></div>
        <div unselectable='on' style="width:@TAG_COMMENT_COL_WIDTH@px;" class="tagproperties-column"></div>
        <div unselectable='on' style="width:@TAG_OPTION_TYPE_COL_WIDTH@px;" class="tagproperties-column"></div>
    </div>

</div>
</script>

<script id="JobPalette" type="template">
<div unselectable='on' class="jobpalette" style="background-color: #ededed;">
    <div unselectable='on' class="jobpalette-head-left"></div>
    <div unselectable='on' class="jobpalette-head-body">
        <span unselectable='on' class="jobpalette-title"></span>
        <div unselectable='on' class="jobpalette-resize-btn"
            style="background-image: url(images/matrix/001/001_01.png)"
            onmouseover="this.style.backgroundImage='url(images/matrix/001/001_03.png)'"
            onmouseout="this.style.backgroundImage='url(images/matrix/001/001_01.png)'"
            onmousedown="this.style.backgroundImage='url(images/matrix/001/001_02.png)'"
            onmouseup="this.style.backgroundImage='url(images/matrix/001/001_03.png)'">
        </div>
    </div>
    <div unselectable='on' class="jobpalette-head-right"></div>
    <div unselectable='on' class="jobpalette-body" style="background-color: #ededed;">
        <div unselectable='on' class="jobpalette-doc-panel"></div>
        <table class="jobpalette-control-panel">
            <tr>
                <td unselectable='on' width="100">@PalleteCountsTitle@<span unselectable='on' class="jobpalette-count">0</span></td>
                <td><div unselectable='on' id="jobpalette-cls-button" class="jobpalette-button">@PalleteFocusClearButtonLabel@</div></td>
                <td><div unselectable='on' id="jobpalette-list-button" class="jobpalette-button">@PalleteFocusListButtonLabel@</div></td>
            </tr>
            <tr>
                <td></td>
                <td><div unselectable='on' id="jobpalette-download-button" class="jobpalette-button">@PalleteFocusDownloadButtonLabel@</div></td>
                <td><div unselectable='on' id="jobpalette-two-button" class="jobpalette-button">@PalleteFocusMultiButtonLabel@</div></td>
            </tr>
			<s:if test="%{#render.tagDisplayFlag == true}">
            <tr>
                <td></td>
                <td><div unselectable='on' id="jobpalette-tag-button" class="jobpalette-button">@PalleteFocusTagViewButtonLabel@</div></td>
                <td></td>
            </tr>
			</s:if>
        </table>
    </div>
</div>
</script>

<script id="DocItem" type="template">
<div unselectable='on' class="jobpalette-doc-item">
    <div unselectable='on' class="jobpalette-doc-icon"></div>
    <div unselectable='on' class="jobpalette-doc-title"></div>
    <div unselectable='on' class="jobpalette-doc-eventend"></div>
    <div unselectable='on' class="jobpalette-doc-dept"></div>
    <div unselectable='on' class="jobpalette-doc-tag-icon"></div>
</div>
</script>
<form name="frmTagViewMode" action="<s:url value="/tagViewMode.action"/>" target="_top" method="post">
    <s:hidden id="tagViewModeNo" name="tagViewModeNo" value="%{#tagViewModeNo}"/>
    <s:hidden id="screenName" name="screenName" value="%{#screenName}"/>
    <s:hidden id="loginuuid" name="loginuuid" value="%{#loginuuid}"/>
    <s:hidden id="reqpi" name="reqpi" value="%{#reqpi}"/>
    <s:hidden id="requuid" name="requuid" value="%{#requuid}"/>
</form>

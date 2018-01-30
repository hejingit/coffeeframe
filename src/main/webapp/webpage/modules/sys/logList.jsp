<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/webpage/include/taglib.jsp"%>
<html>
<head>
	<title>日志管理</title>
	<meta name="decorator" content="default"/>
	<script type="text/javascript">
		function page(n,s){
			$("#pageNo").val(n);
			$("#pageSize").val(s);
			$("#searchForm").submit();
	    	return false;
	    }
		$(document).ready(function() {
	        //外部js调用
	        laydate({
	            elem: '#beginDate', //目标元素。由于laydate.js封装了一个轻量级的选择器引擎，因此elem还允许你传入class、tag但必须按照这种方式 '#id .class'
	            event: 'focus' //响应事件。如果没有传入event，则按照默认的click
	        });
	        laydate({
	            elem: '#endDate', //目标元素。由于laydate.js封装了一个轻量级的选择器引擎，因此elem还允许你传入class、tag但必须按照这种方式 '#id .class'
	            event: 'focus' //响应事件。如果没有传入event，则按照默认的click
	        });

	       
	    })
	</script>
</head>
<body class="skin-coffee gray-bg">
<div class="wrapper wrapper-content">
<div class="ibox">
    
    <div class="ibox-content coffee-content">
			<h2 class="coffee-title">日志查询</h2>
	<sys:message content="${message}"/>
	
	<!-- 查询条件 -->
	<div class="row">
	<div class="col-sm-12">
	<form:form id="searchForm" action="${ctx}/sys/log/" method="post"  class="coffee-form-inline">
		<input id="pageNo" name="pageNo" type="hidden" value="${page.pageNo}"/>
		<input id="pageSize" name="pageSize" type="hidden" value="${page.pageSize}"/>
		<table:sortColumn id="orderBy" name="orderBy" value="${page.orderBy}" callback="sortOrRefresh();"/><!-- 支持排序 -->
			<div class="coffee-form">
				<span class="label-title">操作菜单：</span>
				<input id="title" name="title" type="text" maxlength="50" class="input-text" value="${log.title}"/>
			</div>
			<div class="coffee-form">
			<span class="label-title">用户名称：</span>
				<input id="createBy.name" name="createBy.name" type="text" maxlength="50" class="input-text" value="${log.createBy.name}"/>
				</div>
			<div class="coffee-form">
			<span class="label-title">URI：</span>
				<input id="requestUri" name="requestUri" type="text" maxlength="50"  class="input-text" value="${log.requestUri}"/>
				</div>
			<div class="coffee-form">
				<span class="label-title">日期：</span>
				<input id="beginDate" name="beginDate" type="text" maxlength="20" class="input-text input-text-date layer-date"
				value="<fmt:formatDate value="${log.beginDate}" pattern="yyyy-MM-dd"/>"/>
				<em class="coffee-date-line"></em>
				<input id="endDate" name="endDate" type="text" maxlength="20" class="input-text input-text-date layer-date"
				value="<fmt:formatDate value="${log.endDate}" pattern="yyyy-MM-dd"/>" />
			</div>
			<div class="coffee-form">
				<div class="coffee-checkbox">
						<input id="exception" name="exception" type="checkbox"${log.exception eq '1'?' checked':''} value="1"/>
						<label class="red" for="exception">只查询异常信息</label>
				</div>
			</div>
	</form:form>
		<div class="coffee-form-button">
			<button class="btn-primary" onclick="search()" ><i class="fa fa-search"></i> 查询</button>
			<button onclick="reset()"><i class="fa fa-refresh"></i> 重置</button>
		</div>
	</div>
	</div>
	
	
		<!-- 工具栏 -->
	<div class="row">
	<div class="col-sm-12">
		<div class="pull-left coffee-table-buttom">
			<shiro:hasPermission name="sys:log:del">
				<table:delRow url="${ctx}/sys/log/deleteAll" id="contentTable"></table:delRow><!-- 删除按钮 -->
				<button class="btn btn-sm btn-primary btn-inquire" onclick="confirmx('确认要清空日志吗？','${ctx}/sys/log/empty')"  title="清空"><i class="fa fa-eraser"></i> 清空</button>
			</shiro:hasPermission>
			</div>
		<div class="pull-right coffee-table-buttom">
			<button class="btn btn-white btn-sm " data-toggle="tooltip" data-placement="left" onclick="sortOrRefresh()" title="刷新"><i class="glyphicon glyphicon-repeat"></i> 刷新</button>
		</div>
	</div>
	</div>
	<div class="table-responsive coffee-table">
	<table id="contentTable" class="table table-hover">
		<thead>
			<tr>
				<th class="th-checkbox text-center"><input type="checkbox" class="i-checks"></th>
				<th>操作菜单</th>
				<th>操作用户</th>
				<th>所在公司</th>
				<th>所在部门</th>
				<th>URI</th>
				<th class="text-center">提交方式</th>
				<th class="text-center">操作者IP</th>
				<th class="text-center">操作时间</th>
			</tr>
		</thead>
		<tbody><%request.setAttribute("strEnter", "\n");request.setAttribute("strTab", "\t");%>
		<c:forEach items="${page.list}" var="log">
			<tr>
				<td class="text-center"><input type="checkbox" id="${log.id}" class="i-checks"></td>
				<td>${log.title}</td>
				<td>${log.createBy.name}</td>
				<td>${log.createBy.company.name}</td>
				<td>${log.createBy.office.name}</td>
				<td>${log.requestUri}</td>
				<td class="text-center">${log.method}</td>
				<td class="text-center">${log.remoteAddr}</td>
				<td class="text-center"><fmt:formatDate value="${log.createDate}" type="both"/></td>
			</tr>
			<c:if test="${not empty log.exception}"><tr>
				<td colspan="8" style="word-wrap:break-word;word-break:break-all;">
<%-- 					用户代理: ${log.userAgent}<br/> --%>
<%-- 					提交参数: ${fns:escapeHtml(log.params)} <br/> --%>
					异常信息: <br/>
					${fn:replace(fn:replace(fns:escapeHtml(log.exception), strEnter, '<br/>'), strTab, '&nbsp; &nbsp; ')}</td>
			</tr></c:if>
		</c:forEach>
		</tbody>
	</table>
	</div>
	
	<!-- 分页代码 -->
	<table:page page="${page}"></table:page>
	<br/>
	<br/>
	</div>
	</div>
</div>
</body>
</html>
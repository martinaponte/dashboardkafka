<#--
 Copyright 2016 HomeAdvisor, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<#import "lib/template.ftl" as template>
<#import "/spring.ftl" as spring />
<@template.header "Topic: ${topic.name}: Messages">
   <style type="text/css">
       h1 { margin-bottom: 16px; }
       #messageFormPanel { margin-top: 16px; }
       .toggle-msg { float: left;}
   </style>

  <script src="/js/message-inspector.js"></script>
</@template.header>
<#setting number_format="0">


<h1>Topic Messages: <a href="/topic/${topic.name}">${topic.name}</a></h1>

<#assign selectedPartition=messageForm.partition!0?number>
<#assign selectedFormat=messageForm.format!defaultFormat>

<div id="partitionSizes">
    <#assign curPartition=topic.getPartition(selectedPartition).get()>
    <span class="label label-default">First Offset:</span> <span id="firstOffset">${curPartition.firstOffset}</span>
    <span class="label label-default">Last Offset:</span> <span id="lastOffset">${curPartition.size}</span>
    <span class="label label-default">Size:</span> <span id="partitionSize">${curPartition.size - curPartition.firstOffset}</span>
</div>

<div id="messageFormPanel" class="panel panel-default">
<form method="GET" action="/topic/${topic.name}/messages" id="messageForm" class="form-inline panel-body">

    <div class="form-group">
        <label for="partition">Partition</label>
        <select id="partition" name="partition">
        <#list topic.partitions as p>
            <option value="${p.id}" data-first-offset="${p.firstOffset}" data-last-offset="${p.size}" <#if p.id == selectedPartition>selected="selected"</#if>>${p.id}</option>
        </#list>
        </select>
    </div>

    <@spring.bind path="messageForm.offset"/>
    <div class="form-group ${spring.status.error?string("has-error", "")}">
        <label class="control-label" for="offset">Offset</label>
        <@spring.formInput path="messageForm.offset" attributes='class="form-control"'/>
        <#if spring.status.error>
            <span class="text-danger"><i class="fa fa-times-circle"></i><@spring.showErrors "<br/>"/></span>
        </#if>
    </div>

    <@spring.bind path="messageForm.count"/>
    <div class="form-group ${spring.status.error?string("has-error", "")}">
        <label class=control-label" for="count">Num Messages</label>
        <@spring.formInput path="messageForm.count" attributes='class="form-control ${spring.status.error?string("has-error", "")}"'/>
        <#if spring.status.error>
           <span class="text-danger"><i class="fa fa-times-circle"></i><@spring.showErrors "<br/>"/></span>
        </#if>
    </div>

    <div class="form-group">
        <label for="format">Message Format</label>
        <select id="format" name="format">
        <#list messageFormats as f>
            <option value="${f}"<#if f == selectedFormat>selected="selected"</#if>>${f}</option>
        </#list>
        </select>
    </div>

        
	<#--<button onclick="displaydata()" class="btn btn-primary" type="submit"><i class="fa fa-search"></i> View Information</button> -->
	

	<!--<button class="btn btn-primary" onclick="unhide();" type="submit" onsubmit="unhide(); return false"><i class="fa fa-search"></i> View Information</button> -->
	<br />
	<br />

	<button class="btn btn-primary"   ><i class="fa fa-search"></i> Get data </button>

	
	<br />
	<br />

	<button class="btn btn-primary" type="button" onclick='(function() {
  				var xhide = document.getElementById("myDIV");
  				if (xhide.style.display === "none") 
				  {
    				xhide.style.display = "block";
  				}
				  return false;
 			 })();' type="submit" onsubmit="unhide(); return false"><i class="fa fa-search"></i> View Information</button>



			  <script>
		var xhide = document.getElementById("myDIV");
		if xvalues.length > 0
			{
				document.getElementById("myDIV").style.display = "block";
			}

	</script>
	
	<#--<button class="btn btn-primary" type="submit"><i class="fa fa-search"></i> View Messages</button> */ -->
		<br />
		<br />

		<div id ="myDIV" style="display:none">
	<input type="radio" name="displayopt" value="2" > Messages<br>
    <input type="radio" name="displayopt" value="3"> Graphic<br>


	</div>
	<br />
	
	  <#--<div id="log">the test is: </div> -->
    
</form>
</div>

<@spring.bind path="messageForm.*"/>
<div id="message-display" class="container" >
    <#if messages?? && messages?size gt 0>
    <#list messages as msg>
        <#assign offset=messageForm.offset + msg_index>
        <div data-offset="${offset}" class="message-detail">
            <span class="label label-default">Offset:</span> ${offset}
            <span class="label label-default">Key:</span> ${msg.key!''}
            <span class="label label-default">Checksum/Computed:</span> <span <#if !msg.valid>class="text-danger"</#if>>${msg.checksum}/${msg.computedChecksum}</span>
            <span class="label label-default">Compression:</span> ${msg.compressionCodec}
            <div>
            <a href="#" class="toggle-msg"><i class="fa fa-chevron-circle-right">&nbsp;</i></a>
            <pre class="message-body">${msg.message!''}</pre>
            </div>
        </div>
    </#list>
    <#elseif !(spring.status.error) && !(messageForm.empty)>
        No messages found in partition ${(messageForm.partition)!"PARTITION_NOT_SET"} at offset ${messageForm.offset}
    </#if>
</div>

<#-- globals go here -->
<script>
	var xvalues = [];
	var yvalues = [];

</script> 

<#--< chart display  -->
<div id="chart-display">

	<div id ="line_chart" class="container" style="width:1170px;height:600px;" >
		
		
		<script>
			//this part gets the number of messages in the topics as defined by num messages 
			var rowcount = $("pre").length
			$( "#testinglog" ).html("this is number of elements" + rowcount);
			
			
			//this part gets the values of said messages 
			var allMessagebody = $('.message-body').map(function () 
			{
				return $(this).text();
			}).get();

			//console.log(allMessagebody);
			
			$( "#testinglog" ).html("the array is " + allMessagebody);
			
			//trying to get unqiues 
			var unique = allMessagebody.filter
			
			var unique = allMessagebody.filter(function(itm, i, allMessagebody) 
			{
				return i == allMessagebody.indexOf(itm);
			});
			$( "#testinglog" ).html("the uniques is " + unique);
			//got uniques yays
			
			xvalues = unique;
			
			//now we count uniques 
			
			var uniqs = allMessagebody.reduce((acc, val) => 
			{
				acc[val] = acc[val] === undefined ? 1 : acc[val] += 1;
				return acc;
			}, {});
			console.log(uniqs);
			
			
			
			var countsfory= new Array();
			
			for(var x = 0; x<unique.length; x++)
				{
					countsfory.push(uniqs[unique[x]]);
				}
			console.log("the unique counts are " + countsfory);
			
			yvalues = countsfory;


			//hiding selector
			function unhide() 
			{
  				var xhide = document.getElementById("myDIV");
  				if (xhide.style.display === "none") 
				  {
    				xhide.style.display = "block";
  				}
 			 }
 
		</script>
	</div>
	
	<#--<div id="bar_chart"><!-- Plotly chart will be drawn inside this DIV</div> -->
		<script>
			<!-- JAVASCRIPT CODE GOES HERE -->
			
			
			
			var data = [{
			x: xvalues,
			y: yvalues,
			type: 'bar'
			}];

			//Plotly.newPlot('bar_chart', data, {}, {showSendToCloud:true});
		</script>
</div>


<script type="text/javascript">
	TESTER = document.getElementById('line_chart');
	Plotly.plot( TESTER, [{
	x: xvalues,
	y: yvalues }], {
	margin: { t: 0 } } );
</script>

<script>

	$("#chart-display").hide().css("visibility", "hidden");
	$("#message-display").hide().css("visibility", "hidden");
	
	$( "input:checked" ).val() = 2;
	$( "input").trigger( "click" );
	
	displaydata();
</script>


<script type="text/javascript">
$( "input" ).on( "click", function displaydata() 
{
	var test = $( "input:checked" ).val();
    $( "#log" ).html( test + " is checked!" );
	
	if(test == 2)
	{
		$( "#log" ).html("this is number" + test);
		
		//$document.getElementById('message-display').style.display = "block";
		//$document.getElementById('chart-display').style.display = "none";
		
	   //$("div.chart-display").hide();
	   //$("div.message-display").hide();
	   
	   $("#chart-display").hide().css("visibility", "hidden");
	   $("#message-display").show().css("visibility", "visible");
		
	}
	else
	{
		$( "#log" ).html("this is number" + test);
		
		$("#chart-display").show().css("visibility", "visible");
	    $("#message-display").hide().css("visibility", "hidden");
	}
});
 </script>




<@template.footer/>

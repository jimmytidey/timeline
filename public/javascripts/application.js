/*********** freebase functions ***
 *
 * The next three functions tie 
 * freebase suggest to the "Title" box,
 * and later, run an MQL query to grab 
 * a couple of dates.
 *
 **********************************/
$(document).ready(function() {
    //adds the click function to the auto add button 
    $('#auto_add_submit').click(function() {autoAdd(); });
    
    $("#event_title")
    .suggest({
      "type": ["/time/event"],
      "type_strict": "any",
      all_types:true
      }).bind("fb-select", function(e, data) {
          getMoreData(data);
        });
    });

// Called by the above
function getMoreData(data) {
  var query = [{'id': data.id, '/time/event/start_date': null, '/time/event/end_date': null}];
  var query_envelope = {'query' : query};
  var service_url = 'http://api.freebase.com/api/service/mqlread';

  $.getJSON(service_url + '?callback=?', {query:JSON.stringify(query_envelope)}, function(response) {
      
       if (response.code == "/api/status/ok" && response.result ) {
          var start_date = response.result[0]["/time/event/start_date"];
          var end_date = response.result[0]["/time/event/end_date"];
          setDates(start_date, end_date);
        }
  });
}

// Called by the above
function setDates(start_date, end_date) {
  start_date = start_date.substring(0,4);
  end_date = end_date.substring(0,4);
  $('#event_start_date').val(start_date);
  $('#event_end_date').val(end_date);
}

/*********** AJAX functions ***
 *
 * These functions deal with http 
 * submissions to the rails app.
 *
 **********************************/

/* Extend jQuery with functions for PUT and DELETE requests. */
function _ajax_request(url, data, callback, type, method) {
  if (jQuery.isFunction(data)) {
      callback = data;
      data = {};
  }
  return jQuery.ajax({
    type: method,
    url: url,
    data: data,
    success: callback,
    dataType: type
    });
}

jQuery.extend({
  put: function(url, data, callback, type) {
    return _ajax_request(url, data, callback, type, 'PUT');
  },
  delete_: function(url, data, callback, type) {
    return _ajax_request(url, data, callback, type, 'DELETE');
  }
});

function request_form_to_edit_event_from_server(the_event) {
  $.get("/events/" + the_event + "/edit");
}

function submit_event_to_server(begin, end, chart) {
  $.post("/events", { 'event':
    {
      'title' : 'click to rename',
      'start_date': begin.toString(),
      'end_date': end.toString(),
      'timeline_chart_id' : chart}
    });
}

function send_delete_request_to_server(the_event) {
  $.delete_("/events/" + the_event);
}

function deleteTimeline(id) {
  $.delete_("/timeline_charts/" + id);
}

/*********** SIMILE functions ***
 *
 * These functions deal with the 
 * timeline.
 *
 **********************************/

var tl;
var eventSource = new Timeline.DefaultEventSource(); 
var resizeTimerID = null;
var bandInfos = [];
var stTheme = Timeline.ClassicTheme.create();
//Mod the theme
stTheme.event.tape.height = 20;

function initialiseTimeline(editMode, zoom) {	
  bandInfos = [
    Timeline.createBandInfo({
  	  width:          "100%", 
  	  intervalUnit:   zoom, 
  	  intervalPixels: 100,
  	  eventSource: eventSource,
      theme: stTheme
    }) /*,
    Timeline.createBandInfo({
      width: "20%",
      intervalUnit: zoom + 1,
      intervalPixels: 100,
      eventSource: eventSource,
      theme: stTheme, 
      layout: 'overview' // original, overview, detailed
    }) */
  ];
  // bandInfos[1].syncWith = 0;
  // bandInfos[1].highlight = true;
  initialiseTheme();
  tl = Timeline.create(document.getElementById("my-timeline"), bandInfos);
  eventSource.loadJSON(events, '');

  if (editMode) {
   initialiseEditFunctions();
  }
}

// If this function is called, then the timeline is drawn in "edit" mode. If not
// then it is drawn in view mode.
function initialiseEditFunctions() {
  initialiseDragAndDrop();
  initialiseResize();
  initialiseLables();
  initialiseEdit();
  initialiseDestroy();
  initalialiseBubblePopper();
}

//Stop timeline scrolling for ever
function initialiseTheme() {
    stTheme.timeline_start = new Date(tc_start_date);
    stTheme.timeline_stop  = new Date(tc_end_date)
}

//Make the durations draggable
function initialiseDragAndDrop() {	
  $('#new_duration').draggable(
  {	
  	stop: function(event, ui) 
  	{
  		addDuration('new_duration', 'click to give me a name','');
  	},
  	//revert: true, // This causes problems
  	containment: '#my-timeline',		
  	grid: [1,18]		
  });
  
	$('.timeline-event-tape').draggable(
	{	
		stop: function(event, ui) {eventSave($(this).attr('id'));},
		drag: function(event, ui) {recalculateEventDate($(this).attr('id')); moveLabel($(this).attr('id'));},
		containment: 'parent', 
		grid: [1, 20],
	});
}

function initialiseLables() 
{
	$('.timeline-event-label').each(function() 	{
		$(this).append('<span class="info"></span><img src="/images/pencil.png" alt="close" class="pencil" />');
		$(this).append('<img src="/images/bin.png" alt="close" class="bin" />');
		recalculateEventDate($(this).attr('id'));	
	});	
}

function initialiseResize() {
	$(".timeline-event-tape").resizable(
		{							 
		stop: function(event, ui) {eventSave($(this).attr('id'));  recalculateEventDate($(this).attr('id')); },
		resize: function(event, ui) {},
		maxHeight:(20),
		minHeight:(20)
		});
}	

function initialiseEdit() { 
  // making the pencil open a modal 
  $('.pencil').click(function() {
      request_form_to_edit_event_from_server(getDataBaseId(this));
  });
}

function initialiseDestroy() { 
  // making the bin trash the event 
  $('.bin').click(function() {
      if (confirm("Are you sure?")){
        send_delete_request_to_server(getDataBaseId(this));
      }
  });
}

function initalialiseBubblePopper() {
  Timeline.OriginalEventPainter.prototype._showBubble = function(x, y, evt) {
    //stop the bubble from appearing!
  }
}

// when user drags the tape it needs to make the lable move with it 
function moveLabel(id) {
	left 	= $("#"+id).css('left');	
	id = "#label"+ id.substr(5);
	$(id).css('left', parseInt(left)+"px");
}

// Pass this function the child of a tape or label and it will return the
// id of the event in the database
function getDataBaseId(child) {
  return  $(child).parent().attr('class').match(/\d+/);
}

function recalculateEventDate(id) 
{
	
	// covert tape element ID to ID for the relevant lable  
	left 	= $("#"+id).css('left');
	width 	= $("#"+id).css('width');	
	
	//caluclate and remove offset from begining of timeline
	offset= parseInt(bandInfos[0].ether._band._viewOffset);	
	begin 	= bandInfos[0].ether.pixelOffsetToDate(parseInt(left)+offset);
	end 	= bandInfos[0].ether.pixelOffsetToDate(parseInt(width)+offset+parseInt(left));
		 
	id = "label"+ id.substr(5);
	
	$('#'+id+" .info").replaceWith(' <span class="info">('+begin.getFullYear()+' - '+ end.getFullYear()+')</span>');	
}

function eventSave(id) {
  alert(getDataBaseId(this));
  null
  null
};

function addDuration(element_id, title, content, chart) 
{	
	//get where the duration has been dropped in pixels 
	left 	= $("#"+element_id).css('left');
	width 	= $("#"+element_id).css('width');
	layer	= $("#"+element_id).css('top'); 	

	//convert to a date
	begin 	= bandInfos[0].ether.pixelOffsetToDate(parseInt(left)-20);
	layer 	= parseInt(layer)/18;
	end 	= bandInfos[0].ether.pixelOffsetToDate(parseInt(left)+parseInt(width));
	
	//get timelinechart number
	chart 	= $("#"+element_id).attr('data-id');
  	submit_event_to_server(begin, end, chart);
	$("#new_duration").css('left', '20px')
	$("#new_duration").css('top', '60px')	
};

function autoAdd() {
	
	var text = $('#auto_add_text').val(); 
	text = escape(text); 
	var json_url = 'http://jimmytidey.co.uk/timeline/open_calais/index.php?query_text='+text+'&callback=?';
	
	alert(text);
	
	$.ajax({
	  type: "GET",
	  url: json_url,
	  timeout: (10000),  
	  dataType: 'jsonp',
	  success: function(dates){parseAutoAdd(dates);} 
	});		
};

function parseAutoAdd(dates) {
	dateObject = eval(dates); 
}

// Bringing up a modal 
var modalWindow = {
	parent:"body",
	windowId:null,
	content:null,
	width:null,
	height:null,
	close:function()
	{
		$(".modal-window").remove();
		$(".modal-overlay").remove();
	},
	open:function()
	{
		var modal = "";
		modal += "<div class=\"modal-overlay\"></div>";
		modal += "<div id=\"" + this.windowId + "\" class=\"modal-window\" style=\"width:"
      + this.width + "px; height:"
      + this.height + "px; margin-top:-"
      + (this.height / 2) + "px; margin-left:-"
      + (this.width / 2) + "px;\">";
		modal += this.content;
		modal += "</div>";

		$(this.parent).append(modal);

		$(".modal-window").append("<a class=\"close-window\"></a>");
		$(".close-window").click(function(){modalWindow.close();});
		$(".modal-overlay").click(function(){modalWindow.close();});
	}
};

function openMyModal(id)
{
	modalWindow.windowId = "myModal";
	modalWindow.width = 480;
	modalWindow.height = 405;
	modalWindow.content = "<p>Edit " + id + " here</p>";
	modalWindow.open();
}; 



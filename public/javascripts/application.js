/*globals $ Timeline jQuery document*/
/*********** Doug Crockford's functions ***
 *
 * These functions add syntactic sugar that 
 * should probably be in the language anyway.
 *
 **********************************/

/* Neater prototypal inheritance http://javascript.crockford.com/prototypal.html */
function object(o) {
  function F() {}
  F.prototype = o;
  return new F();
}

if (typeof Object.beget !== 'function') {
  Object.beget = function (o) {
    var F = function () {};
    F.prototype = o;
    return new F();
  };
}

/* Augment a basic type */
Function.prototype.method = function (name, func) {
    this.prototype[name] = func;
    return this;
};

/*********** freebase functions ***
 *
 * The next three functions tie 
 * freebase suggest to the "Title" box,
 * and later, run an MQL query to grab 
 * a couple of dates.
 *
 **********************************/
// Called by the function below
function getMoreData(data) {
  var query = [{'id': data.id, '/time/event/start_date': null, '/time/event/end_date': null}],
      query_envelope = {'query' : query},
      service_url = 'http://api.freebase.com/api/service/mqlread',
      start_date,
      end_date;

  $.getJSON(service_url + '?callback=?', {query:JSON.stringify(query_envelope)}, function(response) {
      
       if (response.code === "/api/status/ok" && response.result ) {
          start_date = response.result[0]["/time/event/start_date"];
          end_date = response.result[0]["/time/event/end_date"];
          start_date = start_date.substring(0,4);
          end_date = end_date.substring(0,4);
          $('#new_event_form .event_start_date').val(start_date);
          $('#new_event_form .event_end_date').val(end_date);
        }
  });
}

$(document).ready(function() {
    //adds the click function to the auto add button 
    $('#auto_add_submit').click(function() {autoAdd(); });
    
    $('#new_event_form .event_title input').suggest({
      "type": ["/time/event"],
      "type_strict": "any",
      all_types:true
    }).bind("fb-select", function(e, data) {
        getMoreData(data);
    });
});


/*********** AJAX functions ***
 *
 * These functions deal with http 
 * submissions to the rails app.
 *
 **********************************/

function savePosition() {
  savedPosition = tl.getBand(0).getCenterVisibleDate();
}

function restorePosition() {
  tl.getBand(0).setCenterVisibleDate(savedPosition);
}

/* Extend jQuery with functions for PUT and DELETE requests. */
function jq_ajax_request(url, data, callback, type, method) {
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
    return jq_ajax_request(url, data, callback, type, 'PUT');
  },
  delete_it: function(url, data, callback, type) {
    return jq_ajax_request(url, data, callback, type, 'DELETE');
  }
});

function request_form_to_edit_event_from_server(theEvent) {
  savePosition();
  $.get("/events/" + theEvent + "/edit");
}

function submit_event_to_server(begin, end, band, chart) {

  savePosition();
  $.post("/events", { 'event':
    {
      'title' : 'click to rename',
      'start_date': begin.toString(),
      'end_date': end.toString(),
      'band': band.toString(),
      'timeline_chart_id' : chart}
    });
}

function update_dates_for_event_on_the_server(theEvent, startYear, endYear) {
  savePosition();
	$.put("/events/" + theEvent,
    { 'event':
      {
        'start_year': startYear.toString(), 
        'end_year': endYear.toString(),
      }
    }
  );
}

// I can't make this work - I'm not sure why..
function update_title_for_event_on_the_server(theEvent, title) {
  savePosition();
	$.put("/events/" + theEvent,
    { 'event':
      {
        'title': title
      }
    }
  );
}

function send_delete_request_to_server(theEvent) {
  savePosition();
  $.delete_it("/events/" + theEvent);
}

function deleteTimeline(id) {
  savePosition();
  $.delete_it("/timeline_charts/" + id);
}

/*********** SIMILE functions ***
 *
 * These functions deal with the 
 * timeline.
 *
 **********************************/

var tl;

if(savedPosition === undefined){
  var savedPosition;
}

var eventSource = new Timeline.DefaultEventSource();

function initialiseTimeline(editMode, zoom, startYear, endYear, centerYear) {	
  var stTheme = Timeline.ClassicTheme.create(),
    bandInfos = [
    Timeline.createBandInfo({
      width: "100%", 
      intervalUnit: zoom, 
      intervalPixels: 100,
      eventSource: eventSource,
      theme: stTheme
    })];

  initialiseTheme(stTheme);
  if(!editMode) {
    limitScollingOfTimeline(stTheme, startYear, endYear);
  }

  tl = Timeline.create(document.getElementById("my-timeline"), bandInfos);
  eventSource.loadJSON(events, '');

  //Center Timeline
  tl.getBand(0).setCenterVisibleDate(new Date(centerYear,1,1));

  if (editMode) {
    initialiseEditFunctions();
    if (savedPosition) {
      restorePosition();
    }
  }
}

function initialiseTheme(stTheme) {
  stTheme.event.tape.height = 20;
}

//Stop timeline scrolling for ever in View mode
function limitScollingOfTimeline(stTheme, startYear, endYear) {
  stTheme.timeline_start = new Date(startYear,1,1);
  stTheme.timeline_stop  = new Date(endYear,1,1);
}

// If this function is called, then the timeline is drawn in "edit" mode. If not
// then it is drawn in view mode.
function initialiseEditFunctions() {
	initialiseDragAndDrop();
	initialiseResize();
	initialiseLables();
	initialiseEdit();
	initialiseDestroy();
	initialiseBubblePopper();
 	initialiseEditTitle(); 
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
    containment: '#my-timeline' 	
  });
  
  $('.timeline-event-tape').draggable(
  {	
   	start: function(event, ui) {$(this).removeClass('band_1 band_2 band_3 band_4 band_5 band_6 band_7 band_8');$('.timeline-event-tape').removeClass('band_1 band_2 band_3 band_4 band_5 band_6 band_7 band_8'); }, 
    stop: function(event, ui) {eventSave($(this)); },
    drag: function(event, ui) {recalculateEventDate($(this).attr('id')); moveLabel($(this).attr('id')); },
    containment: 'parent'
	});
}

function initialiseLables() 
{
	$('.timeline-event-label').each(function() 	{
		$(this).append('<span class="info"></span><img src="/images/pencil.png" alt="close" class="pencil" />');
    	$(this).append('<img src="/images/bin.png" alt="close" class="bin" />');
    	recalculateEventDate( $(this).prev('.timeline-event-tape').attr('id') );
	});	
}

function initialiseResize() {
	$(".timeline-event-tape").resizable(
		{		
	  	handles: 'e',
		  stop: function(event, ui) { eventSave($(this)) },
		  resize: function(event, ui) {recalculateEventDate($(this).attr('id')) },
		  maxHeight:(20),
		  minHeight:(20)
		});
}	

function initialiseEdit() { 
  // making the pencil open a modal 
  $('.pencil').click(function() {
      request_form_to_edit_event_from_server(getDataBaseId($(this).parent()));
      initialiseDestroy();
  });
}

function initialiseEditTitle() { 
	$('.label_title').click(
		function(event, ui) {	
			editTitle($(this).attr('id'));
		} 							 
	);
}

function initialiseDestroy() { 
  // making the bin trash the event 
  $('.bin').click(function() {
      if (confirm("Are you sure?")){
        send_delete_request_to_server(getDataBaseId($(this).parent()));
      }
  });
}

function initialiseBubblePopper() {
  Timeline.OriginalEventPainter.prototype._showBubble = function(x, y, evt) {
    //stop the bubble from appearing!
  };
}

// when user drags the tape it needs to make the lable move with it 
function moveLabel(id) {
	left = $(id).css("left");	
	id = "#label"+ id.substr(5);
	
	$(id).css('left', parseInt(left)+"px");

}

// Pass this function the a tape or label and it will return the
// id of the event in the database
function getDataBaseId(child) {
  return  $(child).attr('class').match(/\d+/);
}


function editTitle(id)
{
	text = $('#'+id).html();
	$('#'+id).html("<input id='active_text' value='"+text+"'>");
	$('#active_text').focus();
	$('#active_text').blur(	
	function () 
	{
		replacement_text = $('#'+id+' input').val();
		$('#'+id+' input').replaceWith(replacement_text); 		
		event_id= id.substr(9);
		update_title_for_event_on_the_server(event_id, replacement_text); 
	});
}

function recalculateEventDate(id) 
{
	// covert tape element ID to ID for the relevant lable  
	left 	= $("#"+id).css('left');
	width 	= $("#"+id).css('width');
	
	left = parseInt(left);
	width = parseInt(width);
	
	//caluclate and remove offset from begining of timeline
	offset= parseInt(tl.getBand(0)._bandInfo.ether._band._viewOffset);	
	begin 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(left+offset);
	end 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(width+offset+left);
		 
	id = "label"+ id.substr(5);
	
	//this to prevent a problem with rounding that dates to be 1px out sometimes
	if (parseInt(begin.getMonth()) > 5)
	{
		rounded_begin = parseInt(begin.getFullYear());
		rounded_begin ++; 
	}
	else 
	{
		rounded_begin= begin.getFullYear();
	}
	
	if (parseInt(end.getMonth()) > 5)
	{
		rounded_end = parseInt(end.getFullYear());
		rounded_end++; 
	}
	else 
	{
		rounded_end= end.getFullYear();
	}	
	
	$('#'+id+" .info").replaceWith(' <span class="info">('+rounded_begin+' - '+ rounded_end+')</span>');	
}

function eventSave(id) {
  dbId = getDataBaseId(id);
  info = id.next().children('.info');
  start = info.html().match(/\d+/);
  end = info.html().match(/ \d+/);
  update_dates_for_event_on_the_server(dbId, start, end); 
};

function addDuration(element_id, title, content, chart) 
{	
	//get where the duration has been dropped in pixels 
	left 	= $("#"+element_id).css('left');
	width 	= $("#"+element_id).css('width');
	band	= $("#"+element_id).css('top');
	
	//convert to a date (minus 20 is for some CSS problems) 
	
	begin 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)-20);
	band 	= parseInt((parseInt(band)-80)/20);
	end 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)+parseInt(width));
			
	//get timelinechart number
	chart 	= $("#"+element_id).attr('data-id');
  	submit_event_to_server(begin, end, band, chart);
	$("#new_duration").css('left', '20px')
	$("#new_duration").css('top', '70px')	
};

function autoAdd() {
	var text = $('#auto_add_text').val(); 
  text = escape(text); 
	var json_url = 'http://jimmytidey.co.uk/timeline/open_calais/index.php?query_text='+text+'&callback=?';
	
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
	$.each(dateObject, function(key, value) { 
		$('#auto_add_result').append('<p>'+value.title+' Begins: '+value.start+' Ends: '+value.end+'</p> ');
		
	});
	
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

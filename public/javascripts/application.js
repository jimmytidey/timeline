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
  $.get("/events/" + theEvent + "/edit");
}

function submit_event_to_server(begin, end, chart) {
  savePosition();
  $.post("/events", { 'event':
    {
      'title' : 'click to rename',
      'start_date': begin.toString(),
      'end_date': end.toString(),
      'timeline_chart_id' : chart}
    });
}

function update_dates_for_event_on_the_server(theEvent, startYear, endYear) {
  savePosition();
  $.put("/events/" + theEvent,
    { 'event':
      {
        'start_date': startYear.toString(), 
        'end_date': endYear.toString()
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
var savedPosition;
var eventSource = new Timeline.DefaultEventSource();

function initialiseTimeline(editMode, zoom) {	
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
    limitScollingOfTimeline(stTheme);
    //tl.getBand(0).setCenterVisibleDate(savedPosition);
  }

  tl = Timeline.create(document.getElementById("my-timeline"), bandInfos);
  eventSource.loadJSON(events, '');

  if (editMode) {
    initialiseEditFunctions();
    if (restorePosition()) {
      restorePosition();
    }
  }
}

function initialiseTheme(stTheme) {
  stTheme.event.tape.height = 20;
}

//Stop timeline scrolling for ever in View mode
function limitScollingOfTimeline(stTheme) {
  stTheme.timeline_start = Date.parse(tc_start_year,0,0,0,0,0,0);
  stTheme.timeline_stop  = Date.parse(tc_end_year,0,0,0,0,0,0);
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
    stop: function(event, ui) { eventSave($(this)); },
    drag: function(event, ui) { recalculateEventDate($(this).attr('id')); moveLabel($(this).attr('id')); },
    containment: 'parent', 
    grid: [1, 20],
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

function initialiseDestroy() { 
  // making the bin trash the event 
  $('.bin').click(function() {
      if (confirm("Are you sure?")){
        send_delete_request_to_server(getDataBaseId($(this).parent()));
      }
  });
}

function initalialiseBubblePopper() {
  Timeline.OriginalEventPainter.prototype._showBubble = function(x, y, evt) {
    //stop the bubble from appearing!
  };
}

// when user drags the tape it needs to make the lable move with it 
function moveLabel(id) {
	left 	= $("#"+id).css('left');	
	id = "#label"+ id.substr(5);
	$(id).css('left', parseInt(left)+"px");
}

// Pass this function the a tape or label and it will return the
// id of the event in the database
function getDataBaseId(child) {
  return  $(child).attr('class').match(/\d+/);
}

function recalculateEventDate(id) 
{
  // TODO: This is sometimes 'off by one'
	// covert tape element ID to ID for the relevant lable  
	left 	= $("#"+id).css('left');
	width 	= $("#"+id).css('width');	
	
	//caluclate and remove offset from begining of timeline
	offset= parseInt(tl.getBand(0)._bandInfo.ether._band._viewOffset);	
	begin 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)+offset);
	end 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(width)+offset+parseInt(left));
		 
	id = "label"+ id.substr(5);
	
	$('#'+id+" .info").replaceWith(' <span class="info">('+begin.getFullYear()+' - '+ end.getFullYear()+')</span>');	
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
	layer	= $("#"+element_id).css('top'); 	

	//convert to a date
	begin 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)-20);
	layer 	= parseInt(layer)/18;
	end 	= tl.getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)+parseInt(width));
	
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

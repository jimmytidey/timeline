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
	
  query = data.id;

	$('#new_event_form').append("<img src='/images/loading.gif' class='loading_gif' />"); 	

	$.ajax({
		url: 'http://jimmytidey.co.uk/timeline/autocomplete/get_dates.php?id='+query+'&callback=?',
		dataType: 'json',
  		data: data, 
		success: function(result) {
			//this for dates separated by a "-"" 
			start_array = result.start.split("-");
			end_array = result.end.split("-");
			
			end = end_array[0];
			start = start_array[0];

			//this for dates separated by a ", "
			if (start_array.length < 2) { 
				start_array = result.start.split(", ");
				start = start_array[1];
			}
			
			if (end_array.length < 2) { 
				end_array = result.end.split(", ");
				end = end_array[1];
			}

			//if we only got one date, just assume it lasts a single year
			if (!isNumber(end)) { 
				end = start;
			}
			

			if (isNumber(start) && isNumber(end)) { 
				description= unescape(result.description); 
				
				$('.event_start_date').val(start);
				$('.event_end_date').val(end);
				$('#event_description').val(description);
				$('.loading_gif').remove();
			}
			else { 
  				$('#new_event_form .loading_gif').remove();
  				alert("couldn't find dates");
			}
			
 
		},
		
		error: function(result) {

  		}
 	});
}

//BIND CLICK STUFF
$(document).ready(function() {
    $('#new_event_form .event_title input').suggest({
	 "type": ["/people/person", "/time/event"],
 	 "type_strict": "any"
	}).bind("fb-select", function(e, data) {
        getMoreData(data);
    });

    $('#new_event_submit').click(function() { 
		addDuration(); 
	});	

});

/*********** SIMILE functions ***
 *
 * These functions deal with the 
 * timeline.
 *
 **********************************/

if(savedPosition === undefined){
  var savedPosition;
}

var Timeliner = {};
Timeliner.timelines = [];
Timeliner.timeline = function(){
  return this.timelines[0];
};

Timeliner.create = function(editMode, intervalPixels, zoom, startYear, endYear, centerYear, container, events_array) {
  var stTheme = Timeline.ClassicTheme.create();
  this.container = container;
  this.events = events_array;
  this.eventSource = new Timeline.DefaultEventSource(0);
  bandInfos = [
    Timeline.createBandInfo({
    width: "100%",
    intervalUnit: zoom, 
    intervalPixels: intervalPixels,
    eventSource: this.eventSource,
    theme: stTheme
  })];

  events = events_array;
  initialiseTheme(stTheme);

  //make the timeline
  timeline = Timeline.create(document.getElementById(container), bandInfos);
  this.timelines.push(timeline);
  this.eventSource.loadJSON(events_array, '');

  //Center Timeline
  timeline.getBand(0).setCenterVisibleDate(new Date(centerYear,1,1));

  //stop the thing it pops up when you roll over somethign 
  preventBubblePopper();	

  // what to do speifically for edit mode
  if (editMode) { 

    initialiseEditFunctions();

    timeline.getBand(0).addOnScrollListener(function(band){ 
      //this readds all the javascript when the timeline repaints everything 
      if ($(".pencil").length === 0) {
        initialiseEditFunctions();
      }
    });


    if (savedPosition) {
      restoreCenterDate();
    }
  }	else {
    initEmbedCode();
    showDescription(this);

    $(document).ready(function() {initialiseViewLables(container);}); 

    timeline.getBand(0).addOnScrollListener(function(band){ 
      initialiseEventMarkers();

    });
  }
  initialiseEventMarkers();
};

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
	preventBubblePopper();
 	initialiseEditTitle();
 	initLeaveTest();
}



//Make the durations draggable
function initialiseDragAndDrop() {
  var band_s = '';

   // band_s = 'band_1 band_2 band_3 band_4 ...'
  for(var i=1;i<=12;i++) {
    band_s += 'band_' + i + ' '
  }

  $('#new_duration').draggable(
  {
    stop: function(event, ui)
    {
      addDuration('new_duration', 'click to give me a name','');
    },
    grid: [1, 5]
  });
  
  $('.timeline-event-tape').draggable(
  {
    start: function(event, ui) {
      $(this).removeClass(band_s);
      $('.timeline-event-tape').removeClass(band_s);
    },
    stop: function(event, ui) {eventSave($(this));},
    drag: function(event, ui) {recalculateEventDate($(this).attr('id')); moveLabel($(this).attr('id')); },
    containment: 'parent',
	grid: [1, 30]
  });
};

function initialiseLables() {
  $('.timeline-event-label').each(function() 	{
    // this because there is no space for the pencil in the and the delete icon because the labels all have widths assigned 
    wrong_width = parseInt($(this).css('width'));
    rigth_width = wrong_width +100; 
    $(this).css('width', rigth_width+'px')

    $(this).append('<span class="info"></span><img src="/images/pencil.png" alt="close" class="pencil" />');
    $(this).append('<img src="/images/bin.png" alt="close" class="bin" />');

    recalculateEventDate($(this).prev('.timeline-event-tape').attr('id') );
  });	
}

function initialiseViewLables(container) {
  $('#' + container + ' .timeline-event-label').each(function() 	{
	
	//have to make space for the lables 
	wrong_width = parseInt($(this).css('width'));
   	rigth_width = wrong_width +100;
   	$(this).css('width', rigth_width+'px')
   	
	$(this).append('<span class="info"></span>');
    recalculateEventDate( $(this).prev('.timeline-event-tape').attr('id') );
	});
}

function initialiseResize() {
	/*
	$(".timeline-event-tape").resizable(
		{		
	  	handles: 'e',
		  stop: function(event, ui) { eventSave($(this)) },
		  resize: function(event, ui) {recalculateEventDate($(this).attr('id')) },
		  maxHeight:(20),
		  minHeight:(20)
		});
	*/	
}	

function initialiseEdit() { 
  // making the pencil open a modal 
  $('.pencil').click(function() {
      request_form_to_edit_event_from_server(getDataBaseId($(this).parent()));
      initialiseDestroy();
  });
}

function initialiseEditTitle() { 
	$('.timeline-event-label p').click(
		function(event, ui) {	
			editTitle($(this).parent().attr('id'));
		} 							 
	);
}

function initialiseDestroy() { 
  // making the bin trash the event 
  $('.bin').click(function() {
      if (confirm("Do you really want to delete this event?")){
        send_delete_request_to_server(getDataBaseId($(this).parent()));
      }
  });
}

function preventBubblePopper() {
  Timeline.OriginalEventPainter.prototype._showBubble = function(x, y, evt) {
    //stop the bubble from appearing!
  };
}

function findEventWithId(events, event_id) {
  result = jQuery.grep(events.events, function(event, i){
    return (event.eventID == event_id);
  });
  return result[0];
}


$(document).ready(function() {
  $('#close_tape_description').click( function() {
    $('#tape_description').css({
      'display': 'none'
    });	
  });
});

function showDescription(tl) {
  $("#" + tl.container + " div.timeline-event-label").each(function() {
    var description; 

    tape_class_list = $(this).attr('class');
    tape_class = tape_class_list.split(' ');
    event_id = tape_class[0].split('-')[1]; 
    event = findEventWithId(tl.events, event_id);
    description = event.description;

    if (description.length > 1) {
      $(this).append('<img src="/images/arrow.gif" class="show_me_more" /> ');
      $(this).click(function() {
        description = (description + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ "<br />" +'$2');
        $('#tape_description div').html(description);

        $('#tape_description').css({
          'display': 'block'
        });
      });
    }
  });
}

function initialiseEventMarkers() {

  $('.timeline-event-tape').each( function() {
    if (parseInt($(this).css('width'))<10)
      {
        $(this).css({
          "background-color":"transparent",
          "border":"none",
          "overflow": "visible", 
          "z-index" : "1000",
          "border":"1px solid black"
        }); 
        $(this).html("<img src='/images/event_marker.png' class='event_marker' />"); 
      }
  }); 
}


// when user drags the tape it needs to make the lable move with it 
function moveLabel(id) {

	var top;  
	
	top = $('#'+id).css("top");	
	
    $('#'+id).next('.timeline-event-label').css('cssText', "top:"+top+" !important");

	left = $('#'+id).css("left");	
	$('#'+id).next('.timeline-event-label').css('left', left);
}

// Pass this function the a tape or label and it will return the
// id of the event in the database
function getDataBaseId(child) {
 	return $(child).attr('class').match(/\d+/);
}


function editTitle(edit_id)
{
	text = $('#'+edit_id+' p').html();
	$('#'+edit_id+' p').replaceWith("<input class='active_text' value='"+text+"'>");
	$('.active_text').focus();
	$('.active_text').blur(	
	function () 
	{
		replacement_text = $('.active_text').val();
		$('.active_text').replaceWith("<p>"+replacement_text+'</p>'); 	
		eventSave($('#'+edit_id).prev()); 
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
	offset = parseInt(Timeliner.timeline().getBand(0)._bandInfo.ether._band._viewOffset);	
	begin 	= Timeliner.timeline().getBand(0)._bandInfo.ether.pixelOffsetToDate(left+offset);
	end 	= Timeliner.timeline().getBand(0)._bandInfo.ether.pixelOffsetToDate(width+offset+left);

	if (id != null) {var id = "label"+ id.substr(5);}
	
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
	
	if (rounded_begin != rounded_end) {
		$('#'+id+" .info").replaceWith(' <span class="info">(<span class="begin_date" data-epoch="' + begin.getTime() + '">' + rounded_begin + '</span> <span class="end_date" data-epoch="' + end.getTime() + '">'+ rounded_end+'</span>)</span>');	
	} 
	
	else {
		$('#'+id+" .info").replaceWith(' <span class="info">(<span class="begin_date">'+rounded_begin+'</span>)</span>');	
	}
}



function addDroppableDuration(element_id, title, content, chart) 
{	
	//get where the duration has been dropped in pixels 
	var left 	= $("#"+element_id).css('left');
	var width 	= $("#"+element_id).css('width');
	var band	= $("#"+element_id).css('top');
	
	
	//convert to a date (css ofsets in the location of the original duration affect this) 
	band 	= parseInt((parseInt(band)-136)/30);
	begin 	= Timeliner.timeline().getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)-40);
	end 	= Timeliner.timeline().getBand(0)._bandInfo.ether.pixelOffsetToDate(parseInt(left)+parseInt(width));
	
	//get timelinechart number
	chart 	= $("#"+element_id).attr('data-id');
  	submit_event_to_server(begin, end, band, chart);
	$("#new_duration").css('left', '40px')
	$("#new_duration").css('top', '136px')	
};

function addDuration() { 

	// validate 
	 
	var begin = $("#new_event_start_year").val() +"-01-03 04:10:53.000000";
	var end = $("#new_event_end_year").val() +"-01-03 04:10:53.000000";
	var name = $("#new_event_title").val();
	var chart = $('.timeline').attr('data-id');
	if (!(/\S/.test(name))) { // no title has been given
	    name='click to give me a name';
	}
	if (end < begin) { 
		end = begin; 
	} 


	//this to prevent overlapping events happening
	var search_events = events['events']; 
	search_events.sort(function(a, b){
		var first = a.classname.split("_");
		var second = b.classname.split("_");
 		return first[1]-second[1]; 
	});

	Timeliner.band_store = 1; 

	$.each(events['events'], function(index, value) { // calculate which bad is free
		//search for dates that start in the same period as ours
		var test_start_year = parseInt(value.start.getFullYear());
		console.log("test_start_year "+test_start_year);
		var test_end_year = parseInt(value.end.getFullYear());
		console.log("test_end_year "+test_end_year);
		var start_year = parseInt($("#new_event_start_year").val());
		console.log("start_year "+start_year); 
		var end_year = parseInt($("#new_event_end_year").val()); 
		console.log("end_year "+end_year); 
		if (test_start_year >= start_year && test_start_year <= end_year) { 
			Timeliner.band_store = index+2;
			console.log(index);
			return true; 
			console.log('start infringement found');
		}

		//is there a date that ends in the same period as ours? 

		else if (test_end_year >= start_year && test_end_year <= end_year) { 
			Timeliner.band_store = index+2;
			console.log(index);
			return true; 
			console.log('end infringement found');
		}

		else { 
			console.log('clear band');
			console.log(index);
			Timeliner.band_store = index; 
			return false;
		}
	});





	submit_event_to_server(name, begin, end, Timeliner.band_store, chart);

}

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

function initEmbedCode() {
	$(document).ready(function() {
		$('#embed_code_generate').click(function() {
			var url = location.href;
			var iframe_width = parseInt($('#embed_code_width').val()); 
			var html = '<iframe src="'+url+'iframe" scrolling="no" frameborder="0" width="'+iframe_width+'" height="550"></iframe>';
		
			$('#embed_code_output').html("<textarea style='width:450px; margin-top:10px; '>"+html+"</textarea>"); 
		}); 
	});
}

function initLeaveTest() {
	
	window.onbeforeunload = bunload;
	
	function bunload(){
		var title = $('#timeline_chart_title').val(); 
		var description = $('#timeline_chart_description').val();
		
		if (title == 'Untitled') {
			dontleave="Why not give your timeline a proper title before you leave? Press cancel to stay on this page";
			return dontleave;
		}	
		
		if (description == '') {
			dontleave="Giving your timeline a description will help other users find it. Press cancel to stay on this page";
			return dontleave;
		}			
	}
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

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}


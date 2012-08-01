

bandCalculator ={};

//BIND CLICK STUFF
$(document).ready(function() {
    $('#new_event_submit').click(function() { 
		console.log('adding new duration');
		addDuration(); 
		$('#new_event_form #new_event_title').suggest('close')
	});	
});


// If this function is called, then the timeline is drawn in "edit" mode. If not
// then it is drawn in view mode.
function initialiseEditFunctions() {
	initialiseDragAndDrop();
	initialiseResize();
	initialiseLables();
	initialiseEdit();
  	initialiseEditTitle();
	preventBubblePopper();
	initLeaveTest();
}



//Make the durations draggable (only up and down )
function initialiseDragAndDrop() {

  // band_s = 'band_1 band_2 band_3 band_4 ...'
  var band_s = '';
  for(var i=1;i<=12;i++) {
    band_s += 'band_' + i + ' ';
  }
  
  $('.timeline-event-tape').draggable(
  {
    start: function(event, ui) {
      $(this).removeClass(band_s);
      $('.timeline-event-tape').removeClass(band_s);
    },
    stop: function(event, ui) {eventSave($(this));},
    drag: function(event, ui) {recalculateEventDate($(this).attr('id')); moveLabel($(this).attr('id')); },
    containment: 'parent',
	grid: [1, 30],
	axis: 'y'
  });
};

//add information beyond the event name to each event 
function initialiseLables() {
	$('.timeline-event-label').each(function() {
		// this because there is no space for the pencil in the and the delete icon because the labels all have widths assigned 
		wrong_width = parseInt($(this).css('width'), 10);
		right_width = wrong_width +100; 
		$(this).css('width', right_width+'px');
		$(this).append('<span class="info"></span><img src="/images/pencil.png" alt="pencil" class="pencil" />');
		recalculateEventDate($(this).prev('.timeline-event-tape').attr('id') );
	});	
}

//placing the dates after each of the event titles
function initialiseViewLables(container) {
  $('#' + container + ' .timeline-event-label').each(function() {
		wrong_width = parseInt($(this).css('width'), 10);
      right_width = wrong_width +100;
      $(this).css('width', right_width+'px');
		$(this).append('<span class="info"></span>');
	    recalculateEventDate( $(this).prev('.timeline-event-tape').attr('id'));
	});
}

//change the duration of an event 
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

// making the pencil open a modal to edit the event
function initialiseEdit() { 
  $('.pencil').click(function() {
      request_form_to_edit_event_from_server(getDataBaseId($(this).parent()));
  });
}

//just click on the text of the title to edit it 
function initialiseEditTitle() { 
	$('.timeline-event-label p').click(
		function(event, ui) {	
			editTitle($(this).parent().attr('id'));
		} 							 
	);
}

//Simile has an annoying pop up bubble that I want to disable
function preventBubblePopper() {
  Timeline.OriginalEventPainter.prototype._showBubble = function(x, y, evt) {
    //stop the bubble from appearing!
  };
}

//hides all the extended descriptions on init 
$(document).ready(function() {
  $('#close_tape_description').click( function() {
    $('#tape_description').css({
      'display': 'none'
    });	
  });
});

//displays extended descriptions 
function showDescription(tl) {
  $("#" + tl.container + " div.timeline-event-label").each(function() {
    var description; 

    tape_class_list = $(this).attr('class');
    tape_class = tape_class_list.split(' ');
    event_id = tape_class[0].split('-')[1]; 
    event = findEventWithId(tl.events, event_id);
    description = event.description;

    if (description.length > 1) {
      $("p", this).append('<img src="/images/arrow.gif" class="show_me_more" /> ');
      $(this).click(function() {
        description = (description + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ "<br />" +'$2');
		$('body').append("<p id='modal_description'>"+description+"</p>"); 
		$('#modal_description').dialog({
			width:500,
			height:600, 
			close: function(){ 
				$('#modal_description').remove();
			}
		});
      });
    }
  });
}

//for events of low width a tape doesn't look right - we need a market instead 
function initialiseEventMarkers() {
  $('.timeline-event-tape').each( function() {
    if (parseInt($(this).css('width'))<10)
      {
        $(this).css({
          "background-color":"transparent",
          "border":"none",
          "overflow": "visible", 
          "z-index" : "1000",
          "border":"none"
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
	var left 	= $("#"+id).css('left');
	var width 	= $("#"+id).css('width');
	
	var left = parseInt(left);
	var width = parseInt(width);
	
	//caluclate and remove offset from begining of timeline
	
	var offset = parseInt(Timeliner.timeline().getBand(0)._bandInfo.ether._band._viewOffset);	
	var begin 	= Timeliner.timeline().getBand(0)._bandInfo.ether.pixelOffsetToDate(left+offset);
	var end 	= Timeliner.timeline().getBand(0)._bandInfo.ether.pixelOffsetToDate(width+offset+left);

	if (id != null) {var id = "label"+ id.substr(5);}
	
	//this to prevent a problem with rounding that dates to be 1px out sometimes
	if (parseInt(begin.getMonth()) > 5)
	{
		var rounded_begin = parseInt(begin.getFullYear());
		rounded_begin ++; 
	}
	else 
	{
		rounded_begin= begin.getFullYear();
	}
	
	if (parseInt(end.getMonth()) > 5)
	{
		var rounded_end = parseInt(end.getFullYear());
		rounded_end++; 
	}
	else 
	{
		rounded_end= end.getFullYear();
	}	
	
	if (rounded_begin != rounded_end) {
		$('#'+id+" .info").replaceWith('<span class="info" >(<span class="begin_date" data-epoch="' + begin.getTime() + '">' + rounded_begin + '</span> - <span class="end_date" data-epoch="' + end.getTime() + '">'+ rounded_end+'</span>)</span>');	
	} 
	
	else {
		$('#'+id+" .info").replaceWith(' <span class="info">(<span class="begin_date" data-epoch="' + begin.getTime() + '" >'+rounded_begin+'</span>)</span>');	
	}
}

//when the form adds a new duration to the timeline, including intelligently assigning a band
function addDuration() { 
	// validate  
	// add zeron padding to make dates before 1000 ad work 
	var begin_dirty = $("#new_event_start_year").val();
	var end_dirty 	= $("#new_event_end_year").val(); 
	var begin_clean = zeroPad(begin_dirty,4);
	var end_clean = zeroPad(end_dirty,4);
	bandCalculator.name 		= $("#new_event_title").val();
	bandCalculator.chart 		= $('.timeline').attr('data-id');
	bandCalculator.description 	= $('#event_description').val();	
	
	//if the event is very short, we need to use the length of the label, not the timespan
	if ((end_clean - begin_clean) < 5) { 
		end_clean = parseInt(begin_clean) + 20 + bandCalculator.name.length;
	}
	
	
	bandCalculator.begindate 	= new Date("01/01/"+begin_clean); 
	bandCalculator.enddate 		= new Date("01/01/"+end_clean);
	
	bandCalculator.begin 		=  bandCalculator.begindate.getTime();
	bandCalculator.end 			=  bandCalculator.enddate.getTime();
	


	if (!(/\S/.test(bandCalculator.name))) { // no title has been given
	    bandCalculator.name='click to give me a name';
	}
	
	if (bandCalculator.end < bandCalculator.begin) { 
		bandCalculator.end = bandCalculator.begin; 
	} 

	//Put the exitsing events into an ordered array
	bandCalculator.search_events = events['events']; 
	bandCalculator.search_events.sort(function(a, b){
		var first = a.classname.split("_");
		var second = b.classname.split("_");
 		return first[1]-second[1]; 
	});

	bandCalculator.saveBand = function(answer_array) { 
		bandCalculator.saved = false; 
		$.each(answer_array, function(index, value) {
			console.log("name:" + bandCalculator.name);
			last_index = answer_array.length - 1; 
			if (value == 'sucess') {  
				console.log('adding to sucessful band'); 
				submit_event_to_server(bandCalculator.name, bandCalculator.description, bandCalculator.begin, bandCalculator.end, index, bandCalculator.chart);
				bandCalculator.saved = true;
				return false; 
			} 
			if (!bandCalculator.saved && index == last_index) { 
				console.log('making a new band' + bandCalculator.begin + " -  " + bandCalculator.end); 
				submit_event_to_server(bandCalculator.name, bandCalculator.description, bandCalculator.begin, bandCalculator.end, index+1, bandCalculator.chart);
				bandCalculator.saved = true;				
			}	 
		});
	}

	//this is the first event
	if (bandCalculator.search_events.length == 0) { 
		band_answer= 1; 
		submit_event_to_server(bandCalculator.name, bandCalculator.description, bandCalculator.begin, bandCalculator.end, band_answer, bandCalculator.chart);
	}

	else  {
		answer_array = [];

		$.each(bandCalculator.search_events, function(index, value) { // calculate which band is free
			//search for dates that start in the same period as ours

			console.log("-------");
			var test_start_year = parseInt(value.start.getFullYear());
			console.log("test_start_year "+test_start_year);
			var test_end_year = parseInt(value.end.getFullYear());
			console.log("test_end_year "+test_end_year);
			var start_year = parseInt($("#new_event_start_year").val());
			console.log("start_year "+start_year); 
			var end_year = parseInt($("#new_event_end_year").val()); 
			console.log("end_year "+end_year); 
			
			if ((test_end_year - test_start_year) <20) { 
				//test_end_year = test_start_year +20 + value.title.length; 
			}
			

			var band_test = value.classname.split("_");
			band_test = parseInt(band_test[1]);

			last_index = bandCalculator.search_events.length - 1; 
			
			console.log("band_val" + band_test);
			
			if (test_start_year >= start_year && test_start_year <= end_year) { 	
				console.log('start infringement found');
				answer_array[band_test] = "fail"; 
			}

			//is there a date that ends in the same period as ours? 
			else if (test_end_year >= start_year && test_end_year <= end_year) { 
				console.log('end infringement found');
				answer_array[band_test] = "fail"
			}

			//is there a date that ends in the same period as ours? 
			else if (test_start_year <= start_year && test_end_year >= end_year) { 
				console.log('total infringement found');
				answer_array[band_test] = "fail"
			}			

			else {
				console.log('no infringement found '); 
				if(answer_array[band_test] != 'fail' ) { 
					answer_array[band_test] = "sucess";
				} 
			}

			//trigger band saving once we've looped through everything 
			if (index == last_index) {
				bandCalculator.saveBand(answer_array); 
			}							
		});
	}	
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

//grep for an event with a particular ID 
function findEventWithId(events, event_id) {
  result = jQuery.grep(events.events, function(event, i){
    return (event.eventID == event_id);
  });
  return result[0];
}

// Pass this function the a tape or label and it will return the
// id of the event in the database
function getDataBaseId(child) {
 	return $(child).attr('class').match(/\d+/);
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function zeroPad(num,count)
{
var numZeropad = num + '';
while(numZeropad.length < count) {
numZeropad = "0" + numZeropad;
}
return numZeropad;
}


//bring up a alert if the user hasn't give a title 

function initLeaveTest() {

	window.onbeforeunload = bunload;

	function bunload(){
		var title = $('#timeline_chart_title').val(); 
		var description = $('#timeline_chart_description').val();

		if(events.events.length <3) { 
			dontleave="I see you haven't got very far. I'd love to hear if there is a problem... jimmytidey@gmail.com";
			return dontleave;			
		}

		if (title == 'Untitled') {
			dontleave="Why not give your timeline a title?";
			return dontleave;
		}	

		if (description == '') {
			dontleave="Giving your timeline a description will help other users find it. Press cancel to stay on this page";
			return dontleave;
		}			
	}
}	



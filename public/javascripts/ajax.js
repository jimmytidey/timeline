

/*********** AJAX functions ***
 *
 * These functions deal with http 
 * submissions to the rails app.
 *
 **********************************/


function eventSave(id) {
  var ttop, dbId,color;
  dbId = getDataBaseId(id);
  
  // get the band
  ttop  = parseInt($(id).css('top')); 
  ttop  = Math.round((ttop)/30)+1; 
  if (ttop == 0) {ttop=1;}
  var title = $(id).next('.timeline-event-label').children('p').html();
  var info = id.next().children('.info');
  	
	if ($(id).hasClass('magenta')) { 
		color = 'magenta';
	}
	else if  ($(id).hasClass('cream')) { 
		color = 'cream';
	}
	else if  ($(id).hasClass('yellow')) { 
		color="yellow"; 
	}	
	else { 
		color = 'blue';
	}
	
	var start = info.children('.begin_date').attr('data-epoch');
	var end = info.children('.end_date').attr('data-epoch');
  	if (end == undefined) { 
		end = start; 
	}

  update_dates_for_event_on_the_server(dbId, start, end, ttop, title, color); 
};


function saveCenterDate() {
	// everytime an event is edited a new timeline is created. this is very wasteful of memeory and should probably be addressed.
	var current_timeline_index = Timeliner.timelines.length - 1;
	window.savedPosition = Timeliner.timelines[current_timeline_index].getBand(0).getCenterVisibleDate();
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
  saveCenterDate();
  $.get("/events/" + theEvent + "/edit");
}

function submit_event_to_server(name, description, begin, end, band, chart) {
  saveCenterDate();
	console.log("startdate" + begin); 
  $.post("/events", { 'event':
    {
      'title' : name,
	  'description' : description,
      'start_date': begin.toString(),
      'end_date': end.toString(),
      'band': band.toString(),
      'timeline_chart_id' : chart}
    });
}

function update_dates_for_event_on_the_server(theEvent, startDate, endDate, band, title, description, color) {
  saveCenterDate();

	if (description.length > 0) { 
		
		$.put("/events/" + theEvent,
	    { 'event':
	      {
	        'start_date': startDate.toString(),
	        'end_date': endDate.toString(),
			'band': band.toString(),
			'title': title.toString(),
			'color': color,
			'description': description
	      }
	    });
	}
	else { 
		$.put("/events/" + theEvent,
	    { 'event':
	      {
	        'start_date': startDate.toString(),
	        'end_date': endDate.toString(),
			'band': band.toString(),
			'color': color,
			'title': title.toString()
	      }
	    });	
	}
}

function send_delete_request_to_server(theEvent) {
  saveCenterDate();
  $.delete_it("/events/" + theEvent);
}

function deleteTimeline(id) {
  $.delete_it("/timeline_charts/" + id);
}

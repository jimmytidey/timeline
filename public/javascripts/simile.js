/*********** SIMILE functions ***
 *
 * These functions deal with the 
 * timeline.
 *
 **********************************/

var Timeliner = {};
Timeliner.timelines = [];
Timeliner.timeline = function(){
  return this.timelines[0];
};

//simile code for writing a new timeline
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

	//Center Timeline, either to the center year or to the center date or to the last saved event 
	if(bandCalculator.saved) { 
		var last_elem = events['events'].length - 1; 
		last_event = events['events'][last_elem];
		console.log(last_event); 
	}
  	else { 
 		timeline.getBand(0).setCenterVisibleDate(new Date(centerYear,1,1));
	}

  //stop the thing it pops up when you roll over somethign 
  preventBubblePopper();	

  // what to do speifically for edit mode
  if (editMode) { 
	    initialiseEditFunctions();
		
		//when the timeline is repainted, redraw all the edit functions 
	    timeline.getBand(0).addOnScrollListener(function(band){ 
	      if ($(".pencil").length === 0) {initialiseEditFunctions();}
	    });
	} 
	else {
    	initEmbedCode();
    	showDescription(this);
    	$(document).ready(function() {initialiseViewLables(container);}); 
	    timeline.getBand(0).addOnScrollListener(function(band){ 
	      initialiseEventMarkers();

	    });
  	}
  	initialiseEventMarkers();
};

//changes the height of each band
function initialiseTheme(stTheme) {
	stTheme.event.tape.height = 20;
}

//Stop timeline scrolling for ever in View mode
function limitScollingOfTimeline(stTheme, startYear, endYear) {
  stTheme.timeline_start = new Date(startYear,1,1);
  stTheme.timeline_stop  = new Date(endYear,1,1);  
}

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
			
			start_array = [];
			end_array = [];
			
			//this for dates separated by a "-"" 
			if (result.start != null ) { 
				start_array = result.start.split("-");
				start = start_array[0];
				
				//this for dates separated by a ", "
				if (start_array.length < 2) { 
					start_array = result.start.split(", ");
					start = start_array[1];
				}				
				
			}
			if (result.end != null) { 	
				end_array = result.end.split("-");
				end = end_array[0];

				if (end_array.length < 2) { 
					end_array = result.end.split(", ");
					end = end_array[1];
				}				
			}

			//if we only got one date, just assume it lasts a single year
			if (!isNumber(end)) { 
				end = start;
			}
			

			if (isNumber(start) && isNumber(end)) { 
				description= unescape(result.description); 
				
				$('#new_event_start_year').val(start);
				$('#new_event_end_year').val(end);
				$('#event_description').val(description);
				console.log($('#event_description').val());
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
    $('#new_event_form #new_event_title').suggest({
	 "type": ["/people/person", "/time/event"],
 	 "type_strict": "any"
	}).bind("fb-select", function(e, data) {
        getMoreData(data);
    });
});
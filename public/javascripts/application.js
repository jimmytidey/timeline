/*********** freebase functions ***
 *
 * The next three functions tie 
 * freebase suggest to the "Title" box,
 * and later, run an MQL query to grab 
 * a couple of dates.
 *
 **********************************/
$(document).ready(function() {
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
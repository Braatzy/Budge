if ($('#place_list').length) {
  $('#place_list').html("<%= escape_javascript(render :partial => 'foursquare_places_list', :locals => {:results => @results}) %>");
  $('#place_list').listview('refresh');
}

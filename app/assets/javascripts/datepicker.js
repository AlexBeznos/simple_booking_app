$(document).ready(function() {
  var today = new Date();

  $('.datepicker').datetimepicker({
    format: 'dddd, MMMM Do YYYY h:mm a z',
    minDate: today,
    sideBySide: true,
    widgetPositioning: {
                          horizontal: 'left',
                          vertical: 'bottom'
                       }
  });
});

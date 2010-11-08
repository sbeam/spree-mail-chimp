alert('AAAAN~');

var subscribe_email_default_txt = '';

jQuery(document).ready( function() {

    subscribe_email_default_txt = $('#subscribe_email').val();

    $('#subscribe_email').bind('focus', function() {
      if (this.value == subscribe_email_default_txt) this.value = '';
    });
    $('#subscribe_email').bind('blur', function() {
      if (this.value == '') this.value = subscribe_email_default_txt;
    });


    $('input[type=text],input[type=password]').addClass('textfield').wrap('<span class="inputborderwrap"></span>');


});

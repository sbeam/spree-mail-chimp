
var subscribe_email_default_txt = '';

jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

var SpreeMailchimpApp = {

  doSubmit: function(e) {
          SpreeMailchimpApp.getBusy(null); // could really use $.proxy here but spree doesn't have 1.4
          $.post(this.action+'.js', $(this).serialize(), SpreeMailchimpApp.getNotBusy, "script");
          return false;
  },

  getBusy : function( fn ) {
          $("body").css('cursor', 'progress');
          $("#busy_indicator").fadeIn('fast', fn);
  },

  getNotBusy : function() {
          $("body").css('cursor', 'default');
          $("#busy_indicator").fadeOut('fast');
  }

};



jQuery(document).ready( function() {

    subscribe_email_default_txt = $('#subscribe_email').val();

    $('#subscribe_email').bind('focus', function() {
      if (this.value == subscribe_email_default_txt) this.value = '';
    });
    $('#subscribe_email').bind('blur', function() {
      if (this.value == '') this.value = subscribe_email_default_txt;
    });

    $('#mailchimp_subscribe_wrap form').bind('submit', SpreeMailchimpApp.doSubmit);

});




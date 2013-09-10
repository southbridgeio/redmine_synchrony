$(function(){

  $('.add-synchrony-site').click(function(event){
    event.preventDefault();
    var nextRedmine = $('.synchrony-site-settings').length;
    $('#synchrony-sites').append(
      $('<fieldset>', { class: 'box synchrony-site-settings' }).append(
          $('<a href="#" class="icon icon-del contextual delete-synchrony-site">Delete</a>')
        ).append(
          $('<p>').append(
              $('<label for="settings_redmine_' + nextRedmine + '_source_site">Source site</label>')
            ).append(
              $('<input type="text" id="settings_redmine_' + nextRedmine + '_source_site" name="settings[redmine][][source_site]">')
            )
        )
    );
  });

  $('.delete-synchrony-site').live('click', function(event){
    event.preventDefault();
    $(this).closest('.synchrony-site-settings').remove();
  });

});
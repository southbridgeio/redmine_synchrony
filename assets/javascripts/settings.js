$(function(){
  // TODO add unique project validation before save
  var properties = $('#synchrony-sites')
  var translations = properties.data('i18n')
  var projects = properties.data('projects')
  var trackers = properties.data('trackers')

  var label = function(field_name, nextId){
    return $('<label for="settings_redmine_' + nextId + '_' + field_name + '">' + translations[field_name] + '</label>');
  };

  var inputField = function(field_name, nextId){
    return $('<p>').append(
      label(field_name, nextId)
    ).append(
      $('<input type="text" size="60" id="settings_redmine_' + nextId + '_' + field_name +
        '" name="settings[redmine][][' + field_name + ']">')
    );
  };

  var selectField = function(field_name, values, nextId){
    var options = [$('<option></option>')];
    for (var id in values) {
      if (values.hasOwnProperty(id)) {
        options.push($('<option value="' + id + '">' + values[id] + '</option>'))
      }
    }
    return $('<p>').append(
      label(field_name, nextId)
    ).append(
      $('<select id="settings_redmine_' + nextId +'_' + field_name + '" name="settings[redmine][][' + field_name + ']">').append(options)
    );
  };

  $('.add-synchrony-site').click(function(event){
    event.preventDefault();
    var nextRedmine = $('.synchrony-site-settings').length;
    $('#synchrony-sites').append(
      $('<fieldset>', { class: 'box synchrony-site-settings' }).append(
          $('<a href="#" class="icon icon-del contextual delete-synchrony-site">Delete</a>')
        ).append(
          inputField('source_site', nextRedmine)
        ).append(
          inputField('api_key', nextRedmine)
        ).append(
          inputField('source_tracker', nextRedmine)
        ).append(
          selectField('target_project', projects, nextRedmine)
        ).append(
          selectField('target_tracker', trackers, nextRedmine)
        )
    );
  });

  $('.delete-synchrony-site').live('click', function(event){
    event.preventDefault();
    $(this).closest('.synchrony-site-settings').remove();
  });

});
$(function(){
  var properties = $('#synchrony-sites')
  var translations = properties.data('i18n')
  var projects = properties.data('projects')
  var trackers = properties.data('trackers')
  var languages = properties.data('languages')

  var label = function(field_name, nextId, required){
    if(typeof(required)==='undefined') required = false;
    var result_label = $(
      '<label for="settings_redmine_' + nextId + '_' + field_name + '">' + translations[field_name] + '</label>'
    );
    if (required){
      result_label.append('<span class="required"> *</span>');
    }
    return result_label;
  };

  var inputField = function(field_name, nextId){
    return $('<p>').append(
      label(field_name, nextId, true)
    ).append(
      $('<input type="text" size="60" class="required" id="settings_redmine_' + nextId + '_' + field_name +
        '" name="settings[redmine][][' + field_name + ']">')
    );
  };

  var selectField = function(field_name, values, nextId, required){
    if(typeof(required)==='undefined') required = false;
    var select = $(
      '<select id="settings_redmine_' + nextId +'_' + field_name + '" name="settings[redmine][][' + field_name + ']">'
    );
    if(required){
      select.addClass('required');
    }
    if(!values.hasOwnProperty('')){
      $('<option></option>').appendTo(select);
    }
    for (var id in values) {
      if (values.hasOwnProperty(id)) {
        $('<option value="' + id + '">' + values[id] + '</option>').appendTo(select);
      }
    }
    return $('<p>').append(
      label(field_name, nextId, required)
    ).append(select);
  };

  var validatePresence = function() {
    var errorCount = 0;
    $('#settings input.required, #settings select.required').each(function(){
      var $this = $(this);
      if($this.val() === ''){
        if(!errorDisplayed($this)) {
          displayError($this, translations['errors.blank']);
        }
        errorCount++;
      } else {
        removeError($this);
      }
    });
    return !(errorCount > 0);
  };

  var validateProjectUniqueness = function() {
    var errorCount = 0;
    var projects = [];
    $('select[name="settings[redmine][][target_project]"]').each(function(){
      var $this = $(this);
      var project = $this.val();
      var existProjectIndex = $.inArray(project, projects);
      if(existProjectIndex >= 0) {
        errorCount++;
        if(!errorDisplayed($this)) {
          displayError($this, translations['errors.uniqueness']);
        }
        var existProjectSelect = $($('select[name="settings[redmine][][target_project]"]')[existProjectIndex]);
        if(!errorDisplayed(existProjectSelect)) {
          displayError(existProjectSelect, translations['errors.uniqueness']);
        }
      } else {
        removeError($this);
      }
      projects.push(project);
    });
    return !(errorCount > 0);
  };

  var errorDisplayed = function(element) {
    return element.closest('p').find('.error-notice').length > 0;
  };

  var displayError = function(element, message){
    element.addClass('error-setting');
    element.closest('p').append(
      $('<span class="error-notice">' + message + '</span>')
    );
  };

  var removeError = function(element){
    element.removeClass('error-setting');
    element.closest('p').find('.error-notice').remove();
  };

  $('.add-synchrony-site').click(function(event){
    event.preventDefault();
    var nextRedmine = $('.synchrony-site-settings').length;
    $('#synchrony-sites').append(
      $('<fieldset>', { class: 'box synchrony-site-settings' }).append(
          $(
            '<a href="#" class="icon icon-del contextual delete-synchrony-site">' +
              translations['button_delete'] + '</a>'
          )
        ).append(
          inputField('source_site', nextRedmine)
        ).append(
          inputField('api_key', nextRedmine)
        ).append(
          inputField('source_tracker', nextRedmine)
        ).append(
          selectField('target_project', projects, nextRedmine, true)
        ).append(
          selectField('target_tracker', trackers, nextRedmine, true)
        ).append(
          selectField('language', languages, nextRedmine)
        )
    );
  });

  $('.delete-synchrony-site').live('click', function(event){
    event.preventDefault();
    $(this).closest('.synchrony-site-settings').remove();
  });

  $('#settings form').submit(function(event){
    if(validatePresence() && validateProjectUniqueness()) {
      $(this).off('submit');
      $(this).trigger('submit');
    } else {
      event.preventDefault();
    }
  });

});
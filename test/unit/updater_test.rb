require File.expand_path('../../test_helper', __FILE__)
require 'synchrony/updater'
require 'fakeweb'

class UpdaterTest < ActiveSupport::TestCase

  fixtures :projects, :trackers

  def setup
    remote_redmine_url = 'http://remote-redmine.org/'
    FakeWeb.register_uri(:get, "#{remote_redmine_url}trackers.xml",
                         body: File.read(File.expand_path('../../fixtures/xml/trackers.xml', __FILE__)))
    @target_project = Project.find(1)
    @target_tracker = Tracker.find(1)
    @valid_settings = {
        'source_site' => remote_redmine_url, 'api_key' => 'some_api_key', 'source_tracker' => 'Administration',
        'target_project' => @target_project.id.to_s, 'target_tracker' => @target_tracker.id.to_s
    }
  end

  %w(source_site api_key source_tracker target_project target_tracker).each do |setting|
    define_method("test_settings_with_blank_#{setting}") do
      invalid_settings = @valid_settings.dup
      invalid_settings.delete(setting)
      assert_raises(Synchrony::Errors::InvalidSettingError) do
        Synchrony::Updater.new(invalid_settings)
      end
    end
  end

  def test_invalid_source_site
    invalid_settings = @valid_settings.dup
    invalid_settings['source_site'] = 'http://site-which-does-not-exist.local'
    assert_raises(Synchrony::Errors::InvalidSourceSiteError) do
      Synchrony::Updater.new(invalid_settings)
    end
  end

  def test_invalid_source_tracker
    invalid_settings = @valid_settings.dup
    invalid_settings['source_tracker'] = 'Not exist tracker'
    assert_raises(Synchrony::Errors::InvalidSourceTrackerError) do
      Synchrony::Updater.new(invalid_settings)
    end
  end

  def test_tracker_adds_to_project_when_it_not_added
    @target_project.trackers.delete(@target_tracker)
    Synchrony::Updater.new(@valid_settings)
    @target_project.reload
    assert @target_project.trackers.include?(@target_tracker)
  end

end
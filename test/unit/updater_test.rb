require File.expand_path('../../test_helper', __FILE__)
require 'synchrony/updater'
require 'fakeweb'

class UpdaterTest < ActiveSupport::TestCase

  fixtures :projects, :trackers, :issue_statuses, :enumerations, :issues, :journals, :users

  def setup
    @remote_redmine_url = 'http://remote-redmine.org/'
    @source_tracker = OpenStruct.new(id: 4, name: 'Administration') # from fixtures
    fake_remote_redmine(@remote_redmine_url, @source_tracker)
    @target_project = Project.find(1)
    @target_tracker = Tracker.find(1)
    @valid_settings = {
        'source_site' => @remote_redmine_url, 'api_key' => 'some_api_key', 'source_tracker' => @source_tracker.name,
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
    invalid_site = 'http://site-which-does-not-exist.local/'
    FakeWeb.register_uri(:get, "#{invalid_site}trackers.xml", exception: SocketError )
    invalid_settings = @valid_settings.dup
    invalid_settings['source_site'] = invalid_site
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

  def test_source_tracker_case_insensitive
    @valid_settings['source_tracker'] = 'admiNIstrATion'
    updater = Synchrony::Updater.new(@valid_settings)
    assert updater.send(:source_tracker) != nil
  end

  def test_language
    @valid_settings['language'] = :ru
    Synchrony::Updater.new(@valid_settings)
    assert I18n.locale == :ru
  end

  def test_tracker_adds_to_project_when_it_not_added
    @target_project.trackers.delete(@target_tracker)
    Synchrony::Updater.new(@valid_settings)
    @target_project.reload
    assert @target_project.trackers.include?(@target_tracker)
  end

  def test_issue_creating
    issues_count_before = Issue.count
    Synchrony::Updater.new(@valid_settings).sync_issues
    issues_count_after = Issue.count
    assert_equal 2, (issues_count_after - issues_count_before), 'Issues must be created'
  end

  def test_created_issue_with_synchrony_id
    Synchrony::Updater.new(@valid_settings).sync_issues
    assert Issue.last.synchrony_id != nil, 'Synchrony id must be defined for synchronized issues'
  end

  def test_created_issue_with_synchronized_at
    Synchrony::Updater.new(@valid_settings).sync_issues
    assert Issue.last.synchronized_at != nil, '"Synchronized at" must be defined for synchronized issues'
  end

  def test_issue_updating
    issue = Issue.where(project_id: @target_project.id).first
    issue.update_column(:synchrony_id, 1)

    journals_count_before = issue.journals.count
    Synchrony::Updater.new(@valid_settings).sync_issues
    journals_count_after = issue.journals.count
    assert_equal 2, (journals_count_after - journals_count_before), 'Journals must be added'
  end

  def test_journals_creating
    journals_count_before = Journal.count
    Synchrony::Updater.new(@valid_settings).sync_issues
    journals_count_after = Journal.count
    assert_equal 8, (journals_count_after - journals_count_before), 'Journals must be created'
  end

  def test_created_journal_with_synchrony_id
    Synchrony::Updater.new(@valid_settings).sync_issues
    assert Journal.last.synchrony_id != nil, 'Synchrony id must be defined for synchronized journals'
  end

  def test_created_journal_with_same_created_on_time
    Synchrony::Updater.new(@valid_settings).sync_issues
    journal = Journal.where(synchrony_id: 1).first # from fixture
    assert journal.created_on == Time.parse('2013-09-10T13:53:52Z'),
           'Created on for synchronized journal should be equal to source journal'
  end

  def test_journal_notes
    Synchrony::Updater.new(@valid_settings).sync_issues
    journal = Journal.where(synchrony_id: 3).first # from fixture
    assert journal.notes.include?('Text comment'), 'Journal should have notes from source journal'
  end

  def test_journal_status_detail
    Synchrony::Updater.new(@valid_settings).sync_issues
    journal = Journal.where(synchrony_id: 4).first # from fixture
    assert journal.notes.include?('New'), 'Journal should have status changing text'
    assert journal.notes.include?('Accepted'), 'Journal should have status changing text'
  end

  def test_journal_assigned_to_detail
    Synchrony::Updater.new(@valid_settings).sync_issues
    journal = Journal.where(synchrony_id: 7).first # from fixture
    assert journal.notes.include?('Redmine Admin'), 'Journal should have assigned user name text'
  end

  def test_journal_priority_detail
    Synchrony::Updater.new(@valid_settings).sync_issues
    journal = Journal.where(synchrony_id: 7).first # from fixture
    assert journal.notes.include?('Normal'), 'Journal should have priority changing text'
    assert journal.notes.include?('High'), 'Journal should have priority changing text'
  end

  def test_journal_priority_detail_for_old_redmine_versions
    FakeWeb.register_uri(:get, "#{@remote_redmine_url}enumerations/issue_priorities.xml",
                         status: ['404', 'Not found'])
    Synchrony::Updater.new(@valid_settings).sync_issues
    journal = Journal.where(synchrony_id: 7).first # from fixture
    assert !journal.notes.include?('Normal'), 'Journal should not have priority changing text'
    assert !journal.notes.include?('High'), 'Journal should not have priority changing text'
  end

  private

  def fake_remote_redmine(site, tracker)
    FakeWeb.allow_net_connect = false
    issues_uri = "#{site}issues.xml?status_id=#{ERB::Util.url_encode('*')}&tracker_id=#{tracker.id}" +
                                "&updated_on=#{ERB::Util.url_encode('>=')}#{Synchrony::Updater::START_DATE}"
    FakeWeb.register_uri(:get, issues_uri,
                         body: File.read(File.expand_path('../../fixtures/xml/issues.xml', __FILE__)))
    [1, 2].each do |issue_id|
      FakeWeb.register_uri(:get, "#{site}issues/#{issue_id}.xml?include=journals",
                           body: File.read(File.expand_path("../../fixtures/xml/issue_#{issue_id}.xml", __FILE__)))
    end
    %w(trackers issue_statuses).each do |resource_name|
      FakeWeb.register_uri(:get, "#{site}#{resource_name}.xml",
                           body: File.read(File.expand_path("../../fixtures/xml/#{resource_name}.xml", __FILE__)))
    end
    FakeWeb.register_uri(:get, "#{site}enumerations/issue_priorities.xml",
                         body: File.read(File.expand_path('../../fixtures/xml/issue_priorities.xml', __FILE__)))
    FakeWeb.register_uri(:get, "#{site}users/1.xml",
                         body: File.read(File.expand_path('../../fixtures/xml/user_1.xml', __FILE__)))
  end

end
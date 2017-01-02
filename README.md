# Redmine Synchrony

Plugin makes copies of last updated issues and journals from another redmine instance via API.
Plugin compatible with Redmine 2.0.x, 2.1.x, 2.2.x, 2.3.x, 2.5.x, 3.2.x (for source and destination instance)

Please help us make this plugin better telling us of any [issues](https://github.com/centosadmin/redmine_synchrony/issues) you'll face using it. We are ready to answer all your questions regarding this plugin.

## WARNING

All **rake** commands must be run with correct **RAILS_ENV** variable, e.g.
```
RAILS_ENV=production rake redmine:plugins:migrate
```

## Installation

1. Stop redmine

2. Clone repository to your redmine/plugins directory
```
git clone https://github.com/olemskoi/redmine_synchrony.git
```

3. Run migrations
```
rake redmine:plugins:migrate
```

4. Run redmine

5. Setup "Redmine Synchrony" plugin (Administration - Plugins - Configure "Redmine Synchrony plugin"):
  * Source site: url to redmine instance
  * API key: api key of user with read access from source redmine
  * Source tracker: tracker's name for issue filtration. Issues will be copied with this tracker only
  * Local target project: destination project. Must be unique for each synchronized redmine
  * Local target tracker: destination tracker. It will be added to 'Local target project' if project hasn't it
  * Language (optional): I18n for notes

## Usage

Just run next rake task periodically
```
rake redmine_synchrony:issues
```
It checks last created/updated issues (today and yesterday) and copies changes.

## Uninstall

1. Stop redmine.

2. Rollback migration
```
rake redmine:plugins:migrate VERSION=0 NAME=redmine_synchrony
```

3. Remove plugin directory from your redmine/plugins directory

## Where get API key?

1. Activate the RESTful API in source Redmine in Administration - Settings - Authentication - Option "Enable REST web service"

2. Go to your profile page (/my/account) and get api key from right panel

## Sponsors

Work on this plugin was fully funded by [centos-admin.ru](http://centos-admin.ru)

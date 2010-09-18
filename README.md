# Highrise Importer plugin for Fat Free CRM

## Assumptions: one Highrise account which is mapped to Fat Free CRM admin account.

  * Pull "dropbox" branch of Fat Free CRM, see http://github.com/michaeldv/fat_free_crm/network
  * `rake db:migrate`
  * `ruby script/plugin install git://github.com/michaeldv/crm_highrise_importer.git`
  * `rake crm:highrise:import SITE=[Your Highrise URL]`

*Note:* [Your Highrise URL] should be http://**yourapikey**:X@subdomain.highrisehq.com eg:

`rake crm:highrise:import SITE=http://1d93c8294:X@sample.highrisehq.com/`

#### What's the deal with the :X ?

When using the authentication token, you don't need a separate password. But since Highrise uses HTTP Basic Authentication, and lots of implementations assume that you want to have a password, it's often easier just to pass in a dummy password, like X. (source: http://developer.37signals.com/highrise/)

Copyright (c) 2009-10 Michael Dvorkin, released under the GNU Affero General Public License

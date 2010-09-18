# Highrise Importer plugin for Fat Free CRM

## Assumptions: one Highrise account which is mapped to Fat Free CRM admin account.

  * `rake db:migrate`
  * `ruby script/plugin install git://github.com/michaeldv/crm_highrise_importer.git`
  * `rake crm:highrise:import SITE=[Your Highrise URL]`

#### [Your Highrise URL] should be:

`http://**yourapitoken**:X@subdomain.highrisehq.com`

WHERE:

  * yourapitoken is your api token from Highrise (sign in, click `My Info`, click `API token`)
  * X is just a dummy placeholder for password, which you don't need.  Find out more information about that: http://developer.37signals.com/highrise/
  * subdomain is your highrise account subdomain

`rake crm:highrise:import SITE=http://1d93c8294:X@sample.highrisehq.com/`

### Important note about SSL and redirect errors

If you try this rake task and get an error: `Failed with 302 Found => https://sample.highrisehq.com/people.xml?n=0` your account is set to use SSL authentication and you need to specify https as the SITE parameter to the rake task

Copyright (c) 2009-10 Michael Dvorkin, released under the GNU Affero General Public License

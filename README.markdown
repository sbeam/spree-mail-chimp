h1. Spree + Mail Chimp 

MailChimp API integration for your Spree store, using the hominid gem.

Adds a checkbox to the user signup form to allow customer to opt-in to your Mailchimp mailing list. Mailchimp API calls happen via the hominid gem.

Mailchimp subscription status is tracked with a boolean flag on the users table, we also fetch and store the unique MC record id when the subscription is created. This allows us to modify existing email addresses with minimal fuss.

This is a very simple extension as of now, *any ideas suggestions or improvements welcome!*

h2. Subscription form partial with JS

Also includes a partial at <code>shared/newsletter_subscribe_form</code> that can be included in your footer or sidebar anywhere on the site, has one field for the email address. jQuery code in <code>public/javascripts/mailchimp_subscribe.js</code> will POST to the SubscriptionsController which will relay to Mailchimp. 

The SimpleModal plugin is used in the EJB to pop up a confirmation or error alert (because you won't be satisfied with a simple alert() box)

h3. Installation ###

<pre><code>
./script/extension install git://github.com/sbeam/spree-mail-chimp.git
</code> </pre>

h3. Configuration ###

Look at <code>config/initializers/mail_chimp_settings.rb</code> - copy this to your site extension and add your own MailChimp API key and list ids.

h3. Changes ###

Version 1.0 - released 8 Nov 2010

h3. Requirements ###

Spree =~ 0.11.99 (not 0.30, yet)
hominid >= 2.2.0 http://rubygems.org/gems/hominid

Also uses the jQuery SimpleModal plugin, included.

h3. Credits ###

Authored by Sam Beam sbeam@onsetcorps.net

Inspired originally by Mailee Spree https://github.com/softa/mailee_spree

includes SimpleModal http://www.ericmmartin.com/projects/simplemodal/

h3. TODO ###

* Make Rails 3/Spree 0.30 compat
* Export new orders to Mailchimp for full CRM gnarliness
* Utility to export existing users to Mailchimp
* Add admin controller to view lists and subscriptions
* Allow for multiple lists
* Make modal dialog play nicer with other css/layout requirements
* Tests :/


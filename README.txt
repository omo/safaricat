
= Safaricat : O'reilly Safari Scraper for offline reading =

Safaricat is a screen scraper for O'Reilly Safari Books Online.
Safaricat can format and combine multiple book pages on Safari onlin reader 
for "offline" reading, as with ebook readers.

Note that Safaricat assumes that you've subscribed the account and 
provide NO way to access it freely. You can just suscriibe Safari Library.
at the site: http://www.safaribooksonline.com/ .

== Prerequirement ==

 * Ruby 1.8.x
 * Hpricot

== Usage ==

Download pages (manually!) :

 * Open a section page with Safari Online reader on your browser. 
   For example, open http://my.safaribooksonline.com/9780137126347/part01 .

 * Save the page and associated file to your disk drive
   With Firefox, you can use "Web Page, complee" option for this purpose.

 * Go next section, and save the page(s) subsequently.
   TIPS: URLs on Safari is not Safaricat-friendly.
         You may change the filename from ch01.html to ch01_sec01a.html, etc.
         to avoid name conflict.

Combine Downloaded Pages:

 * pass HTML filenames to the argument.
 * save stdout as a html.

 $ safaricat.rb somewhere/*.html > out.html

== TODO ==

 * automatic download with my account
 * customizable style

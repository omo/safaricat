
= Safaricat : Safari Books Formatter for offline reading =

Safaricat is a HTML formatter Safari Books Online.
Safaricat can format and combine multiple book pages on Safari onlin reader 
for "offline" reading, as with ebook readers.

Note that Safaricat assumes that you've subscribed the account and 
provide NO way to access it freely. You can just suscriibe Safari Library.

== Prerequirement ==

 * Ruby 1.8.x
 * Hpricot

== Usage ==

Download pages (manually; the service explicitly prohibit spidering) :

 * Open a section page with your browser. 

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

 * customizable style
 * create TOC

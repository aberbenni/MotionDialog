MonotionDialog
================

MonotionDialog is a port of MonoTouch.Dialog to RubyMotion.
It is a foundation to create dialog boxes and show
table-based information. Table support Pull-to-Refresh
as well as built-in searching.

![screenshot](http://www.berbenni.com/images/md.png "Sample") 

Currently this supports creating Dialogs based on navigation controllers 
that support both basic and advanced cells.

Some basic cells include:

  * On/Off controls
  * Slider (floats)
  * String informational rendering
  * Text Entry
  * Password Entry
  * Jump to HTML page
  * Radio elements
  * Dates, Times and Dates+Times
  * Pull-to-refresh functionality
  * Activity indicators

Advanced cells include:
  * Container for arbitrary UIViews
  * Mail-like message displays
  * Styled cells

**Check out a working sample app [here][Sample]!**

[Sample]: https://github.com/aberbenni/MotionDialog/tree/master/Samples

Forking
-------
Feel free to fork! And if you end up using MonotionDialog in your app, I'd love to hear about your experience.

Bugs
----

Please report any bugs you find with our source at the
[Issues](https://github.com/aberbenni/MotionDialog/issues) page.

Todo
----
- Rubyfy with BubbleWrap and Metaprogramming
- More Tests
- More Elements
- Create gem
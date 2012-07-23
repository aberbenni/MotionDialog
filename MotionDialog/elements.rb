
# Elements: defines the various components of our view 
#
# Author:: Alessandro Berbenni (mailto:aberbenni@gmail.com)
# Copyright:: Copyright (c) 2012 Alessandro Berbenni
# License::   This code is licensed under the terms of the MIT X11 license
#       
# Code based on Miguel de Icaza's MonoTouch.Dialog.Elements

module MotionDialog

	include Enumerable
	
	# Base class for all elements in MotionDialog
	class Element
				
		# Handle to the container object.
		# For sections this points to a RootElement, for every
		# other object this points to a Section and it is null
		# for the root RootElement.
		@parent #public Element
		
		# The caption to display for this given element
		@caption
		
		attr_accessor :parent, :caption
		
		# Initializes the element with the given caption.
		def initialize(caption)
			@caption = caption
		end
		
		@@cellkey = "xx"
		
		# Gets a UITableViewCell for this element.   Can be overridden, but if you
		# customize the style or contents of the cell you must also override the CellKey
		# property in your derived class.
		def getCell(tv)
			UITableViewCell.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:self.cellKey)
		end
	
		# Returns a summary of the value represented by this object, suitable
		# for rendering as the result of a RootElement with child objects.
		# The return value must be a short description of the value.
		def summary()
			""
		end
	
		
		# Invoked when the given element has been deslected by the user.
		# dvc: The DialogViewController where the deselection took place
		# tableView: The UITableView that contains the element.
		# path: The NSIndexPath that contains the Section and Row for the element.
		def deselected(dvc, tableView, path)			
		end
		
		# Invoked when the given element has been selected by the user.
		# dvc: The DialogViewController where the selection took place
		# tableView: The UITableView that contains the element.
		# path: The NSIndexPath that contains the Section and Row for the element.
		# </param>
		def selected(dvc, tableView, path)			
		end
	
		# If the cell is attached will return the immediate RootElement	
		def getImmediateRootElement()
			section = @parent
			if section.nil? then
				return nil
			end
			section.parent
		end
		
		# Returns the UITableView associated with this element, or null if this cell is not currently attached to a UITableView
		def getContainerTableView()
			root = getImmediateRootElement()
			if root.nil? then
				return nil
			end
			root.tableView
		end
		
		# Returns the currently active UITableViewCell for this element, or null if the element is not currently visible
		def getActiveCell()
			tv = getContainerTableView()
			if tv.nil? then
				return nil
			end
			path = indexPath()
			if path.nil? then
				return nil
			end
			tv.cellForRowAtIndexPath(path)
		end
		
		# Returns the IndexPath of a given element.   This is only valid for leaf elements,
		# it does not work for a toplevel RootElement or a Section of if the Element has
		# not been attached yet.
		def indexPath()
			section = @parent
			if section.nil? then
				return nil
			end
			root = section.parent
			if root.nil? then
				return nil
			end
			row = 0
			
			section.elements.each do |element|
				if element == self then
					nsect = 0
					root.sections.each do |sect|
						if section == sect then
							indexPath = NSIndexPath.indexPathForRow(row, inSection:nsect)
							indexes = (0..indexPath.length).map { |x| indexPath.indexAtPosition(x) }
							return indexPath
						end
						nsect += 1
					end
				end
				row += 1
			end
			return nil
		end
	
		# Method invoked to determine if the cell matches the given text,
		# never invoked with a nil value or an empty string.
		def matches(text)
			if @caption.nil? then
				return false
			end
			@caption.downcase().index(text.downcase()) != nil
		end
		
		protected
		
		# Subclasses that override the getCell method should override this method as well
		# This method should return the key passed to UITableView.DequeueReusableCell.
		# If your code overrides the getCell method to change the cell, you must also
		# override this method and return a unique key for it.
		# This works in most subclasses with a couple of exceptions: StringElement and
		# various derived classes do not use this setting as they need a wider range
		# of keys for different uses, so you need to look at the source code for those
		# if you are trying to override StringElement or StyledStringElement.
		def cellKey()
			@@cellkey
		end
		 
		def self.removeTag(cell, tag)
			viewToRemove = cell.contentView.viewWithTag(tag)
			if viewToRemove != nil then
				viewToRemove.removeFromSuperview()
			end
		end
		
	end #class
	
	class BoolElement < Element
	
		def value
			@val
		end
	
		def value=(value)
			#emit = @val != value
			@val = value
		end
	
		def initialize(caption, value)
			super(caption)
			@val = value
		end
	
		def summary()
			@val ? "On" : "Off"
		end
		
	end #class
	
	# Used to display switch on the screen.
	class BooleanElement < BoolElement
		@@bkey = "BooleanElement"
		
		def initialize(caption, value, key=nil)
			super(caption, value)
		end
		
		def getCell(tv)
			if @sw.nil? then
				@sw = UISwitch.alloc.init.tap{|sw|
					sw.backgroundColor = UIColor.clearColor
					sw.tag = 1
					sw.setOn(self.value(), animated:false)
				}
				@sw.addTarget(self, action: :toggleOn, forControlEvents: UIControlEventValueChanged)
			else
				@sw.setOn(self.value(), animated:true)
			end
			cell = tv.dequeueReusableCellWithIdentifier(self.cellKey())
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:self.cellKey())
				cell.selectionStyle = UITableViewCellSelectionStyleNone
			else
				self.class.removeTag(cell, 1)
			end
			cell.textLabel.text = @caption
			cell.accessoryView = @sw
			cell
		end
			
		def value
			super
		end
		
		def value=(value)
			super value
			if @sw != nil then
				@sw.on = value
			end
		end
		
		protected #all methods that follow will be made protected
		
		def cellKey
			@@bkey
		end
		
		def toggleOn 
			self.value = @sw.isOn
		end
		
	end #class

	# This class is used to render a string + a state in the form
	# of an image.
	# It is abstract to avoid making this element
	# keep two pointers for the state images, saving 8 bytes per
	# slot.   The more derived class "BooleanImageElement" shows
	# one way to implement this by keeping two pointers, a better
	# implementation would return pointers to images that were
	# preloaded and are static.
	# 
	# A subclass only needs to implement the getImage method.
	class BaseBooleanImageElement < BoolElement
		@@key = "BooleanImageElement"
	
		attr_accessor :tapped
	
		class TextWithImageCellView < UITableViewCell
			
			FontSize = 17
			@@font = nil #=UIFont.boldSystemFontOfSize(FontSize)
			ImageSpace = 32
			Padding = 8
			
			def initWithStyle(style, reuseIdentifier: reuseIdentifier)
				super(style, reuseIdentifier)
			end
			
			def initialize(parent_)
			    self.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier: parent_.send(:cellKey))
			    @@font = UIFont.boldSystemFontOfSize(FontSize)
				@parent = parent_
				@label = UILabel.alloc.init.tap{|l| 
					l.textAlignment = UITextAlignmentLeft
					l.text = @parent.caption
					l.font = @@font
					l.backgroundColor = UIColor.clearColor
				}				
				@button = UIButton.buttonWithType(UIButtonTypeCustom)
				@button.addTarget(self, action: 'toggle', forControlEvents:UIControlEventTouchDown)
				self.contentView.addSubview(@label)
				self.contentView.addSubview(@button)
				updateImage()
			end
	
			def toggle
				@parent.value = !@parent.value
				self.updateImage()
				if @parent.tapped != nil then
					@parent.tapped.call()
				end 
			end
	
			def updateImage()
				@button.setImage(@parent.getImage(), forState:UIControlStateNormal)
			end
	
			def layoutSubviews()
				super()
				full = self.contentView.bounds
				frame = full
				frame.size.height = 22
				frame.origin.x = Padding
				frame.origin.y = (full.size.height - frame.size.height) / 2
				frame.size.width -= ImageSpace + Padding
				@label.frame = frame
				@button.frame = CGRectMake(full.size.width - ImageSpace, -3, ImageSpace, 48)
			end
	
			def updateFrom(newParent)
				@parent = newParent
				updateImage()
				@label.text = @parent.caption
				setNeedsDisplay()
			end
			
		end #class
		
		def initialize(caption, value)
			super(caption, value)
		end
					
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(self.cellKey())
			if cell.nil? then
				cell = TextWithImageCellView.new(self)
			else
				cell.updateFrom(self)
			end
			cell
		end
			
		protected #all methods that follow will be made protected
			
		def getImage()
			raise NotImplementedError, "Abstract Method"
		end
		
		def cellKey
			@key
		end
	
	end #class
	
	class BooleanImageElement < BaseBooleanImageElement
		
		def initialize(caption, value, onImage, offImage)
			super(caption, value)
			@onImage = onImage
			@offImage = offImage
		end
	
		def getImage()
			if self.value then
				return @onImage
			else
				return @offImage
			end
		end
	
	end #class
	
	# Used to display a slider on the screen.
	class FloatElement < Element
		@@skey = "FloatElement"
		
		attr_accessor :showCaption, :value, :minValue, :maxValue 
	
		def initialize(left, right, value)
			super(nil)
			@left = left
			@right = right
			@minValue = 0
			@maxValue = 1
			@value = value
		end
	
		def summary()
			@value.to_s()
		end
		
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(self.cellKey())
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:self.cellKey())
				cell.selectionStyle = UITableViewCellSelectionStyleNone
			else
				self.class.removeTag(cell, 1)
			end
			captionSize = CGSize.new(0, 0)
			if caption != nil and showCaption then
				cell.textLabel.text = caption
				captionSize = caption.sizeWithFont(UIFont.fontWithName(cell.textLabel.font.fontName, UIFont.labelFontSize))
				captionSize.width += 10 #spacing
			end
			
			if @slider.nil? then
				@slider = UISlider.alloc.initWithFrame(CGRectMake(10.0 + captionSize.width, 12.0, 280.0 - captionSize.width, 7.0)).tap do |sl|
					sl.backgroundColor = UIColor.clearColor
					sl.minimumValue = @minValue
					sl.maximumValue = @maxValue
					sl.continuous = true
					sl.value = @value
					sl.tag = 1
				end
				#slider.ValueChanged += delegate {
				#	Value = slider.Value;
				#};
				@slider.addTarget(self, action:'changeValue', forControlEvents:UIControlEventValueChanged)
			else
				@slider.value = @value
			end
			cell.contentView.addSubview(@slider)
			cell
		end
		
		def changeValue
			@value = @slider.value
		end
		
		protected
		
		def cellKey
			return @skey
		end
	
	end #class
	
	# Used to display a cell that will launch a web browser when selected.
	class HtmlElement < Element
		@@hkey = "HtmlElement"
		
		attr_accessor :web
		
		def initialize(caption, url)
			super(caption)
			self.Url = url
		end
	
		def Url
			@nsUrl.to_s()
		end
	
		def Url=(value)
			@nsUrl = NSURL.URLWithString(value)
		end
	
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(self.cellKey())
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: self.cellKey())
				cell.selectionStyle = UITableViewCellSelectionStyleBlue
			end
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
			cell.textLabel.text = self.caption()
			cell
		end
	
		def networkActivity=(value)
			UIApplication.sharedApplication.networkActivityIndicatorVisible = value
		end
	
		# We use this class to dispose the web control when it is not
		# in use, as it could be a bit of a pig, and we do not want to
		# wait for the GC to kick-in.
		class WebViewController < UIViewController
				
			attr_accessor :autorotate
			
			def initialize(container)
				@container = container
			end
	
			def viewWillDisappear(animated)
				super(animated)
				networkActivity = false
				if @container.web.nil? then
					return 
				end
				@container.web.stopLoading()
				@container.web = nil
			end
		
			def shouldAutorotateToInterfaceOrientation(toInterfaceOrientation)
				self.autorotate
			end
			
		end #class
	
		def selected(dvc, tableView, path)
			@vc = WebViewController.new(self).tap do |wvc| 
				wvc.autorotate = dvc.autorotate
			end
			web = UIWebView.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |wv|
				wv.backgroundColor = UIColor.whiteColor
				wv.scalesPageToFit = true
				wv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin 
			end
			
			web.delegate = self
			
			@vc.navigationItem.title = self.caption()
			@vc.view.autoresizesSubviews = true
			@vc.view.addSubview(web)
			dvc.activateController(@vc)
			web.loadRequest(NSURLRequest.requestWithURL( @nsUrl ))
		end
		
		#UIWebViewDelegate Methods
		
		def webViewDidStartLoad(webView)
 			networkActivity = true
			indicator = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)			
			@vc.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(indicator)
			indicator.startAnimating()
 		end
 		
 		def webViewDidFinishLoad(webView)
 			networkActivity = false
			@vc.navigationItem.rightBarButtonItem = nil
 		end
 		
		def webView(webView, didFailLoadWithError:error)
			networkActivity = false
			@vc.navigationItem.rightBarButtonItem = nil
			if web != nil then
				web.loadHTMLString("<html><center><font size=+5 color='red'>An error occurred:<br>#{error.localizedDescription}</font></center></html>", baseURL: nil)
			end
		end
		
		protected #all methods that follow will be made protected
		
		def cellKey
			@@hkey
		end
		
	end #class
	
	# The string element can be used to render some text in a cell
	# that can optionally respond to tap events.
	class StringElement < Element
		@@skey = "StringElement"
		@@skeyvalue = "StringElementValue"
	
		attr_accessor :alignment, :tapped, :value
		
		def value
			@value
		end
	
		def value=(value)
			@value = value
		end
	
		def initialize(caption, val=nil)
			super(caption)
			@alignment = UITextAlignmentLeft
			@value = nil
			if !val.nil? then
				if val.kind_of?(String) then
					@value = val
				elsif val.kind_of?(Method) then
					@tapped = val
				end
			end	
		end
		
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(@value.nil? ? @@skey : @@skeyvalue)
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle( (@value.nil? ? UITableViewCellStyleDefault : UITableViewCellStyleValue1), reuseIdentifier:@@skey )
				cell.selectionStyle = (@tapped != nil) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone
			end
			cell.accessoryType = UITableViewCellAccessoryNone
			cell.textLabel.text = self.caption
			cell.textLabel.textAlignment = @alignment
			# The check is needed because the cell might have been recycled.
			if cell.detailTextLabel != nil then
				cell.detailTextLabel.text = @value.nil? ? "" : @value #if !@value.is_a?(TrueClass) && !@value.is_a?(FalseClass) #horrible patch!
			end
			cell
		end
	
		def summary()
			self.caption
		end
	
		def selected(dvc, tableView, indexPath)
			if @tapped != nil then
				@tapped.call() #self.tapped()
			end
			tableView.deselectRowAtIndexPath(indexPath, animated:true)
		end
	
		def matches(text)			
			return (@value != nil ? @value.downcase().index(text.downcase()) != -1 : false) || (super(text))
		end
		
	end #class
	
	#   A version of the StringElement that can be styled with a number of formatting 
	#   options and can render images or background images either from UIImage parameters 
	#   or by downloading them from the net.
	class StyledStringElement < StringElement #, IImageUpdated, IColorizeBackground
		@@skey = [".1", ".2", ".3", ".4"]
				
		attr_accessor :accessoryTapped, :font, :subtitleFont, :textColor, :lineBreakMode, :lines, :accessory
		
		def initialize(caption, val=nil, style=UITableViewCellStyleValue1)
			super(caption, val)
			@lineBreakMode = UILineBreakModeWordWrap
			@lines = 0
			@accessory = UITableViewCellAccessoryNone
			@style = UITableViewCellStyleDefault
			if !val.nil? then
				if val.kind_of?(String) then
					@style = style
				end
			end
		end
		
		class ExtraInfo
			#Maybe add backgroundImage?
			attr_accessor :image, :backgroundColor, :detailColor, :uri, :backgroundUri			
		end
		
		# To keep the size down for a StyleStringElement, we put all the image information
		# on a separate structure, and create this on demand.
		def onImageInfo
			if @extraInfo.nil?
				@extraInfo = ExtraInfo.new
			end
			@extraInfo
		end
		
		# Uses the specified image (use this or imageUri)
		def image
			@extraInfo.nil? ? nil : @extraInfo.image
		end
		
		def image=(value)
			self.onImageInfo().image = value
			@extraInfo.uri = nil
		end
		
		# Loads the image from the specified uri (use this or image)
		def imageUri 
			@extraInfo.nil? ? nil : @extraInfo.uri
		end
		
		def imageUri=(value) 
			self.onImageInfo().uri = value
			@extraInfo.image = nil
		end
		
		# Background color for the cell (alternative: backgroundUri)
		def backgroundColor
			@extraInfo.nil? ? nil : @extraInfo.backgroundColor
		end
		
		def backgroundColor=(value)
			self.onImageInfo().backgroundColor = value
			@extraInfo.backgroundUri = nil
		end
		
		def detailColor
			@extraInfo.nil? ? nil : @extraInfo.detailColor
		end
		
		def detailColor=(value)
			self.onImageInfo().detailColor = value
		end
		
		# Uri for a background image (alternative: backgroundColor)
		def backgroundUri
			@extraInfo.nil? ? nil : @extraInfo.backgroundUri
		end
			
		def backgroundUri=(value)
			self.onImageInfo().backgroundUri = value
			@extraInfo.backgroundColor = nil
		end
			
		def getCell(tv) 
			key = self.getKey(@style)
			cell = tv.dequeueReusableCellWithIdentifier(key)
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(@style, reuseIdentifier:key)
				cell.selectionStyle = UITableViewCellSelectionStyleBlue
			end
			self.prepareCell(cell)
			cell
		end
		
		def clearBackground(cell) 
			cell.backgroundColor = UIColor.whiteColor
			cell.textLabel.backgroundColor = UIColor.clearColor
		end
		
		def willDisplay(tableView, cell, indexPath)
						
			if @extraInfo.nil? then
				self.clearBackground(cell)
				return
			end
			
			if @extraInfo.backgroundColor != nil then
				cell.backgroundColor = @extraInfo.backgroundColor
				cell.textLabel.backgroundColor = UIColor.clearColor
			elsif @extraInfo.backgroundUri != nil then
				img = UIImage.imageWithContentsOfFile(@extraInfo.backgroundUri) #ImageLoader.defaultRequestImage(@extraInfo.backgroundUri, self)
				cell.backgroundColor = img.nil? ? UIColor.whiteColor : UIColor.colorWithPatternImage(img)
				cell.textLabel.backgroundColor = UIColor.clearColor
				self.updatedImage(@extraInfo.backgroundUri)
			else 
				self.clearBackground(cell)
			end
		end

		def updatedImage(uri) 
			if uri.nil? || @extraInfo.nil? then
				return
			end
			root = self.getImmediateRootElement()
			if (root.nil? || root.tableView.nil?) then
				return
			end
			root.tableView.reloadRowsAtIndexPaths([self.indexPath], withRowAnimation: UITableViewRowAnimationNone)
		end

		protected #all methods that follow will be made protected
		
		def getKey(style)
			@@skey [style]
		end
		 
		def prepareCell(cell)
			cell.accessoryType = @accessory
			tl = cell.textLabel
			tl.text = self.caption
			tl.textAlignment = self.alignment
			tl.textColor = @textColor || UIColor.blackColor
			tl.font = @font || UIFont.boldSystemFontOfSize(17)
			tl.lineBreakMode = @lineBreakMode
			tl.numberOfLines = @lines
			
			# The check is needed because the cell might have been recycled.
			if cell.detailTextLabel != nil then
				cell.detailTextLabel.text = self.value || ""
			end
			
			if @extraInfo.nil? then
				self.clearBackground(cell)
			else
				imgView = cell.imageView
				#img #UIImage

				if imgView != nil then
					if @extraInfo.uri != nil then
						img = ImageLoader.defaultRequestImage(@extraInfo.uri, self)
					elsif @extraInfo.image != nil then
						img = @extraInfo.image
					else 
						img = nil
					end
					imgView.image = img
				end

				if cell.detailTextLabel != nil then
					cell.detailTextLabel.textColor = @extraInfo.detailColor || UIColor.grayColor
				end
			end
				
			if cell.detailTextLabel != nil then
				cell.detailTextLabel.numberOfLines = @lines
				cell.detailTextLabel.lineBreakMode = @lineBreakMode
				cell.detailTextLabel.font = @subtitleFont || UIFont.systemFontOfSize(14)
				cell.detailTextLabel.textColor = (@extraInfo.nil? || @extraInfo.detailColor.nil?) ? UIColor.grayColor : @extraInfo.detailColor
			end
			
		end

	end #class
	
	class StyledMultilineElement < StyledStringElement
	
		def initialize(caption, val=nil, style=nil)
			super(caption, val)
			if !val.nil? then
				if val.kind_of?(String) then
					@style = style
				end
			end
		end
	
		def getHeight(tableView, indexPath)
			margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 40.0 : 110.0
			maxSize = CGSize.new(tableView.bounds.size.width - margin, Float::MAX)
			if self.accessory != UITableViewCellAccessoryNone then
				maxSize.width -= 20
			end
			c = self.caption
			v = self.value
			# ensure the (multi-line) Value will be rendered inside the cell when no Caption is present
			if c.to_s.empty? && !v.to_s.empty? then
				c = " "
			end

			captionFont = self.font || UIFont.boldSystemFontOfSize(17)
			height = c.sizeWithFont(captionFont, constrainedToSize: maxSize, lineBreakMode: self.lineBreakMode ).height

			if !v.to_s.empty? then
				subtitleFont = self.subtitleFont || UIFont.SystemFontOfSize(14)
				if @style == UITableViewCellStyleSubtitle then
					height += v.sizeWithFont(subtitleFont, constrainedToSize: maxSize, lineBreakMode: self.lineBreakMode ).height
				else
					vheight = v.sizeWithFont(subtitleFont, constrainedToSize: maxSize, lineBreakMode: self.lineBreakMode ).height
					if vheight > height then
						height = vheight
					end
				end
			end
			height + 10
		end
	end
	
	#ImageStringElement < StringElement
	
	class MultilineElement < StringElement
		def initialize(caption, arg=nil)
			super(caption, arg)
		end
	
		def getCell(tv)
			cell = super(tv)
			tl = cell.textLabel
			tl.lineBreakMode = UILineBreakModeWordWrap
			tl.numberOfLines = 0
			cell
		end
	
		def getHeight(tableView, indexPath)
			margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 40.0 : 110.0
			size = CGSize.new(tableView.bounds.size.width - margin, Float::MAX) #3.40282346638528859E+38
			font = UIFont.boldSystemFontOfSize(17)
			c = self.caption()
			# ensure the (single-line) Value will be rendered inside the cell
			if c.to_s.empty? && !self.value.to_s.empty? then
				c = " "
			end			
			c.sizeWithFont(font, constrainedToSize:size, lineBreakMode: UILineBreakModeWordWrap).height + 10
		end
	end
	
	class RadioElement < StringElement
		
		attr_accessor :group, :radioIdx
		
		def initialize(caption, group=nil)
			super(caption)
			@group = group if !group.nil?
		end

		def getCell(tv)
			cell = super(tv)			
			root = self.parent.parent
			if !root.group.kind_of?(RadioGroup) then
				raise "The RootElement's Group is nil or is not a RadioGroup"
			end
			selected = @radioIdx == root.group.selected
			cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
			cell
		end

		def selected(dvc, tableView, indexPath)
			root = self.parent.parent if self.parent.parent.kind_of?(RootElement)
			if @radioIdx != root.radioSelected then
				cell = nil
				selectedIndex = root.pathForRadio(root.radioSelected)
				if selectedIndex != nil then
					cell = tableView.cellForRowAtIndexPath(selectedIndex)
					if cell != nil
						cell.accessoryType = UITableViewCellAccessoryNone
					end
				end
				cell = tableView.cellForRowAtIndexPath(indexPath)
				if cell != nil then
					cell.accessoryType = UITableViewCellAccessoryCheckmark
				end
				root.radioSelected = @radioIdx
			end	
			super(dvc, tableView, indexPath)
		end
	end #class
	
	class CheckboxElement < StringElement
		
		def initialize(caption, value=nil, group=nil)
			super(caption)
			@val = value if !value.nil?
			@group = group if !group.nil?
		end
	
		def value
			@val
		end
		
		def value=(value)
			@val = value
		end
	
		def configCell(cell)
			cell.accessoryType = self.value ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
			cell
		end
	
		def getCell(tv)
			self.configCell(super(tv))
		end
	
		def selected(dvc, tableView, indexPath)
			self.value = !self.value
			cell = tableView.cellForRowAtIndexPath(indexPath)
			self.configCell(cell)
			super(dvc, tableView, indexPath)
		end
	end

	class ImageElement < Element
		@@ikey = "ImageElement"
		@@rect = nil
		# Apple leaks this one, so share across all.
		@@picker = nil
		# Height for rows
		DIMX = 48
		DIMY = 43
		# radius for rounding
		RAD = 10
		
		attr_accessor :value
		
		def self.makeEmpty()
			using(cs = CGColorSpaceCreateDeviceRGB()){
				bit = CGBitmapContextCreate(nil, DIMX, DIMY, 8, 0, cs, KCGImageAlphaPremultipliedFirst )
				CGContextSetRGBStrokeColor(bit, 1, 0, 0, 0.5)
				CGContextFillRect(bit, CGRectMake(0, 0, DIMX, DIMY))
				return UIImage.imageWithCGImage(CGBitmapContextCreateImage(bit))
			}
		end
	
		def scale(source)
			UIGraphicsBeginImageContext(CGSize.new(DIMX, DIMY))
			ctx = UIGraphicsGetCurrentContext()
			img = source.CGImage
			CGContextTranslateCTM(ctx, 0, DIMY)
			if CGImageGetWidth(img) > CGImageGetHeight(img) then
				CGContextScaleCTM(ctx, 1, - CGImageGetWidth(img) / DIMY)
			else
				CGContextScaleCTM(ctx, CGImageGetHeight(img) / DIMX, -1)
			end
			CGContextDrawImage(ctx, @@rect, source.CGImage)
			ret = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			ret
		end
	
		def initialize(image=nil)
			@@rect = CGRectMake(0, 0, DIMX, DIMY)
			
			if image.nil? then
				@value = self.class.makeEmpty()
				@scaled = @value
			else
				@value = image
				@scaled = self.scale(@value)
			end
		end
	
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(self.cellKey())
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: self.cellKey())
			end
			if @scaled.nil? then
				return cell
			end
			psection = self.parent
			roundTop = psection.elements[0] == self
			roundBottom = psection.elements[psection.elements.count - 1] == self
			
			using(cs = CGColorSpaceCreateDeviceRGB()){
				using(bit = CGBitmapContextCreate(nil, DIMX, DIMY, 8, 0, cs, KCGImageAlphaPremultipliedFirst)){
					# Clipping path for the image, different on top, middle and bottom.
					if roundBottom then
						CGContextAddArc(bit, RAD, RAD, RAD, Math::PI, (3 * Math::PI / 2), false)
					else
						CGContextMoveToPoint(bit, 0, RAD)
						CGContextAddLineToPoint(bit, 0, 0)
					end
					CGContextAddLineToPoint(bit, DIMX, 0)
					CGContextAddLineToPoint(bit, DIMX, DIMY)
					if roundTop then
						CGContextAddArc(bit, RAD, DIMY - RAD, RAD, (Math::PI/2), Math::PI, false )
						#bit.AddArc(@rad, @dimy - @rad, @rad, (Math.PI / 2), Math.PI, false)
						CGContextAddLineToPoint(bit, 0, RAD)
						#bit.AddLineToPoint(0, @rad)
					else
						CGContextAddLineToPoint(bit, 0, DIMY)
					end
					CGContextClip(bit)
					CGContextDrawImage(bit, @@rect, @scaled.CGImage)
					cell.imageView.image = UIImage.imageWithCGImage(CGBitmapContextCreateImage(bit))
				}
			}
			cell
		end
	
		class MyDelegate #implements UIImagePickerControllerDelegate protocol
			
			def initialize(container, table, path)
				@container = container
				@table = table
				@path = path
			end
			
			def imagePickerController(picker, didFinishPickingImage: image, editingInfo: editingInfo)
				#@container.picked(image)
				#@table.reloadRowsAtIndexPaths(Array.new([@path]), withRowAnimation: UITableViewRowAnimationNone)
			end
			
			def imagePickerController(picker, didFinishPickingMediaWithInfo: editingInfo)
				@container.picked(editingInfo["UIImagePickerControllerOriginalImage"])
				@table.reloadRowsAtIndexPaths(Array.new([@path]), withRowAnimation: UITableViewRowAnimationNone)
			end
			
			def imagePickerControllerDidCancel(picker)
				picker.dismissModalViewControllerAnimated true
			end
			
		end #class
	
		def picked(image)
			@value = image
			@scaled = self.scale(image)
			@currentController.dismissModalViewControllerAnimated(true)
		end
	
		def selected(dvc, tableView, path)
			if @@picker.nil? then
				@@picker = UIImagePickerController.new()
			end
			#@@picker.delegate = MyDelegate.new(self, tableView, path)
			@pdelegate = MyDelegate.new(self, tableView, path) #retain delegate to avoid EXC_BAD_ACCESS
			@@picker.delegate = @pdelegate
			
			#picker config
			@@picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum
			@@picker.dismissModalViewControllerAnimated(true)
					
			case UIDevice.currentDevice.userInterfaceIdiom
				when UIUserInterfaceIdiomPad
					@popover = UIPopoverController.alloc.initWithContentViewController(@@picker)
					cell = tableView.cellForRowAtIndexPath(path)
					if cell.nil? then
						useRect = @rect
					else
						@rect = cell.frame
					end
					@popover.presentPopoverFromRect(rect, inView: dvc.View, permittedArrowDirections: UIPopoverArrowDirectionAny, arrowDirections: true)
				else
					#when UIUserInterfaceIdiomPhone
					dvc.activateController(@@picker)
			end
			@currentController = dvc
		end 
		
		protected
		
		def cellKey
			@@ikey
		end
		
	end #class
	
	# An element that can be used to enter text.
	# This element can be used to enter text both regular and password protected entries.
	# The Text fields in a given section are aligned with each other.
	class EntryElement < Element
		@@entryKey = "EntryElement"
		@@cellkey = "EntryElement"
		@@font = nil

		# The value of the EntryElement
		def value
			if @entry.nil? then
				return @val
			end
			newValue = @entry.text
			if newValue == @val then
				return @val
			end
			@val = newValue
			@val
		end
	
		def value=(value)
			@val = value
			if @entry != nil then
				@entry.text = value
			end
		end
	
		# The key used for reusable UITableViewCells.
		def entryKey
			@@entryKey
		end
	
		# The type of keyboard used for input, you can change
		# this to use this for numeric input, email addressed,
		# urls, phones.
		def keyboardType
			@keyboardType
		end
	
		def keyboardType=(value)
			@keyboardType = value
			if @entry != nil then
				@entry.keyboardType = value
			end
		end
	
		# The type of Return Key that is displayed on the
		# keyboard, you can change this to use this for
		# Done, Return, Save, etc. keys on the keyboard
		def returnKeyType
			@returnKeyType
		end
	
		def returnKeyType=(value)
			@returnKeyType = value
			if @entry != nil && !@returnKeyType.nil? then
				@entry.returnKeyType = @returnKeyType
			end
		end
	
		def autocapitalizationType
			@autocapitalizationType
		end
	
		def autocapitalizationType=(value)
			@autocapitalizationType = value
			if @entry != nil then
				@entry.autocapitalizationType = value
			end
		end
	
		def autocorrectionType
			@autocorrectionType
		end
	
		def autocorrectionType=(value)
			@autocorrectionType = value
			if @entry != nil then
				@autocorrectionType = value
			end
		end
	
		def clearButtonMode
			@clearButtonMode
		end
	
		def clearButtonMode=(value)
			@clearButtonMode = value
			if @entry != nil then
				@entry.clearButtonMode = value
			end
		end
	
		def textAlignment
			@textalignment
		end
	
		def textAlignment=(value)
			@textalignment = value
			if @entry != nil then
				@entry.textAlignment = @textalignment
			end
		end
			
		# Constructs an EntryElement (for password entry) with the given caption, placeholder and initial value.
		def initialize(caption, placeholder, value, isPassword=false)
			super(caption)
			
			@keyboardType = UIKeyboardTypeDefault
			@returnKeyType = nil
			@autocapitalizationType = UITextAutocapitalizationTypeSentences
			@autocorrectionType = UITextAutocorrectionTypeDefault
			@clearButtonMode = UITextFieldViewModeNever
			@textalignment = UITextAlignmentLeft
			@@font = UIFont.boldSystemFontOfSize(17)
			
			self.value = value
			@placeholder = placeholder
			@isPassword = isPassword
			
		end
	
		def summary()
			self.value
		end

		# Computes the X position for the entry by aligning all the entries in the Section
		def computeEntryPosition(tv, cell)
			s = self.parent
			if !s.entryAlignment.nil? && s.entryAlignment.width != 0 then
				return s.entryAlignment
			end
			# If all EntryElements have a null Caption, align UITextField with the Caption
			# offset of normal cells (at 10px).
			max = CGSize.new(-15, "M".sizeWithFont(@@font).height)
			
			s.elements.each do |e|
				ee = e #as EntryElement
				if ee.nil? then
					next
				end
				if ee.caption != nil then
					size = ee.caption.sizeWithFont(@@font)
					if size.width > max.width then
						max = size
					end
				end
			end
			s.entryAlignment = CGSize.new(25 + [max.width, 160].min, max.height)
			s.entryAlignment
		end
		
		def createTextField(frame)
			UITextField.alloc.initWithFrame(frame).tap do |tf| 
				tf.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin
				tf.placeholder = @placeholder || ""
				tf.secureTextEntry = @isPassword
				tf.text = self.value || ""
				tf.tag = 1
				tf.textAlignment = @textalignment
				tf.clearButtonMode = @clearButtonMode
			end
		end
	
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(self.cellKey())
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:self.cellKey())
				cell.selectionStyle = UITableViewCellSelectionStyleNone
			else
				self.class.removeTag(cell, 1)
			end
			if @entry.nil? then
				size = self.computeEntryPosition(tv, cell)
				yOffset = (cell.contentView.bounds.size.height - size.height) / 2 - 1
				width = cell.contentView.bounds.size.width - size.width
				if @textalignment == UITextAlignmentRight then
					# Add padding if right aligned
					width -= 10
				end
				@entry = self.createTextField(CGRectMake(size.width, yOffset, width, size.height))
				
				@entry.delegate=self #delegate ended shouldReturn started
				
				@entry.addTarget(self, action:'fetchValue', forControlEvents:UIControlEventValueChanged)    #.valueChanged
				
			end
			
			if @becomeResponder then
				@entry.becomeFirstResponder()
				@becomeResponder = false
			end
			
			@entry.keyboardType = self.keyboardType
			@entry.autocapitalizationType = self.autocapitalizationType
			@entry.autocorrectionType = self.autocorrectionType
			cell.textLabel.text = self.caption
			cell.contentView.addSubview(@entry)
			cell
		end
	
		# UITextFieldDelegate Methods
		
		def textFieldDidEndEditing(textField)
			self.fetchValue()
		end
		
		def textFieldShouldReturn(textField)
			if @shouldReturn != nil then
				@shouldReturn
			end
			root = self.getImmediateRootElement()
			focus = nil #EntryElement
			
			if root.nil? then
				return true
			end
			
			root.sections.each do |s|
				s.elements.each do |e|
					if e == self then
						focus = self
					elsif focus != nil && e.kind_of?(EntryElement) then
						focus = e
						break
					end
				end
				
				if focus !=nil && focus != self then
					break
				end
			end
			
			if focus != self then
				focus.becomeFirstResponder(true)
			else
				focus.resignFirstResponder(true)
			end
			
			true
		end
		
		def textFieldDidBeginEditing(textField)
			this = nil
			
			if self.returnKeyType.nil? then
				returnType = UIReturnKeyDefault
				
				self.parent.elements.each do |e|
					if e == self then
						this = self
					elsif this != nil && e.kind_of?(EntryElement) then
						returnType = UIReturnKeyNext
					end
				end
				@entry.returnKeyType = returnType
			else
				@entry.returnKeyType = self.returnKeyType
			end
			tv = self.getContainerTableView()
			tv.scrollToRowAtIndexPath(self.indexPath(), atScrollPosition:UITableViewScrollPositionMiddle, animated:true)
		end

		# Copies the value from the UITextField in the EntryElement to the
		# Value property and raises the Changed event if necessary.
		def fetchValue()
			if @entry.nil? then
				return 
			end
			newValue = @entry.text
			if newValue == self.value then
				return
			end
			self.value = newValue
		end
	
		def selected(dvc, tableView, indexPath)
			self.becomeFirstResponder true
			tableView.deselectRowAtIndexPath(indexPath, animated:true)
		end
		
		def matches(text)
			(self.value != nil ? self.value.downcase().index(text.downcase()) != -1 : false) || super.matches(text)
		end
		
		# Makes this cell the first responder (get the focus)
		def becomeFirstResponder(animated)
			@becomeResponder = true
			tv = self.getContainerTableView()
			if tv.nil? then
				return 
			end
			tv.scrollToRowAtIndexPath(self.indexPath(), atScrollPosition:UITableViewScrollPositionMiddle, animated:animated)
			if @entry != nil then
				@entry.becomeFirstResponder()
				@becomeResponder = false
			end
		end
	
		def resignFirstResponder(animated)
			@becomeResponder = false
			tv = self.getContainerTableView()
			if tv.nil? then
				return 
			end
			tv.scrollToRowAtIndexPath(self.indexPath(), atScrollPosition:UITableViewScrollPositionMiddle, animated:animated)
			if @entry != nil then
				@entry.resignFirstResponder()
			end
		end
		
		protected
		
		def cellKey
			@@cellkey
		end
		
	end #class
	
	class DateTimeElement < StringElement
				
		attr_accessor :dateValue, :datePicker, :dateSelected, :fmt
	
		def initialize(caption, date)
			super(caption)
			@fmt = NSDateFormatter.alloc.init.tap{|df| df.dateStyle = NSDateFormatterShortStyle}
			@dateValue = date
			self.value = self.formatDate(date)
		end
	
		def getCell(tv)
			self.value = self.formatDate(@dateValue)
			cell = super(tv)
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
			cell
		end
	
		def getDateWithKind(dt)
			if !dt.gmt? && !dt.utc? then
				return dt.getlocal
			end
			dt
		end
	
		def formatDate(dt)
			dt = self.getDateWithKind(dt)
			@fmt.stringFromDate(dt) + " " + dt.localtime().strftime("%m/%d/%Y")
		end
	
		def createPicker()
			picker = UIDatePicker.alloc.init.tap do |dp|
				dp.autoresizingMask = UIViewAutoresizingFlexibleWidth
				dp.datePickerMode = UIDatePickerModeDateAndTime
				dp.date = @dateValue
			end
			picker
		end
	
		def self.pickerFrameWithSize(size)
			screenRect = UIScreen.mainScreen.applicationFrame
			fY, fX = 0,0
			case UIApplication.sharedApplication.statusBarOrientation
				when UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight then
					fX = (screenRect.size.height - size.width) / 2
					fY = (screenRect.size.width - size.height) / 2 - 17
				when UIInterfaceOrientationPortrait || UIInterfaceOrientationPortraitUpsideDown then
					fX = (screenRect.size.width - size.width) / 2
					fY = (screenRect.size.height - size.height) / 2 - 25
			end
			CGRectMake(fX, fY, size.width, size.height)
		end
	
		class MyViewController < UIViewController
			
			attr_accessor :autorotate
			
			def initialize(container)
				@container = container
			end
	
			def viewWillDisappear(animated)
				super(animated)
				@container.dateValue = @container.datePicker.date
				if @container.dateSelected != nil then
					@container.dateSelected(@container)
				end
			end
	
			def didRotate(fromInterfaceOrientation)
				super(fromInterfaceOrientation)
				@container.datePicker.frame = self.pickerFrameWithSize(@container.datePicker.sizeThatFits(CGRect.new))
			end
	
			def shouldAutorotateToInterfaceOrientation(toInterfaceOrientation)
				self.autorotate
			end
		end
	
		def selected(dvc, tableView, path)
			vc = MyViewController.new(self).tap do |mvc|
				mvc.autorotate = dvc.autorotate
			end
			@datePicker = self.createPicker()
			@datePicker.frame = self.class.pickerFrameWithSize(datePicker.sizeThatFits(CGSize.new))
			vc.view.backgroundColor = UIColor.blackColor
			vc.view.addSubview(datePicker)
			dvc.activateController(vc)
		end
		
		protected :fmt
		
	end
	
	class DateElement < DateTimeElement
		def initialize(caption, date)
			super(caption, date)
			fmt.dateStyle = NSDateFormatterMediumStyle
		end
	
		def formatDate(dt)
			fmt.stringFromDate(self.getDateWithKind(dt))
		end
	
		def createPicker()
			picker = super()
			picker.datePickerMode = UIDatePickerModeDate
			picker
		end
	end #class
	
	class TimeElement < DateTimeElement
		def initialize(caption, date)
			super(caption, date)
		end
	
		def formatDate(dt)
			self.getDateWithKind(dt).localtime().strftime("%I:%M %p")
		end
	
		def createPicker()
			picker = super()
			picker.datePickerMode = UIDatePickerModeTime
			picker
		end
	end #class
	
	#UIViewElement < Element
	
	# Sections contain individual Element instances that are rendered by MtionDialog
	# 
	# Sections are used to group elements in the screen and they are the
	# only valid direct child of the RootElement.    Sections can contain
	# any of the standard elements, including new RootElements.
	# 
	# RootElements embedded in a section are used to navigate to a new
	# deeper level.
	# 
	# You can assign a header and a footer either as strings (Header and Footer)
	# properties, or as UIViews to be shown (HeaderView and FooterView).   Internally
	# this uses the same storage, so you can only show one or the other.
	class Section < Element #, IEnumerable
		# X corresponds to the alignment, Y to the height of the password
		#@entryAlignment #CGSize
	
		attr_accessor :elements, :entryAlignment
		
		# Constructs a Section with or without header and footer
		def initialize(header=nil, footer=nil)
		    @elements = []
			if header.nil? && footer.nil? then
				super(nil)
			elsif !header.nil? && footer.nil? then
				if header.instance_of? String then
					super(header)
				elsif header.instance_of? UIView then
					super(nil)
					self.headerView=header
				end
			elsif !header.nil? && !footer.nil? then
				if footer.instance_of?(String) && header.instance_of?(String) then
					super(header)
					self.footer = footer
				elsif footer.instance_of?(UIView) && header.instance_of?(UIView) then
					super(nil)
					self.headerView=header
					self.footerView=footer
				end
			end
		end
		
		# The section header, as a string
		def header
			if @header.is_a?(String) then 
				return @header
			else
				return nil
			end
		end
	
		def header=(value)
			@header = value
		end
	
		# The section footer, as a string.
		def footer
			if @footer.is_a?(String) then 
				return @footer
			else
				return nil
			end
		end
	
		def footer=(value)
			@footer = value
		end
	
		# The section's header view.
		def headerView
			if @header.is_a?(UIView) then 
				return @header
			else
				return nil
			end
		end
	
		def headerView=(value)
			@header = value
		end
	
		# The section's footer view.
		def footerView
			if @footer.is_a?(UIView) then 
				return @footer
			else
				return nil
			end
		end
	
		def footerView=(value)
			@footer = value
		end
		
		# Adds one or more new child Elements to the Section
		def add(arg)
			if arg.nil? then
				return
			end
			if arg.kind_of?(Element) then
				@elements<<arg
				arg.parent=self
				self.insertVisual(@elements.count-1, UITableViewRowAnimationNone, 1) if !self.parent.nil?  
			elsif arg.kind_of?(UIView) then
				self.add(UIViewElement.new(nil, arg, false))
			elsif arg.kind_of?(Array) then
				arg.each do |e|
					if e.kind_of?(UIView) then
						# Use to add a UIView to a section, it makes the section opaque, to
						# get a transparent one, you must manually call UIViewElement
						self.add(UIViewElement.new(nil, arg, false))
					elsif e.kind_of?(Element) then
						addAll(arg)
						break
					end
				end
			end
			puts "  @elements:#{@elements.count}"
		end
	
		alias :<< :add
		
		def addAll(elements)
			count = 0
			elements.each do |e|
				add(e)
				count += 1
			end
			count
		end
		
		# Inserts a series of elements into the Section using the specified animation
		# idx: The index where the elements are inserted
		# anim: The animation to use
		# newElements: A series of elements.
		def insert(idx, anim=UITableViewRowAnimationNone, newElements)
			if newElements.nil? then
				return
			end
			pos = idx
			count = 0
			newElements = [*newElements]
			newElements.each do |e|
				@elements.insert(pos, e)
				pos += 1
				e.parent = self
				count += 1
			end
			root = self.parent
			if parent != nil and root.tableView != nil then
				if anim == UITableViewRowAnimationNone then
					root.tableView.reloadData()
				else
					self.insertVisual(idx, anim, newElements.length)
				end
			end
			count
		end
	
		def insertVisual(idx, anim, count)
			root = self.parent
			if root.nil? or root.tableView.nil? then
				return
			end
			sidx = root.indexOf(self)
			paths = Array.new(count) #NSIndexPath [count];			
			i = 0
			while i < count
				paths[i] = NSIndexPath.indexPathForRow(idx + i, inSection:sidx)
				i += 1
			end
			root.tableView.insertRowsAtIndexPaths(paths, withRowAnimation:anim)
		end
	
		def remove(it)
			if it.nil? then
				return 
			end
			if it.kind_of?(Element) then
				i = @elements.count
				while i > 0
					i -= 1
					if @elements[i] == it then
						self.removeRange(i, 1)
						return 
					end
				end
			else
				self.removeRange(it, 1)
			end
		end
	
		# Remove a range of elements from the section with the given animation
		def removeRange(start, count, anim=UITableViewRowAnimationFade)
			if start < 0 or start >= @elements.count then
				return 
			end
			if count == 0 then
				return 
			end
			root = self.parent if self.parent.kind_of?(RootElement)
			if start + count > @elements.count then
				count = @elements.count - start
			end
			@elements.slice!(start..(start+count-1)) #removeRange(start, count)
			if root.nil? or root.tableView.nil? then
				return 
			end
			sidx = root.indexOf(self)
			paths = Array.new(count)
			i = 0
			while i < count
				paths[i] = NSIndexPath.indexPathForRow(start + i, inSection:sidx)
				i += 1
			end
			root.tableView.deleteRowsAtIndexPaths(paths, withRowAnimation:anim)
		end
	
		def count
			@elements.count
		end
	
		def [](idx)
			@elements[idx]
		end
	
		def clear()
			if @elements != nil then
				@elements.each do |e|
					e = nil
				end
			end
			@elements = Array.new()
			root = self.parent
			if root != nil and root.fableView != nil then
				root.tableView.reloadData()
			end
		end
			
		def getCell(tv)
			cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"")
			cell.textLabel.text = "Section was used for Element"
			return cell
		end
	end
	
	# Used by root elements to fetch information when they need to
	# render a summary (Checkbox count or selected radio group).
	class Group
		@key
		attr_accessor :key	
		def initialize(key)
			@key = key
		end
	end

	# Captures the information about mutually exclusive elements in a RootElement
	class RadioGroup < Group
		@selected
		
		def selected
			@selected
		end
	
		def selected=(value)
			@selected = value
		end
	
		def initialize(key=nil, selected)
			super(key)
			@selected = selected
		end
	
	end
	
	# RootElements are responsible for showing a full configuration page.
	# At least one RootElement is required to start the MotionDialogs
	# process.
	# 
	# RootElements can also be used inside Sections to trigger
	# loading a new nested configuration page.   When used in this mode
	# the caption provided is used while rendered inside a section and
	# is also used as the Title for the subpage.
	# 
	# If a RootElement is initialized with a section/element value then
	# this value is used to locate a child Element that will provide
	# a summary of the configuration which is rendered on the right-side
	# of the display.
	# 
	# RootElements are also used to coordinate radio elements.  The
	# RadioElement members can span multiple Sections (for example to
	# implement something similar to the ring tone selector and separate
	# custom ring tones from system ringtones).
	# 
	# Sections are added by calling the Add method
	class RootElement < Element 
		@@rkey1 = "RootElement1"  
		@@rkey2 = "RootElement2" 
						
		# @needColorUpdate is used to indicate that we need the DVC to dispatch calls to
		# WillDisplayCell so we can prepare the color of the cell before 
		# display
		
		attr_accessor :tableView, :sections, :unevenRows, :needColorUpdate, :group
		
		# Initializes a RootSection with a caption
		#def initialize(caption)
			
		# Initializes a RootSection with a caption and a callback that will
		# create the nested UIViewController that is activated when the user
		# taps on the element.
		#def initialize(caption, createOnSelected)
		
		# Initializes a RootElement with a caption with a summary fetched from the specified section and element
		# The caption to render cref="System.String"/>
		# The section that contains the element with the summary.
		# The element index inside the section that contains the summary for this RootSection.
		#def initialize(caption, section, element)
		
		# Initializes a RootElement that renders the summary based on the radio settings of the contained elements.
		# The group that contains the checkbox or radio information.  This is used to display
		# the summary information when a RootElement is rendered inside a section.
		#def initialize(caption, group)
		
		def initialize(caption, arg=nil, element=nil)
			super(caption)
			@sections = []
			@unevenRows = false
			@needColorUpdate = false
			if arg.nil? && element.nil? then
				@summarySection = -1;
			elsif arg.kind_of?(Proc) && element.nil? then
				@summarySection = -1;
				@createOnSelected = arg
			elsif arg.kind_of?(Group) && element.nil? then
				@group = arg
			elsif arg.kind_of?(Integer) && !element.nil? then
				@summarySection = arg
				@summaryElement = element
			end
		end
				
		def pathForRadio(idx)
			radio = @group
			if radio.nil? then
				return nil
			end
			current, section = 0, 0
			
			@sections.each do |s|
				row = 0
				s.elements.each do |e|
					if !e.kind_of?(RadioElement) then
						next
					end
					if current == idx then
						return NSIndexPath.indexPathForRow(row, inSection:section)
					end
					row += 1
					current += 1
				end
				section += 1
			end
			nil
		end
	
		def count
			@sections.count
		end
		
		def [](idx)
			@sections[idx]
		end
	
		def indexOf(target)
			idx = 0
			@sections.each do |s|
				if s == target then
					return idx
				end
				idx += 1
			end
			return -1
		end
	
		def prepare()
			current = 0
			@sections.each do |s|
				s.elements.each do |e|
					re = e if e.kind_of?(RadioElement)				
					if !re.nil? then
						re.radioIdx = current
						current += 1
					end
					
					if (!@unevenRows && e.respond_to?(:getHeight)) then
						@unevenRows = true
					#else
					#	@unevenRows = false
					end
					
					puts "  @needColorUpdate:#@needColorUpdate #{ e.respond_to?(:willDisplay) } "
					puts "  #{e} " if e.respond_to?(:willDisplay)
					
					if (!@needColorUpdate && e.respond_to?(:willDisplay)) then
						@needColorUpdate = true
					else
						@needColorUpdate = false
					end
				end
			end
		end
		
		# Adds one or more new sections to this RootElement
		def add(sec)
			if sec.nil? then
				return
			end
			if sec.kind_of?(Section) then
				@sections<<sec
				sec.parent = self
				if @tableView.nil? then
					return 
				end
				@tableView.insertSections(self.makeIndexSet(@sections.count - 1, 1), UITableViewRowAnimationNone)
			elsif sec.kind_of?(Array) then
				sec.each do |s|
					self.add(s)
				end
			end
		end
		
		def makeIndexSet(start, count)
			range = NSRange.new
			range.location = start
			range.length = count
			NSIndexSet.indexSetWithIndexesInRange(range)
		end
	
		# Inserts a new section into the RootElement
		# idx: The index where the section is added 
		# anim: The UITableViewRowAnimation type.
		# newSections: A list of sections to insert
		# This inserts the specified list of sections (a params argument) into the
		# root using the specified animation.
		def insert(idx, anim = UITableViewRowAnimationNone, newSections)
			if idx < 0 or idx > @sections.count then
				return 
			end
			if newSections.nil? then
				return 
			end
			newSections = [*newSections]
			if @tableView != nil then
				@tableView.beginUpdates()
			end
			pos = idx
			newSections.each do |s|
				s.parent = self
				@sections.insert(pos, s)
				pos += 1
			end
			if @tableView.nil? then
				return 
			end
			@tableView.insertSections(self.makeIndexSet(idx, newSections.length), withRowAnimation:anim)
			@tableView.endUpdates()
		end
	
		# Removes a section at a specified location using the specified animation
		def removeAt(idx, anim = UITableViewRowAnimationFade)
			if idx < 0 or idx >= @sections.count then
				return 
			end
			@sections.delete_at(idx)
			if @tableView.nil? then
				return 
			end
			@tableView.deleteSections(NSIndexSet.indexSetWithIndex(idx), withRowAnimation: anim)
		end
	
		def remove(s, anim = UITableViewRowAnimationFade)
			if s.nil? then
				return 
			end
			idx = @sections.index(s)
			if idx == -1 then
				return 
			end
			self.removeAt(idx, anim)
		end
	
		def clear()
			@sections.each do |s|
				s = nil
			end
			@sections = Array.new()
			if @tableView != nil then
				@tableView.reloadData()
			end
		end
	
		# The currently selected Radio item in the whole Root.
		def radioSelected
			radio = @group if @group.kind_of?(RadioGroup)
			if radio != nil then
				return radio.selected
			end
			return -1
		end
	
		def radioSelected=(value)
			radio = @group if @group.kind_of?(RadioGroup)
			if radio != nil then
				radio.selected = value
			end
		end
	
		def getCell(tv)
			key = @summarySection == -1 ? @rkey1 : @rkey2
			cell = tv.dequeueReusableCellWithIdentifier(key)
			if cell.nil? then
				style = @summarySection == -1 ? UITableViewCellStyleDefault : UITableViewCellStyleValue1
				cell = UITableViewCell.alloc.initWithStyle(style, reuseIdentifier:key)
				cell.selectionStyle = UITableViewCellSelectionStyleBlue
			end
			cell.textLabel.text = self.caption
			radio = @group if @group.kind_of?(RadioGroup) #as RadioGroup
			if radio != nil then
				selected = radio.selected
				current = 0
				
				@sections.each do |s|
					s.elements.each do |e|
						if !e.kind_of?(RadioElement) then
							next
						end
						if current == selected then
							cell.detailTextLabel.text = e.summary()
						end
						current += 1
					end
				end
				
			elsif @group != nil then
				count = 0
				@sections.each do |s|
					s.elements.each do |e|
						ce = e if e.kind_of?(CheckboxElement) #as CheckboxElement
						if ce != nil then
							if ce.value then
								count += 1
							end
							next
						end
						be = e if e.kind_of?(BoolElement) #as BoolElement
						if be != nil then
							if be.value then
								count += 1
							end
							next
						end
					end
				end
				cell.detailTextLabel.text = count.to_s()
			elsif @summarySection != -1 and @summarySection < @sections.count then
				s = @sections[@summarySection]
				if @summaryElement < s.elements.count and cell.detailTextLabel != nil then
					cell.detailTextLabel.text = s.elements[@summaryElement].summary()
				end
			end
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
			cell
		end
	
		# This method does nothing by default, but gives a chance to subclasses to
		# customize the UIViewController before it is presented
		def prepareDialogViewController(dvc)
		end
	
		# Creates the UIViewController that will be pushed by this RootElement
		def makeViewController()
			if @createOnSelected != nil then
				return self.createOnSelected(self)
			end
			DialogViewController.alloc.init.tap{|dvc| 
				dvc.root = self
				dvc.pushing = true
			    dvc.autorotate = true
			}
		end

		def selected(dvc, tableView, indexPath)			
			ip = Pointer.new(:uint)
			indexPath.getIndexes(ip)
			#puts "#{ip.length}"
			
			begin
				#tableView.deleteRowsAtIndexPaths(indexPath, withRowAnimation:false) #=>RuntimeError: NSInvalidArgumentException: -[NSIndexPath count]: unrecognized selector sent to instance
				newDvc = self.makeViewController()
				self.prepareDialogViewController(newDvc)
				dvc.activateController(newDvc)
			rescue => ex
				puts "#{ex.class}: #{ex.message}"
			end
		end
	
		def reload(object, animation)
			if object.nil? then
				raise ArgumentError, "element or section is nil"
			elsif object.kind_of?(Section) then 
				section = object
				if section.parent.nil? or section.parent != self then
					raise ArgumentError, "Section is not attached to this root"
				end
				idx = 0
				@sections.each do |sect|
					if sect == section then
						@tableView.reloadSections(NSIndexSet.indexSetWithIndex(idx), animation)
						return 
					end
					idx += 1
				end
			elsif object.kind_of?(Element) then
				element = object
				section = element.parent
				if section.nil? then
					raise ArgumentError, "Element is not attached to this root"
				end
				root = section.parent
				if root.nil? then
					raise ArgumentError, "Element is not attached to this root"
				end
				path = element.indexPath
				if path.nil? then
					return 
				end
				@tableView.reloadRowsAtIndexPaths(Array.new([path]), withRowAnimation:animation)
			end
		end
		
	end #class
	
end #module

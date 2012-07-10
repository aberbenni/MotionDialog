
# element_badge.rb: defines the Badge Element.
#
# Author:: Alessandro Berbenni (mailto:aberbenni@gmail.com)
# Copyright:: Copyright (c) 2012 Alessandro Berbenni
# License::   This code is licensed under the terms of the MIT X11 license
#       
# Code based on Miguel de Icaza's MonoTouch.Dialog.BadgeElement

#require "mscorlib"
#require "System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "System.Collections, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "System.Collections.Generic, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "MonoTouch.UIKit, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "MonoTouch.CoreGraphics, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#require "MonoTouch.Foundation, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

module MotionDialog
	# This element can be used to show an image with some text

	# The font can be configured after the element has been created
	# by assignign to the Font property;   If you want to render
	# multiple lines of text, set the MultiLine property to true.
	# 
	# If no font is specified, it will default to Helvetica 17.
	# 
	# A static method MakeCalendarBadge is provided that can
	# render a calendar badge like the iPhone OS.   It will compose
	# the text on top of the image which is expected to be 57x57
	class BadgeElement < Element #, IElementSizing
		@@ckey = "badgeKey"
		
		attr_accessor :lineBreakMode, :contentMode, :lines, :accessory
		
		def initialize(badgeImage, cellText, tapped=nil)
			super(cellText)
			@lineBreakMode = UILineBreakModeTailTruncation
			@contentMode = UIViewContentModeLeft
			@lines = 1
			@accessory = UITableViewCellAccessoryNone
			
			if badgeImage.nil? then
				raise ArgumentError, "badgeImage cannot be nil"
			end
			@image = badgeImage
			if tapped != nil then
				@tapped += tapped
			end
		end

		def font
			if @font.nil? then
				@font = UIFont.fontWithName("Helvetica", size: 17.0)
			end
			@font
		end

		def font=(value)
			@font = value
		end

		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(@@ckey)
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: @ckey).tap{|c| 
					c.selectionStyle = UITableViewCellSelectionStyleBlue}
			end
			cell.accessoryType = @accessory
			tl = cell.textLabel
			tl.Text = caption
			tl.font = self.font
			tl.lineBreakMode = @lineBreakMode
			tl.numberOfLines = @lines
			tl.contentMode = @contentMode
			cell.imageView.image = @image
			cell
		end

		def getHeight(tableView, indexPath)
			size = CGSize.new(tableView.bounds.size.width - 40, Float::MAX) #3.402823e38
			height = caption.sizeWithFont(self.font, forWidth: size.width, lineBreakMode: @lineBreakMode).height + 10
			# Image is 57 pixels tall, add some padding
			[height, 63].max
		end

		def selected(dvc, tableView, path)
			if @tapped != nil then
				@tapped.call()
			end
			tableView.deselectRowAtIndexPath(path, animated: true)
		end

		def self.makeCalendarBadge(template, smallText, bigText)
			puts "#{self.class.to_s}.makeCalendarBadge(#{template}, #{smallText}, #{bigText})"
			puts "  #{CGColorSpaceCreateDeviceRGB()}"
			using(cs = CGColorSpaceCreateDeviceRGB()){
				puts "  #{cs}"
				using(context = CGBitmapContextCreate(nil, 57, 57, 8, 57 * 4, cs, KCGImageAlphaPremultipliedLast)){ #Pointer.new("@")
					#context.scaleCTM (0.5f, -1);
					CGContextTranslateCTM(context, 0, 0) #context.translateCTM(0, 0)
					CGContextDrawImage(context, CGRectMake(0, 0, 57, 57), template.CGImage) #context.drawImage(RectangleF.new(0, 0, 57, 57), template.CGImage)
					CGContextSetRGBFillColor(context, 1, 1, 1, 1) #context.setRGBFillColor(1, 1, 1, 1)
					CGContextSelectFont(context, "Helvetica", 10.0, KCGEncodingMacRoman) #context.selectFont("Helvetica", 10.0, CGTextEncoding.MacRoman)
					# Pretty lame way of measuring strings, as documented:
					start = CGContextGetTextPosition(context).x #context.textPosition.x
					CGContextSetTextDrawingMode(context, KCGTextInvisible) #context.setTextDrawingMode(CGTextDrawingMode.Invisible)
					CGContextShowText(context, smallText, smallText.length) #context.showText(smallText)
					puts "  start:#{start}"
					puts "  #{CGContextGetTextPosition(context).x}"
					width = CGContextGetTextPosition(context).x
					puts "  width:#{width}"
					puts "  #{width-start}"
					width = (CGContextGetTextPosition(context).x - start) #context.TextPosition.X - start
					CGContextSetTextDrawingMode(context, KCGTextFill) #context.SetTextDrawingMode(CGTextDrawingMode.Fill)
					CGContextShowTextAtPoint(context, (57 - width) / 2, 46, smallText, smallText.length) #context.ShowTextAtPoint((57 - width) / 2, 46, smallText)
					# The big string
					CGContextSelectFont(context, "Helvetica-Bold", 32, KCGEncodingMacRoman) #context.SelectFont("Helvetica-Bold", 32, CGTextEncoding.MacRoman)
					start = CGContextGetTextPosition(context).x #start = context.TextPosition.X
					CGContextSetTextDrawingMode(context, KCGTextInvisible) #context.SetTextDrawingMode(CGTextDrawingMode.Invisible)
					CGContextShowText(context, bigText, bigText.length) #context.ShowText(bigText)
					width = (CGContextGetTextPosition(context).x - start) #context.TextPosition.X - start
					CGContextSetRGBFillColor(context, 0, 0, 0, 1)  #context.SetRGBFillColor(0, 0, 0, 1)
					CGContextSetTextDrawingMode(context, KCGTextFill)  #context.SetTextDrawingMode(CGTextDrawingMode.Fill)
					CGContextShowTextAtPoint(context, (57 - width) / 2, 9, bigText, bigText.length)  #context.ShowTextAtPoint((57 - width) / 2, 9, bigText)
					CGContextStrokePath(context)  #context.StrokePath()
					
					UIImage.imageWithCGImage(CGBitmapContextCreateImage(context)) #context.ToImage()
				}
			}
		end
		
	end #class
	
end #module
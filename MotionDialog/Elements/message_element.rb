module MotionDialog
	
	class MessageSummaryView < UIView
		@@senderFont = nil
		@@subjectFont = nil
		@@textFont = nil
		@@countFont = nil
		@@gradient = nil
		@@colors = []
		@@padright = 21
		
		
		attr_accessor :sender, :body, :subject, :date, :newFlag, :messageCount  
	
			using(colorspace = CGColorSpaceCreateDeviceRGB()){
				
				c1 = Pointer.new('f',4)
				c1[0] = 0.52
				c1[1] = 0.69
				c1[2] = 0.96
				c1[3] = 1.0
				
				c2 = Pointer.new('f',4)
				c2[0] = 0.12
				c2[1] = 0.31
				c2[2] = 0.67
				c2[3] = 1.0
				
				@@colors[0] = CGColorCreate(colorspace, c1)
				@@colors[1] = CGColorCreate(colorspace, c2)
				
				@@gradient = CGGradientCreateWithColors(colorspace, @@colors, nil)
			}

		def init
			super
			self.send(:initialize)
			self
		end

		def initialize()
			@@senderFont = UIFont.boldSystemFontOfSize(19)
			@@subjectFont = UIFont.systemFontOfSize(14)
			@@textFont = UIFont.systemFontOfSize(13)
			@@countFont = UIFont.boldSystemFontOfSize(13)
			self.backgroundColor = UIColor.whiteColor
		end

		def update(sender, body, subject, date, newFlag, messageCount)
			self.sender = sender
			self.body = body
			self.subject = subject
			self.date = date
			self.newFlag = newFlag
			self.messageCount = messageCount
			self.setNeedsDisplay()
		end

		def drawRect(rect)
			ctx = UIGraphicsGetCurrentContext()
					
			# Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
			#CGContextTranslateCTM(ctx, 0, rect.size.height)
			#CGContextScaleCTM(ctx, 1.0, -1.0)
				
			if self.messageCount > 0 then
				ms = self.messageCount.to_s
				ssize = ms.sizeWithFont(@@countFont)
				boxWidth = [22 + ssize.width, 18].min
				crect = CGRectMake(bounds.size.width - 20 - boxWidth, 32, boxWidth, 16)
				
				#UIColor.grayColor.setFill()
				CGContextSetFillColorWithColor(ctx, UIColor.grayColor.CGColor)
				
				GraphicsUtil.fillRoundedRect(ctx, crect, 3)
				
				#UIColor.whiteColor.set()
				CGContextSetFillColorWithColor(ctx, UIColor.whiteColor.CGColor)

				crect.origin.x +=5
				ms.drawInRect(crect, withFont: @@countFont)
				boxWidth += @@padright
			else
				boxWidth = 0
			end
			
			#UIColor.colorWithRed(36, green: 112, blue: 216, alpha:1).set() #blue x etichetta data
			#CGContextSetRGBFillColor(ctx, 36.0, 112.0, 216.0, 1.0)			
			CGContextSetFillColorWithColor(ctx, UIColor.blueColor.CGColor)
			
			diff = Time.now - self.date
			if Time.now.day == self.date.day then
				label = self.date.strftime("%c")
			elsif diff <= (24*60*60) then
				label = "Yesterday"
			elsif diff < (6*24*60*60) then
				label = self.date.strftime("%x")
			else
				label = self.date.strftime("%x")
			end
			ssize = label.sizeWithFont(@@subjectFont)
			dateSize = ssize.width + @@padright + 5
			
			lrect = CGRectMake(self.bounds.size.width - dateSize, 6, dateSize, 14)
			label.drawInRect(lrect, withFont: @@subjectFont, lineBreakMode: UILineBreakModeClip, alignment: UITextAlignmentLeft)
			
			offset = 33
			bw = self.bounds.size.width - offset

			#UIColor.blackColor.set()
			CGContextSetFillColorWithColor(ctx, UIColor.blackColor.CGColor)
			CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor.CGColor)
			 
			self.sender.drawAtPoint(CGPoint.new(offset,  2), forWidth: bw - dateSize, withFont: @@senderFont, lineBreakMode: UILineBreakModeTailTruncation)
			self.subject.drawAtPoint(CGPoint.new(offset, 23), forWidth: bw - offset - boxWidth, withFont: @@subjectFont, lineBreakMode: UILineBreakModeTailTruncation)
		
			#UIColor.grayColor.set()
			CGContextSetFillColorWithColor(ctx, UIColor.grayColor.CGColor)
			CGContextSetStrokeColorWithColor(ctx, UIColor.grayColor.CGColor)
			
			self.body.drawInRect(CGRectMake(offset, 40, bw - boxWidth, 34), withFont: @@textFont, lineBreakMode: UILineBreakModeTailTruncation, alignment: UITextAlignmentLeft)
			
			if self.newFlag then
				CGContextSaveGState(ctx)
				CGContextAddEllipseInRect(ctx, CGRectMake(10, 32, 12, 12))
				CGContextClip(ctx)
				
				#CGContextSetFillColorWithColor(ctx, UIColor.redColor.CGColor)
				#CGContextFillRect(ctx, self.bounds)
				
				CGContextDrawLinearGradient(ctx, @@gradient, CGPoint.new(10, 32), CGPoint.new(22, 44),  KCGGradientDrawsAfterEndLocation)
				CGContextRestoreGState(ctx)
				
				#CGGradientRelease(@@gradient);
				#CGColorSpaceRelease(colorSpace);
			end
=begin				
			#CGContextSaveGState(ctx)
			#UIColor.colorWithRed(78, green: 122, blue: 198, alpha: 1).set()
			#CGContextSetShadow(ctx, CGSize.new(1, 1), 3.0)
			#CGContextStrokeEllipseInRect(ctx, CGRectMake(10, 32, 12, 12))
			#CGContextRestoreGState(ctx)
=end			
		end
	end #class
	
	class MessageElement < Element
		@@mKey = "MessageElement"
		
		#class<<self; attr_reader :mKey end
		
		attr_accessor :sender, :body, :subject, :date, :newFlag, :messageCount
		
		class MessageCell < UITableViewCell
		
			def initWithStyle(style, reuseIdentifier:reuseIdentifier)
				super(style, reuseIdentifier: reuseIdentifier)
			end
			
			def init(*args)
				super(args)
				self.send(:initialize, args)
			end
		
			def initialize(reuseIdentifier)
				self.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: reuseIdentifier)
				@view = MessageSummaryView.new()
				self.contentView.addSubview(@view)
				self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
			end

			def update(me)
				@view.update(me.sender, me.body, me.subject, me.date, me.newFlag, me.messageCount)
			end

			def layoutSubviews()
				super()
				@view.frame = self.contentView.bounds
				@view.setNeedsDisplay()
			end
			
		end #class
		
		def initialize(tapped=nil)
			super("")
			if !tapped.nil? then
				@tapped = tapped
			end
		end
		
		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(@@mKey)
			if cell.nil? then
				cell = MessageCell.new(@@mKey)
			end
			cell.update(self)
			cell
		end

		def getHeight(tableView, indexPath)
			78
		end

		def selected(dvc, tableView, path)
			if @tapped != nil then
				@tapped.call(dvc, tableView, path)
			end
		end
		
	end #class
	
end #module

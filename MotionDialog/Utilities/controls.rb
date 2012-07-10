
module MotionDialog

	module RefreshViewStatus
		ReleaseToReload = 1
		PullToReload = 2
		Loading = 3
	end
	
	class RefreshTableHeaderView < UIView
		@@arrow = nil
		
		attr_accessor :isFlipped
		
		alias flipped? isFlipped
		
		def initWithFrame(frame)
			super(frame)
		end

		def initialize(rect)
			self.initWithFrame(rect)
			@@arrow = UIImage.imageWithContentsOfFile("arrow.png")
			@status = -1
			@autoresizingMask = UIViewAutoresizingFlexibleWidth
			@backgroundColor = UIColor.colorWithRed(0.88, green:0.90, blue:0.92, alpha:1)
			createViews()
		end
	
		def createViews()
			@lastUpdateLabel = UILabel.alloc.init.tap{|ul|
				ul.font = UIFont.systemFontOfSize 13.0
				ul.textColor = UIColor.colorWithRed(0.47, green:0.50, blue:0.57, alpha:1)
				ul.shadowColor = UIColor.whiteColor() 
				ul.shadowOffset = CGSize.new(0, 1)
				ul.backgroundColor = @backgroundColor
				ul.opaque = true
				ul.textAlignment = UITextAlignmentCenter
				ul.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
			}
			addSubview(@lastUpdateLabel)
			@statusLabel = UILabel.alloc.init.tap{|sl|
				sl.font = UIFont.boldSystemFontOfSize 14.0
				sl.textColor = UIColor.colorWithRed(0.47, green:0.50, blue:0.57, alpha:1)
				sl.shadowColor = @lastUpdateLabel.shadowColor 
				sl.shadowOffset = CGSize.new(0, 1)
				sl.backgroundColor = @backgroundColor
				sl.opaque = true
				sl.textAlignment = UITextAlignmentCenter
				sl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
			}
			addSubview(@statusLabel)
			setStatus(RefreshViewStatus::PullToReload)
			@arrowView = UIImageView.alloc.init.tap{|av|
				av.contentMode = UIViewContentModeScaleAspectFill
				av.image = @@arrow
				av.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
			}
			@arrowView.layer.transform = CATransform3DMakeRotation(Math::PI, 0, 0, 1)
			addSubview(@arrowView)
			@activity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray).tap{|ac|
				ac.hidesWhenStopped = true
				ac.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
			}
			addSubview(@activity)
		end
	
		def layoutSubviews()
			super()
			bounds = self.bounds
			@lastUpdateLabel.frame = CGRectMake(0, bounds.size.height - 30, bounds.size.width, 20)
			@statusLabel.frame = CGRectMake(0, bounds.size.height - 48, bounds.size.width, 20)
			@arrowView.frame = CGRectMake(20, bounds.size.height - 65, 30, 55)
			@activity.frame = CGRectMake(25, bounds.size.height - 38, 20, 20)
		end
	
		def setStatus(status)
			if @status == status then
				return 
			end
			s = "Release to refresh"
			case status
				when RefreshViewStatus::Loading
					s = "Loading..."
				when RefreshViewStatus::PullToReload
					s = "Pull down to refresh..."
			end
			@statusLabel.text = s
		end
	
		def drawRect(rect)
			context = UIGraphicsGetCurrentContext()
			CGContextDrawPath(context, KCGPathFillStroke) #context.drawPath(KCGPathFillStroke)
			CGContextSetStrokeColorWithColor(context, @statusLabel.textColor.CGColor) #@statusLabel.textColor.setStroke()
			CGContextBeginPath(context) #context.beginPath()
			CGContextMoveToPoint(context, 0, self.bounds.size.height - 1) #context.moveTo(0, @bounds.size.height - 1)
			CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - 1) #context.addLineToPoint(@bounds.size.width, @bounds.size.height - 1)
			CGContextStrokePath(context) #context.strokePath()
		end
	
		def flip(animate)
			UIView.beginAnimations(nil, context: nil)
			UIView.setAnimationDuration(animate ? 0.18 : 0.0)
			@arrowView.layer.transform = @isFlipped ? CATransform3DMakeRotation(Math::PI, 0, 0, 1) : CATransform3DMakeRotation(Math::PI * 2, 0, 0, 1)
			UIView.commitAnimations()
			@isFlipped = !@isFlipped
		end
	
		def lastUpdate
			@lastUpdateTime
		end
	
		def lastUpdate=(value)
			if value == @lastUpdateTime then
				return 
			end
			@lastUpdateTime = value
			if value == Time.gm(0001,1,1,0,0,0) then
				@lastUpdateLabel.text = "Last Updated: never"
			else
				@lastUpdateLabel.text = "Last Updated: #{value.strftime('%c')}"
			end
		end
	
		def setActivity(active)
			if active then
				@activity.startAnimating()
				@arrowView.hidden = true
				setStatus(RefreshViewStatus::Loading)
			else
				@activity.stopAnimating()
				@arrowView.hidden = false
			end
		end
		
	end #class
	
end #module
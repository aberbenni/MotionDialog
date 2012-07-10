
# This cell does not perform cell recycling, do not use as
# sample code for new elements. 
module MotionDialog

	class LoadMoreElement < Element
		@@key = "LoadMoreElement"
		
		attr_accessor :normalCaption, :loadingCaption, :textColor, :backgroundColor, :tapped, :font, :height, :accessory, :animating

		def initialize(normalCaption, loadingCaption, tapped, font, textColor)
			super("")
			
			@alignment = UITextAlignmentCenter
			@animating = false
			
			@pad = 10
			@isize = 20
			
			@normalCaption = normalCaption
			@loadingCaption = loadingCaption
			@tapped = tapped
			@font = font
			@textColor = textColor
		end

		def getCell(tv)
			cell = tv.dequeueReusableCellWithIdentifier(@key)
			if cell.nil? then
				cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: @key)
				activityIndicator = UIActivityIndicatorView.new().tap do |ai|
					ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray
					ai.tag = 1
				end
				caption = UILabel.new().tap do |l|
					l.adjustsFontSizeToFitWidth = false
					l.tag = 2
				end
				cell.contentView.addSubview(caption)
				cell.contentView.addSubview(activityIndicator)
			else
				activityIndicator = cell.contentView.viewWithTag(1) #as UIActivityIndicatorView
				caption = cell.contentView.viewWithTag(2) #as UILabel
			end
			if @animating then
				caption.text = self.loadingCaption
				activityIndicator.hidden = false
				activityIndicator.startAnimating()
			else
				caption.text = self.normalCaption
				activityIndicator.hidden = true
				activityIndicator.stopAnimating()
			end
			if self.backgroundColor != nil then
				cell.contentView.backgroundColor = self.backgroundColor || UIColor.clearColor
			else
				cell.contentView.backgroundColor = nil
			end
			caption.backgroundColor = UIColor.clearColor
			caption.TextColor = self.textColor || UIColor.blackColor
			caption.font = @font || UIFont.BoldSystemFontOfSize(16)
			caption.textAlignment = @alignment
			self.layout(cell, activityIndicator, caption)
			cell
		end

		def animating
			@animating
		end

		def animating=(value)
			if @animating == value then
				return 
			end
			@animating = value
			cell = self.getActiveCell()
			if cell.nil? then
				return 
			end
			activityIndicator = cell.contentView.viewWithTag(1) #as UIActivityIndicatorView
			caption = cell.contentView.viewWithTag(2) #as UILabel
			if value then
				caption.text = self.loadingCaption
				activityIndicator.hidden = false
				activityIndicator.startAnimating()
			else
				activityIndicator.stopAnimating()
				activityIndicator.hidden = true
				caption.Text = self.normalCaption
			end
			self.layout(cell, activityIndicator, caption)
		end

		def selected(dvc, tableView, path)
			tableView.deselectRowAtIndexPath(path, animated: true)
			if self.animating then
				return 
			end
			if @tapped != nil then
				self.animating = true
				@tapped.call()
			end
		end

		def getTextSize(text)
			text.sizeWithFont(@font, forWidth: UIScreen.mainScreen.bounds.size.width, lineBreakMode: UILineBreakModeTailTruncation)
		end

		def getHeight(tableView, indexPath)
			@height || self.getTextSize(self.animating ? self.loadingCaption : self.normalCaption).height + 2 * @pad
		end

		def layout(cell, activityIndicator, caption)
			sbounds = cell.contentView.bounds
			size = self.getTextSize(self.animating ? self.loadingCaption : self.normalCaption)
			if !activityIndicator.hidden? then
				activityIndicator.frame = CGRectMake((sbounds.size.width - size.width) / 2 - @isize * 2, @pad, @isize, @isize )
			end
			caption.frame = CGRectMake(10, @pad, sbounds.size.width - 20, size.height)
		end

		def alignment
			@alignment
		end

		def alignment=(value)
			@alignment = value
		end

	end#class

end #module


# DialogViewController: drives MotionDialog
#
# Author:: Alessandro Berbenni (mailto:aberbenni@gmail.com)
# Copyright:: Copyright (c) 2012 Alessandro Berbenni
# License::   This code is licensed under the terms of the MIT X11 license
#       
# Code based on Miguel de Icaza's MonoTouch.Dialog.DialogViewController
# Code to support pull-to-refresh based on Martin Bowling's TweetTableView
# which is based in turn in EGOTableViewPullRefresh code which was created
# by Devin Doty and is Copyrighted 2009 enormego and released under the
# MIT X11 license 

module MotionDialog

	# The DialogViewController is the main entry point to use MonoTouch.Dialog,
	# it provides a simplified API to the UITableViewController.
	class DialogViewController < UITableViewController
    
    	
    	# If @enableSearch is true, we are enabled, used in the source for quick computation
    	
    	# @autoHideSearch If set, we automatically scroll the content to avoid showing the search bar until 
		# the user manually pulls it down.
		
		# @autorotate Controls whether the DialogViewController should auto rotate
		
    	attr_accessor :refreshView, :searchBar, :style
    	attr_accessor :pushing, :reloading, :dirty, :autorotate, :autoHideSearch
    	attr_accessor :onSelection, :reloading, :searchPlaceholder
    	    	
    	alias :pushing? :pushing
    	alias :reloading? :reloading
    	alias :dirty? :dirty
    	alias :autorotate? :autorotate
    	alias :autoHideSearch? :autoHideSearch
    	alias :reloading? :reloading
    	
    	#def tableView
    	#	@tableView
    	#end
    	
    	#def tableView=(value)
    	#	if !value.nil? then
    	#		@tableView = value
    	#	end	
    	#end
    	
		# The root element displayed by the DialogViewController,
		# the value can be changed during runtime to update the contents.
		def root
			@root
		end
	
		def root=(value)
			if @root == value then
				return 
			end
			if @root != nil then
				@root = nil
			end
			@root = value
			@root.tableView = @tableView
			self.reloadData()
		end
	    
		# If you assign a handler to this event before the view is shown, the
		# DialogViewController will have support for pull-to-refresh UI.
		def refreshRequested=(value)
			if @tableView != nil then
				raise ArgumentError, "You should set the handler before the controller is shown"
			end
			@refreshRequested = value
		end
		
		def refreshRequested
			@refreshRequested
		end
		
		alias :refreshRequested? :refreshRequested
		
		def enableSearch=(value)
			if @enableSearch == value then
				return 
			end
			# After MonoTouch 3.0, we can allow for the search to be enabled/disable
			if @tableView != nil then
				raise ArgumentError, "You should set EnableSearch before the controller is shown"
			end
			@enableSearch = value
		end
		
		def enableSearch
			@enableSearch
		end
		
		alias :enableSearch? :enableSearch
		
		# Invoke this method to trigger a data refresh.
		# This will invoke the RerfeshRequested handler, the code attached to it
		# should start the background operation to fetch the data and when it completes
		# it should call reloadComplete to restore the control state.
		def triggerRefresh(showStatus=false)
			if @refreshRequested.nil? then
				return 
			end
			if @reloading then
				return 
			end
			@reloading = true
			if @refreshView != nil then
				@refreshView.setActivity(true)
			end
			refreshRequested.call()
			if @reloading and showStatus and @refreshView != nil then
				UIView.beginAnimations("reloadingData")
				UIView.setAnimationDuration(0.2)
				@tableView.contentInset = UIEdgeInsets.new(60, 0, 0, 0)
				UIView.commitAnimations()
			end
		end
	
		# Invoke this method to signal that a reload has completed, this will update the UI accordingly.
		def reloadComplete()
			if @refreshView != nil then
				@refreshView.lastUpdate = Time.now
			end
			if not @reloading then
				return 
			end
			@reloading = false
			if @refreshView == nil then
				return 
			end
			@refreshView.setActivity(false)
			@refreshView.flip(false)
			UIView.beginAnimations("doneReloading")
			UIView.setAnimationDuration(0.3)
			@tableView.contentInset = UIEdgeInsets.new(0, 0, 0, 0) #attenzione
			@refreshView.setStatus(RefreshViewStatus::PullToReload)
			UIView.commitAnimations()
		end
					
		def shouldAutorotateToInterfaceOrientation(toInterfaceOrientation)
			@autorotate || toInterfaceOrientation == UIInterfaceOrientationPortrait
		end
	
		def didRotate(fromInterfaceOrientation)
			super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
			#Fixes the RefreshView's size if it is shown during rotation
			if @refreshView != nil then
				bounds = self.view.bounds
				@refreshView.frame = CGrectMake(0, -bounds.size.height, bounds.size.width, bounds.size.height)
			end
			self.reloadData()
		end
	
		# Allows caller to programatically activate the search bar and start the search process
		def startSearch()
			if @originalSections != nil then
				return 
			end
			@searchBar.becomeFirstResponder()
			@originalSections = Array.new(self.root.sections)
			@originalElements = Array.new(@originalSections.length){Array.new()}
			
			@originalSections.each_index{|i|
				@originalElements[i] = @originalSections[i].elements
			}
		end
	
		# Allows the caller to programatically stop searching.
		def finishSearch()
			if @originalSections.nil? then
				return 
			end
			self.root.sections = Array.new(@originalSections)
			@originalSections = nil
			@originalElements = nil
			@searchBar.resignFirstResponder()
			self.reloadData()
		end
	
		def onSearchTextChanged(text)
			if @searchTextChanged != nil then
				searchTextChanged(self, SearchChangedEventArgs.new(text))
			end
		end
	
		def performFilter(text)
			if @originalSections.nil? then
				return 
			end
			
			newSections = Array.new()
			
			@originalSections.each_index{ |sidx|
				newSection = nil
				section = @originalSections[sidx]
				elements = @originalElements[sidx]
				elements.each_index{ |eidx|
					if elements[eidx].matches(text) then
						if newSection.nil? then
							newSection = Section.new(section.header, section.footer).tap{ |ns|
								ns.footerView = section.footerView
								ns.headerView = section.headerView
							}
							newSections<<newSection
						end
						newSection.add(elements[eidx])
					end
				}
			}
			self.root.sections = newSections
			self.reloadData()
		end
	
		def searchButtonClicked(text)
			self.performFilter(text)
		end
	
		# this Class implements UISearchBarDelegate protocols
		class SearchDelegate
						
			def initialize(container)
				@container = container
			end
			
			def searchBar(searchBar, textDidChange:searchText)
				@container.performFilter(searchText || "")
			end
			
			#searchBar:shouldChangeTextInRange:replacementText:
			#searchBarShouldBeginEditing:
			
			def searchBarTextDidBeginEditing(searchBar)
				searchBar.showsCancelButton = true
				@container.startSearch()
			end
			
			def searchBarTextDidEndEditing(searchBar)
				searchBar.showsCancelButton = false
				@container.finishSearch()
			end
						
			def searchBarCancelButtonClicked(searchBar)
				searchBar.showsCancelButton = false
				@container.finishSearch()
				searchBar.resignFirstResponder()
			end
			
			def searchBarSearchButtonClicked(searchBar)
				@container.searchButtonClicked(searchBar.text)
			end
			
		end #class
	
		class Source #implements UITableViewDataSource, UITableViewDelegate and UIScrollViewDelegate protocols
			
			Yboundary = 65.0
			
			attr_accessor :root, :container
			
			protected :root, :container
			
			def initialize(container)
				@container = container
				@root = container.root
			end
	
			# UITableViewDataSource Methods
			
			def tableView(tableView, cellForRowAtIndexPath:indexPath)
				section = @root.sections[indexPath.section]
				element = section.elements[indexPath.row]
				element.getCell(tableView)
			end
			
			def numberOfSectionsInTableView(tableView)
				@root.sections.count
			end
			
			def tableView(tableView, numberOfRowsInSection:section)
				s = @root.sections[section]
				count = s.elements.count
				return count
			end
			
			#sectionIndexTitlesForTableView(tableView)
			#tableView(tableView, sectionForSectionIndexTitle:title, atIndex:index)

			def tableView(tableView, titleForHeaderInSection:section)
				@root.sections[section].caption
			end
			
			def tableView(tableView, titleForFooterInSection:section)
				@root.sections[section].footer
			end
			
			#tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
			#tableView(tableView, canEditRowAtIndexPath:indexPath)

			#tableView(tableView, canMoveRowAtIndexPath:indexPath)
			#tableView(tableView, moveRowAtIndexPath: fromIndexPath, toIndexPath:toIndexPath)
			
			
			# UITableViewDelegate Methods
			
			#tableView(tableView, heightForRowAtIndexPath:indexPath)
			#tableView(tableView, indentationLevelForRowAtIndexPath:indexPath)
			
			def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
				if @root.needColorUpdate then
					section = @root.sections[indexPath.section]
					section.elements.each_index{|i| puts "#{i}:#{section.elements[i]}" }
					element = section.elements[indexPath.row]
					puts " element:#{element.caption}"
					colorized = element if element.respond_to?(:willDisplay) #as IColorizeBackground
					puts " colorized:#{colorized.to_s}"
					if colorized != nil then
						colorized.willDisplay(tableView, cell, indexPath)
					end
				end
			end
			
			def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
				section = @root.sections[indexPath.section]
				element = (section.elements[indexPath.row])
				if element != nil then
					element.accessoryTap()
				end
			end
			
			#tableView(tableView, accessoryTypeForRowWithIndexPath:indexPath) Deprecated in iOS 3.0
			#tableView(tableView, willSelectRowAtIndexPath:indexPath)
			
			def tableView(tableView, didSelectRowAtIndexPath:indexPath)
				onSelection = @container.onSelection
				if onSelection != nil then
					onSelection(indexPath)
				end
				@container.selected(indexPath)
			end
			#tableView(tableView, willDeselectRowAtIndexPath:indexPath)
			def tableView(tableView, didDeselectRowAtIndexPath:indexPath)
				@container.deselected(indexPath)
			end

			def tableView(tableView, viewForHeaderInSection:sectionIdx)
				section = @root.sections[sectionIdx]
				return section.headerView
			end

			def tableView(tableView, viewForFooterInSection:sectionIdx)
				section = @root.sections[sectionIdx]
				section.footerView
			end

			def tableView(tableView, heightForHeaderInSection:sectionIdx)
				section = @root.sections[sectionIdx]
				if section.headerView.nil? then
					return -1
				end
				section.headerView.frame.size.height
			end

			def tableView(tableView, heightForFooterInSection:sectionIdx)
				section = @root.sections[sectionIdx]
				if section.footerView.nil? then
					return -1
				end
				section.footerView.frame.size.height
			end
			
			#tableView(tableView, willBeginEditingRowAtIndexPath:indexPath)
			#tableView(tableView, didEndEditingRowAtIndexPath:indexPath)
			#tableView(tableView, editingStyleForRowAtIndexPath:indexPath)
			#tableView(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath)
			#tableView(tableView, shouldIndentWhileEditingRowAtIndexPath:indexPath)
			#tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath, toProposedIndexPath:proposedDestinationIndexPath)
			#tableView(tableView, shouldShowMenuForRowAtIndexPath:indexPath)
			#tableView(tableView, canPerformAction:action, forRowAtIndexPath:indexPathwithSender:sender)
			#tableView(tableView, performAction:action, forRowAtIndexPath:indexPathwithSender:sender)
			
			# UIScrollViewDelegate Methods
				
			#region Pull to Refresh support
			def scrollViewDidScroll(scrollView)
				if !@checkForRefresh then
					return 
				end
				if @container.reloading then
					return 
				end
				view = @container.refreshView
				if view.nil? then
					return 
				end
				point = @container.tableView.contentOffset
				if view.flipped? && point.y > -Yboundary && point.y < 0 then
					view.flip(true)
					view.setStatus(RefreshViewStatus::PullToReload)
				elsif !view.flipped? && point.y < -Yboundary then
					view.flip(true)
					view.setStatus(RefreshViewStatus::ReleaseToReload)
				end
			end
	
			def scrollViewWillBeginDragging(scrollView)
				@checkForRefresh = true
			end
	
			def scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
				if @container.refreshView.nil? then
					return 
				end
				@checkForRefresh = false
				if @container.tableView.contentOffset.y > - Yboundary then
					return 
				end
				@container.triggerRefresh(true)
			end
			
		end #class
		
		# Performance trick, if we expose getHeightForRow, the UITableView will
		# probe *every* row for its size;   Avoid this by creating a separate
		# model that is used only when we have items that require resizing
		class SizingSource < Source
			
			def initialize(controller)
				super(controller)
			end
	
			def getHeightForRow(tableView, indexPath)
				tableView(tableView, heightForRowAtIndexPath:indexPath)
			end
			
			def tableView(tableView, heightForRowAtIndexPath:indexPath)
				section = self.root.sections[indexPath.section]
				element = section.elements[indexPath.row]
				sizable = element if element.respond_to?(:getHeight) #as IElementSizing
				if sizable.nil? then
					return tableView.rowHeight
				end
				sizable.getHeight(tableView, indexPath)
			end
			
		end #class
		
		# Activates a nested view controller from the DialogViewController.
		# If the view controller is hosted in a UINavigationController it
		# will push the result.   Otherwise it will show it as a modal
		# dialog
		def activateController(controller)
			@dirty = true
			parent = self.parentViewController()
			nav = parent
			# We can not push a nav controller into a nav controller
			if nav != nil && !controller.kind_of?(UINavigationController) then
				nav.pushViewController(controller, animated:true)
			else
				if(controller.kind_of?(UIImagePickerController))
					self.presentViewController(controller, animated: true, completion: nil)
				else
					self.presentModalViewController(controller, animated: true)
				end
			end
		end
	
		# Dismisses the view controller.   It either pops or dismisses
		# based on the kind of container we are hosted in.
		def deactivateController(animated)
			parent = self.parentViewController()
			nav = parent
			if nav != nil then
				nav.popViewControllerAnimated(animated)
			else
				self.dismissModalViewControllerAnimated(animated)
			end
		end
	
		def setupSearch()
			if @enableSearch then
				@searchBar = UISearchBar.alloc.initWithFrame CGRectMake(0, 0, @tableView.bounds.size.width, 44)
				@searchDelegate = SearchDelegate.new(self) #retain delegate
        		@searchBar.delegate = @searchDelegate
				if self.searchPlaceholder != nil then
					@searchBar.placeholder = self.searchPlaceholder
				end
				@tableView.tableHeaderView = @searchBar
			else
				tableView.tableHeaderView = nil
			end
		end
	
		def deselected(indexPath)
			section = @root.sections[indexPath.section]
			element = section.elements[indexPath.row]
			element.deselected(self, @tableView, indexPath)
		end
	
		def selected(indexPath)
			section = @root.sections[indexPath.section]
			element = section.elements[indexPath.row]
			element.selected(self, @tableView, indexPath)
		end
	
		def makeTableView(bounds, style)
			UITableView.alloc.initWithFrame(bounds, style:style)
		end
	
		def loadView()
			@tableView = self.makeTableView(UIScreen.mainScreen.bounds, @style)
			@tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin
			@tableView.autoresizesSubviews = true
			if @root != nil then
				@root.prepare()
			end
			self.updateSource()
			self.view = @tableView
			self.setupSearch()
			self.configureTableView()
			if @root.nil? then
				return 
			end
			@root.tableView = @tableView
		end
	
		def configureTableView()
			if @refreshRequested != nil then
				# The dimensions should be large enough so that even if the user scrolls, we render the
				# whole area with the background color.
				bounds = self.view.bounds
				@refreshView = self.makeRefreshTableHeaderView(CGRectMake(0, -bounds.size.height, bounds.size.width, bounds.size.height))
				if @reloading then
					refreshView.setActivity(true)
				end
				@tableView.addSubview(@refreshView)
			end
		end
	
		def makeRefreshTableHeaderView(rect)
			RefreshTableHeaderView.new(rect)
		end
	
		def viewWillAppear(animated)
			super(animated)
			if self.autoHideSearch then
				if self.enableSearch then
					if @tableView.contentOffset.y < 44 then
						@tableView.contentOffset = CGPoint.new(0, 44)
					end
				end
			end
			if @root.nil? then
				return 
			end
			@root.prepare()
			self.navigationItem.hidesBackButton = !@pushing
			if @root.caption != nil then
				self.navigationItem.title = @root.caption
			end
			if self.dirty then
				@tableView.reloadData()
				dirty = false
			end
		end
	
		def createSizingSource(unevenRows)
			unevenRows ? SizingSource.new(self) : Source.new(self)
		end
	
		def updateSource()
			if @root.nil? then
				return 
			end
			@tableSource = self.createSizingSource(@root.unevenRows)
			@tableView.dataSource = @tableSource
			@tableView.delegate = @tableSource #my patch ?!
		end
	
		def reloadData()
			if @root == nil then
				return 
			end
			if @root.caption != nil then
				self.navigationItem.title = @root.caption
			end
			@root.prepare()
			if @tableView != nil then
				self.updateSource()
				@tableView.reloadData()
			end
			dirty = false
		end
		
		#def viewWillDisappear(animated)
		#	super(animated)
		#	if @viewDisappearing != nil then
		#		self.viewDisappearing(self, EventArgs.Empty)
		#	end
		#end
	
		def initWithStyle(style)
			super(style)
		end
		
		def init()
			initialize()
		end
		
		# Creates a new DialogViewController from a RootElement and sets the push status
		# The RootElement containing the information to render.
		# A boolean describing whether this is being pushed
		# (NavigationControllers) or not.   If pushing is true, then the back button
		# will be shown, allowing the user to go back to the previous controller
		def initialize(*args)
			#@originalSections = Array.new()
			#@originalElements = Array.new(Array.new())
			case (args.length)
				when 1
					self.initWithStyle(UITableViewStyleGrouped)
					@style = UITableViewStyleGrouped
					@root = args[0]
				when 2
					if args[0].kind_of?(RootElement) then
						self.initWithStyle(UITableViewStyleGrouped)
						@style = UITableViewStyleGrouped
						@root = args[0]
						@pushing = args[1]
					else #if args[0].kind_of?(UITableViewStyle) then
						self.initWithStyle(args[0])
						@style = args[0]
						@root =  args[1]
					
					end 
				when 3
					self.initWithStyle(args[0])
					@style = args[0] 
					@root = args[1]
					@pushing = args[2]
				else
					@style = UITableViewStyleGrouped	
		    end
		    self
		end
		
	end #class
	
end #module
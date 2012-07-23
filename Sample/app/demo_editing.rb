
module Sample
	# To support editing, you need to subclass the DialogViewController and provide
	# your own "Source" classes (which you also have to subclass).
	# 
	# There are two source classes, a sizing one (for elements that have different
	# sizes, and one for fixed element sizes.   Since we are just using strings,
	# we are going to take a shortcut and just implement one of the sources.
	class EditingDialog < MotionDialog::DialogViewController
		
		# This is our subclass of the fixed-size Source that allows editing
		class EditingSource < MotionDialog::DialogViewController::Source
		
			def initialize(dvc)
				super(dvc)
			end

			def tableView(tableView, canEditRowAtIndexPath:indexPath)
				# Trivial implementation: we let all rows be editable, regardless of section or row
				true
			end

			def tableView(tableView, editingStyleForRowAtIndexPath:indexPath)
				# trivial implementation: show a delete button always
				UITableViewCellEditingStyleDelete
			end

			def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
				# In this method, we need to actually carry out the request
				section = self.container.root[indexPath.section]
				element = section[indexPath.row]
				section.remove(element)
			end
		
		end #class

		def createSizingSource(unevenRows)
			if unevenRows then
				raise NotImplementedError, "You need to create a new SourceSizing subclass, this sample does not have it"
			end
			EditingSource.new(self)
		end

		def initialize(root, pushing)
			super(root, pushing)
		end
		
	end #class

	class AppDelegate
	
		def activateEditing
			@dvc.tableView.setEditing(true, animated: true)
			self.configDone(@dvc)
		end
		
		def deactivateEditing
			@dvc.tableView.setEditing(false, animated: true)
			self.configEdit(@dvc)
		end
		
		def configEdit(dvc)
			dvc.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemEdit, target: self, action:"activateEditing" )
		end

		def configDone(dvc)
			dvc.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target: self, action:"deactivateEditing" )			
		end

		def demoEditing()
			editingSection = Section.new("To-do list").tap do |s|
				s.add StringElement.new("Donate to non-profit")
				s.add StringElement.new("Read new Chomsky book")
				s.add StringElement.new("Practice guitar")
				s.add StringElement.new("Watch Howard Zinn Documentary")
			end
			root = RootElement.new("Edit Support").tap do |r|
				r.add editingSection
			end
			@dvc = EditingDialog.new(root, true)
			self.configEdit(@dvc)
			@navigation.pushViewController(@dvc, animated: true)
		end

	end #class

end #module

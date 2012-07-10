
module Sample
	# To support editing, you need to subclass the DialogViewController and provide
	# your own "Source" classes (which you also have to subclass).
	#
	# There are two source classes, a sizing one (for elements that have different
	# sizes, and one for fixed element sizes.   Since we are just using strings,
	# we are going to take a shortcut and just implement one of the sources.
	class AdvancedEditingDialog < MotionDialog::DialogViewController
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

			def tableView(tableView, canMoveRowAtIndexPath:indexPath)
				true
			end

			def tableView(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
				section = container.root[sourceIndexPath.section]
				source = section[sourceIndexPath.row]
				section.remove(source)
				section.insert(destinationIndexPath.row, source)
			end
		end

		def createSizingSource(unevenRows)
			if unevenRows then
				raise NotImplementedError, "You need to create a new SourceSizing subclass, this sample does not have it"
			end
			return EditingSource.new(self)
		end

		def initialize(root, pushing)
			super(root, pushing)
		end
		
	end #class
	
	class AppDelegate
	
		def activateEditing
			# Switch the root to editable elements		
			@dvc.root = self.createEditableRoot(@dvc.root, true)
			@dvc.reloadData()
			# Activate row editing & deleting
			@dvc.tableView.setEditing(true, animated: true)
			self.advancedConfigDone(@dvc)
		end
		
		def deactivateEditing
			@dvc.reloadData()
			# Switch updated entry elements to StringElements
			@dvc.root = self.createEditableRoot(@dvc.root, false)			
			@dvc.tableView.setEditing(false, animated: true)
			self.advancedConfigEdit(@dvc)
		end
	
		def advancedConfigEdit(dvc)
			dvc.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemEdit, target: self, action:"activateEditing" )			
		end

		def advancedConfigDone(dvc)
			dvc.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target: self, action:"deactivateEditing" )	
		end

		def createEditableRoot(root, editable)
			rootElement = RootElement.new("Todo list").tap do |r|
				r.add Section.new()
			end
			
			root[0].elements.each do |element|
				if element.kind_of?(StringElement) then
					rootElement[0].add(self.createEditableElement(element.caption, element.value, editable)) #as StringElement
				else
					rootElement[0].add(self.createEditableElement(element.caption, element.value, editable)) #as EntryElement
				end
			end
			rootElement
		end

		def createEditableElement(caption, content, editable)
			if editable then
				return EntryElement.new(caption, "todo", content)
			else
				return StringElement.new(caption, content)
			end
		end
		
		def demoAdvancedEditing()
			root = RootElement.new("Todo list").tap do |r|
				r.add Section.new().tap{|s|
					s.add StringElement.new("1", "Todo item 1")
					s.add StringElement.new("2", "Todo item 2")
					s.add StringElement.new("3", "Todo item 3")
					s.add StringElement.new("4", "Todo item 4")
					s.add StringElement.new("5", "Todo item 5")
				}
			end
			@dvc = AdvancedEditingDialog.new(root, true)
			self.advancedConfigEdit(@dvc)
			@navigation.pushViewController(@dvc, animated: true)
		end
		
	end #class
end #module
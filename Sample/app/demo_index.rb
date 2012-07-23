
# This sample shows how to present an index.
# 
# This requires the user to create two subclasses for the
# internal model used in DialogViewController and a new
# subclass of DialogViewController that activates it.
# 
# See the source in IndexedViewController
# 
# The reason for Source and SourceSizing derived classes is
# that MotionDialog will create one or the other based on
# whether there are elements with uniform sizes or not.  This
# imrpoves performance by avoiding expensive computations.

module Sample

	class IndexedViewController < MotionDialog::DialogViewController
		
		def initialize(root, pushing)
			super(root, pushing)
			# Indexed tables require this style.
			self.style = UITableViewStylePlain
			self.enableSearch = true
			self.searchPlaceholder = "Find item"
			self.autoHideSearch = true
		end

		def getSectionTitles()
			self.root.sections.map{|s|
				s.caption..substring(0, 1)
			}
		end

		class IndexedSource < MotionDialog::DialogViewController::Source
			def initialize(parent)
				super(parent)
				@parent = parent
			end

			def sectionIndexTitles(tableView)
				j = @parent.getSectionTitles()
				j
			end
		end #class
		
		class SizingIndexedSource < MotionDialog::DialogViewController::Source
			def initialize(parent)
				super(parent)
				@parent = parent
			end

			def SectionIndexTitles(tableView)
				j = @parent.getSectionTitles()
				j
			end
		end #class

		def createSizingSource(unevenRows)
			if unevenRows then
				return SizingIndexedSource.new(self)
			else
				return IndexedSource.new(self)
			end
		end
		
	end #class
	
	class AppDelegate
		
		def demoIndex()
			root = RootElement.new("Container Style").tap do |r|
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ".each_char{|sh|
					r.add Section.new("#{sh} - Section").tap{|s|
						"12345".each_char{|filler|
							s.add StringElement.new("#{sh} - #{filler}")
						}
					}
				}
			end
			dvc = IndexedViewController.new(root, true)
			@navigation.pushViewController(dvc, animated: true)
		end
		
	end #class
	
end #module


module Sample

	class AppDelegate

		def demoAddRemove()
			puts "  @rnd:#@rnd"
			@rnd = Random.new()
			@count = -1
			puts "  @rnd:#@rnd"
			section = Section.new(nil, "Elements are added randomly").tap do |s|
				s.add StringElement.new("Add elements", self.method("addElements"))
				s.add StringElement.new("Add, with no animation", self.method("addNoAnimation"))
				s.add StringElement.new("Remove top element", self.method("removeElements"))
				s.add StringElement.new("Add Section", self.method("addSection"))
				s.add StringElement.new("Remove Section", self.method("removeSection"))
			end
			@region = Section.new()
			@demoRoot = RootElement.new("Add/Remove Demo").tap do |r|
				r.add section
				r.add @region
			end
			dvc = DialogViewController.new(@demoRoot, true)
			@navigation.pushViewController(dvc,  animated: true)
		end

		def addElements()
			puts "ad.addElements()"
			puts "  @region: #@region"
			#puts "  @rnd: #{@rnd}"
			#puts "  rand: #{@rnd.rand(0..@region.elements.count)}"
			@region.insert(Random.new().rand(0..@region.elements.count),
							UITableViewRowAnimationFade,
							[StringElement.new("Ding #{@count += 1}"), StringElement.new("Dong #{@count += 1}")])
		end

		def addNoAnimation()
			@region.add(StringElement.new("Insertion not animated"))
		end

		def removeElements()
			@region.removeRange(0, 1)
		end

		def addSection()
			section = Section.new().tap do |s|
				s.add StringElement.new("Demo Section Added")
			end
			@demoRoot.insert(@demoRoot.count, section)
		end

		def removeSection()
			# Do not delete the top (our buttons) or the second (where the buttons add stuff)
			if @demoRoot.count == 2 then
				return 
			end
			@demoRoot.removeAt(@demoRoot.count - 1)
		end

	end #class
	
end #module
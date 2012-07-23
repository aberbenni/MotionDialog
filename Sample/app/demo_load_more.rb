
module Sample

	class AppDelegate
		
		def demoLoadMore
			
			@loadMore = Section.new()
			
			s = StyledStringElement.new("Hola").tap do |e|
				#e.backgroundUri = "http://www.google.com/images/logos/ps_logo2.png"
				e.backgroundColor = UIColor.redColor
			end
			
			@loadMore.add s
			@loadMore.add StringElement.new("Element 1")
			@loadMore.add StringElement.new("Element 2")
			@loadMore.add StringElement.new("Element 3")
			@loadMore.add(@lme = LoadMoreElement.new("Load More Elements...", "Loading Elements...", lambda{
				# Launch a thread to do some work
				Dispatch::Queue.concurrent.async do
					# We just wait for 2 seconds.
					sleep 2.0
					
					# Now make sure we invoke on the main thread the updates
					Dispatch::Queue.main.sync do
						@lme.animating = false
						puts "#{@loadMore.count}"
						@loadMore.insert(@loadMore.count - 1, [StringElement.new("Element #{(@loadMore.count + 1)}"),
															   StringElement.new("Element #{(@loadMore.count + 2)}"),
															   StringElement.new("Element #{(@loadMore.count + 3)}") ])
															   	 
					end
					
				end
			}, UIFont.boldSystemFontOfSize(14.0), UIColor.blueColor))
				
			root = RootElement.new("Load More").tap do |r|
				r.add @loadMore
			end
			
			dvc = DialogViewController.new(root, true)
			@navigation.pushViewController(dvc, animated: true)
		end
		
	end #class
	
end #module

class UINavigationController

	def loadMore()
		puts "nc.loadMore()"
		@lme.animating = false
		@loadMore.insert(loadMore.count - 1, [StringElement.new("Element #{loadMore.count + 1}" + (loadMore.count + 1)),
											 StringElement.new("Element #{loadMore.count + 2}" + (loadMore.count + 2)),
											 StringElement.new("Element #{loadMore.count + 1}" + (loadMore.count + 3))])
	end
		
end #class

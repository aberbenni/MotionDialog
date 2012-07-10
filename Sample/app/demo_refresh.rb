
# Shows how to configure a DialogViewController to support
# Pull-to-Refresh

module Sample

	class AppDelegate
	
		def demoRefresh()
			@ri = 0
			@rroot = RootElement.new("Pull to Refresh").tap do |r|
				r.add Section.new().tap{|s|
					s.add MultilineElement.new("Pull from the top to add\na new item at the bottom\nThen wait 1 second")
				}
			end
			@rdvc = DialogViewController.new(@rroot, true)
			
			# After the DialogViewController is created, but before it is displayed
			# Assign to the RefreshRequested event.   The event handler typically
			# will queue a network download, or compute something in some thread
			# when the update is complete, you must call "ReloadComplete" to put
			# the DialogViewController in the regular mode
			@rdvc.refreshRequested = lambda{
				Dispatch::Queue.concurrent.async do
					# Wait X seconds, to simulate some network activity
					sleep(1)
					
					Dispatch::Queue.main.sync do
						@rroot[0].add StringElement.new("Added #{@ri+=1}")
					
						# Notify the dialog view controller that we are done
						# this will hide the progress info
						@rdvc.reloadComplete()
														   	 
					end
				end
			}
			
			# Notify the dialog view controller that we are done
			# this will hide the progress info
			@rdvc.style = UITableViewStylePlain
			@navigation.pushViewController(@rdvc, animated: true)
		end
		
	end #class

end #module
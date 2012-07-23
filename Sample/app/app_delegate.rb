
module Sample

	class AppDelegate # implements UIApplicationDelegate protocol
	  
		include MotionDialog
		
		#Footer = "These show the two sets of APIs\n"available in MotionDialogs"
		
		attr_accessor :navigation
				     
		def application(application, didFinishLaunchingWithOptions:launchOptions)
		  
			last = Time.gm(2010,10,7)
			
			p = NSBundle.mainBundle.pathForResource("background", ofType:"png") #
					
			menu = RootElement.new("Demos").tap do |r|
				r.add Section.new("Element API").tap{|s1|
					s1.add StringElement.new("iPhone Settings Sample", self.method("demoElementApi"))
			
					s1.add StringElement.new("Add/Remove demo", self.method("demoAddRemove"))
					s1.add StringElement.new("Assorted cell", self.method("demoDate"))
					s1.add StyledStringElement.new("Styled Elements",self.method("demoStyled")).tap{|sse1|
						sse1.backgroundUri = p
					}
					s1.add StringElement.new("Load More Sample", self.method("demoLoadMore"))
					s1.add StringElement.new("Row Editing Support", self.method("demoEditing"))
					s1.add StringElement.new("Advanced Editing Support", self.method("demoAdvancedEditing"))
					#s1.add StringElement.new("Owner Drawn Element", self.method("demoOwnerDrawnElement"))
				}
				r.add Section.new("Container features").tap{|s2|
					s2.add StringElement.new("Pull to Refresh", self.method("demoRefresh"))
					s2.add StringElement.new("Headers and Footers", self.method("demoHeadersFooters"))
					s2.add StringElement.new("Root Style", self.method("demoContainerStyle"))
					s2.add StringElement.new("Index sample", self.method("demoIndex"))
				}
			end
			
			# Create our UI and add it to the current toplevel navigation controller
			# this will allow us to have nice navigation animations.
			dv = DialogViewController.new(menu).tap{|dv|
				dv.autorotate = true
			}
			@navigation = UINavigationController.alloc.init
			@navigation.pushViewController(dv, animated:true)			
			
			# On iOS5 we use the new window.RootViewController, on older versions, we add the subview		
			@window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
			@window.makeKeyAndVisible()
			if (UIDevice.currentDevice.systemVersion.to_f>5.0)
				@window.rootViewController = @navigation
			else
				@window.addSubview(@navigation.view)
			end
			
			true
		end
		
		# This method is required in iPhoneOS 3.0
		def onActivated(application)
		end
		
	end #class
		
end #module

module Kernel

  def using(obj, &block)
    raise ArgumentError, "'obj' argument cannot be nil" unless obj
    raise ArgumentError, "'block' argument cannot be nil" unless block
    begin
      block.call
    ensure
      obj.cleanup if obj.respond_to? :cleanup
    end
  end

end #module

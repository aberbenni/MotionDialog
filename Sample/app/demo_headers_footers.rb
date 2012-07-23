
module Sample
    
	class AppDelegate
	
		def demoHeadersFooters()
			section = Section.new().tap do |s|
				s.headerView = self.class.BuildSectionHeaderView("Header")
				s.footerView = self.class.BuildSectionHeaderView("Footer")
			end
			
			section.add RootElement.new("Desert", RadioGroup.new("desert", 0)).tap{|r|
				r.add Section.new().tap{|s|
					s.add RadioElement.new("Ice Cream", "desert")
					s.add RadioElement.new("Milkshake", "desert")
					s.add RadioElement.new("Chocolate Cake", "desert")
				}
			}
			root = RootElement.new("Headers and Footers").tap do |r|
				r.add section
			end
			dvc = DialogViewController.new(root, true)
			@navigation.pushViewController(dvc, animated: true)
		end

		# Sharing this with all three tables on the HomeScreen
		def AppDelegate.BuildSectionHeaderView(caption)
			view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 320, 20))
			label = UILabel.new()
			label.backgroundColor = UIColor.orangeColor
			label.opaque = false
			label.textColor = UIColor.colorWithRed(150, green:210, blue:254, alpha:1)
			label.Font = UIFont.fontWithName("Helvetica-Bold", size: 16.0)
			label.Frame = CGRectMake(15, 0, 290, 20)
			label.text = caption
			view.addSubview(label)
			view
		end
		
	end #class

end #module



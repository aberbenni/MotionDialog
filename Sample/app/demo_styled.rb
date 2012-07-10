
module Sample

	class AppDelegate
	
		def demoStyled
			
			imageBackground = NSBundle.mainBundle.pathForResource("background", ofType:"png")
			image = UIImage.imageWithContentsOfFile(imageBackground)
			UIGraphicsBeginImageContextWithOptions(CGSize.new(32.0, 32.0), true, 0.0)
			image.drawInRect CGRectMake(0.0, 0.0, 32.0, 32.0)
			small = UIGraphicsGetImageFromCurrentImageContext()
			
			imageIcon = StyledStringElement.new("Local image icon").tap do |e|
				e.image = small
			end
			
			#backgroundImage = StyledStringElement.new("Image downloaded").tap do |e|
			#	e.backgroundUri = "http://www.google.com/images/logos/ps_logo2.png"
			#end
			
			localImage = StyledStringElement.new("Local image").tap do |e|
				e.backgroundUri = imageBackground
			end
			
			backgroundSolid = StyledStringElement.new("Solid background").tap do |e|
				e.backgroundColor = UIColor.greenColor
			end
			
			colored = StyledStringElement.new("Colored", "Detail in Green").tap do |e|
				e.textColor = UIColor.yellowColor
				e.backgroundColor = UIColor.redColor
				e.detailColor = UIColor.greenColor
			end
			
			sse = StyledStringElement.new("DetailDisclosureIndicator").tap do |e|
				e.accessory = UITableViewCellAccessoryDetailDisclosureButton
			end
			
			sse.accessoryTapped
			
			root = RootElement.new("Styled Elements").tap do |r|
				r.add Section.new("Image icon").tap{|s|
					s.add imageIcon
				}
				r.add Section.new("Background").tap{|s|
				    #s.add backgroundImage
				    s.add backgroundSolid
				    s.add localImage
				}
				r.add Section.new("Text Color").tap{|s|
				    s.add colored
				}
				r.add Section.new("Cell Styles").tap{|s|
					s.add StyledStringElement.new("Default", "Invisible value", UITableViewCellStyleDefault)
					s.add StyledStringElement.new("Value1", "Aligned on each side", UITableViewCellStyleValue1)
					s.add StyledStringElement.new("Value2", "Like the Addressbook", UITableViewCellStyleValue2)
					s.add StyledStringElement.new("Subtitle", "Makes it sound more important", UITableViewCellStyleSubtitle)
					s.add StyledStringElement.new("Subtitle", "Brown subtitle", UITableViewCellStyleSubtitle).tap{|e|
						e.detailColor = UIColor.brownColor
					}
				}
				r.add Section.new("Accessories").tap{|s|
					s.add StyledStringElement.new("DisclosureIndicator").tap{|e|
						e.accessory = UITableViewCellAccessoryDisclosureIndicator
					}
					s.add StyledStringElement.new("Checkmark").tap{|e|
						e.accessory = UITableViewCellAccessoryCheckmark
					}
					s.add sse
				}
			end
			dvc = DialogViewController.new(root, true)
			@navigation.pushViewController(dvc, animated: true)
		end
		
	end #class
	
end #module

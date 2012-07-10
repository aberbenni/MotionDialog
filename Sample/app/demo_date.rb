module Sample

	class AppDelegate

		@@longString = "Today a major announcement was done in my kitchen, when I managed to not burn the onions while on the microwave"
		
		def demoDate()
			if @badgeImage.nil? then
				@badgeImage = UIImage.imageNamed("jakub-calendar.png") #.imageWithContentsOfFile("jakub-calendar.png")
			end
			
			badgeSection = Section.new("Basic Badge Properties").tap do |s|
				s.add BadgeElement.new(@badgeImage, "New Movie Day").tap{|e|
					e.font = UIFont.fontWithName("Helvetica", size: 36.0)
				}
				s.add BadgeElement.new(@badgeImage, "Valentine's Day")
				s.add BadgeElement.new(@badgeImage, @@longString).tap{|e|
					e.lines = 3
					e.font = UIFont.fontWithName("Helvetica", size: 12.0)
				}
			end
			
			#
			# Use the MakeCalendarBadge API
			#
			font = UIFont.fontWithName("Helvetica", size: 14.0)
			dates = Array.new()
			dates<<["January", "1", "Hangover day"]
			dates<<["February", "14", "Valentine's Day"]
			dates<<["March", "3", "Third day of March"]
			dates<<["March", "31", "Prank Preparation day"]
			dates<<["April", "1", "Pranks"]
						
			calendarSection = Section.new("Date sample")
			
			dates.each do |date|
				calendarSection.add(BadgeElement.new(BadgeElement.makeCalendarBadge(@badgeImage, date[0], date[1]), date[2]).tap{|e| 
					e.font = font})
			end
			
			favorite = NSBundle.mainBundle.pathForResource("favorite.png", ofType: nil)
			favorite = UIImage.imageWithContentsOfFile favorite
			favorited = NSBundle.mainBundle.pathForResource("favorited.png", ofType: nil)
			favorited = UIImage.imageWithContentsOfFile favorited
			#favorited = UIImage.imageNamed "favorited.png"
			
			imageSection = Section.new("Image Booleans").tap do |s|
				s.add BooleanImageElement.new("Gone with the Wind", true, favorited, favorite)
				s.add BooleanImageElement.new("Policy Academy 38", false, favorited, favorite)
			end
			
			messageSection = Section.new("Message Elements").tap do |s| 
			
				s.add MessageElement.new(self.method("msgSelected")).tap{|m|
					m.sender = "Alessandro Berbenni (aberbenni.home@emailserver.com)"
					m.subject = "Re: [RubyMotion] Too much instance variables"
					m.body = "After reading the Rubymotion guides again, I found out that local variables are entitled to garbage-collection, while instance variables will only be collected when the instance variable receiver is alive."
					m.date = Time.now - (23 * 60 * 60)
					m.newFlag = true,
					m.messageCount = 0
				}
				
				s.add MessageElement.new(self.method("msgSelected")).tap{|m|
					m.sender = "Rose (rose.home@emailserver.com)"
					m.subject = "Pictures from Vacation"
					m.body = "Hi, here are the pictures that I promised from Vacation"
					m.date = Time.gm(2010, 10, 20)
					m.newFlag = false
					m.messageCount = 2
				}
			end
			
			entrySection = Section.new("Keyboard styles for entry").tap do |s|
			
				s.add EntryElement.new("Number ", "Some cute number", "1.2").tap{|e|
					e.keyboardType = UIKeyboardTypeNumberPad
				}
				s.add EntryElement.new("Email ", "", nil).tap{|e|
					e.keyboardType = UIKeyboardTypeEmailAddress
				}
				s.add EntryElement.new("Url ", "", nil).tap{|e|
					e.keyboardType = UIKeyboardTypeURL
				}
				s.add EntryElement.new("Phone ", "", "1.2").tap{|e|
					e.keyboardType = UIKeyboardTypePhonePad
				}
			end
			
			root = RootElement.new("Assorted Elements").tap do |r|
				r.add imageSection
				r.add messageSection
				r.add entrySection
				r.add calendarSection
				r.add badgeSection
			end
			
			dvc = DialogViewController.new(root, true)
			dvc.style = UITableViewStylePlain
			@navigation.pushViewController(dvc, animated:true)
		end

		def msgSelected(dvc, tv, path)
			np = DialogViewController.new(RootElement.new("Message Display").tap{|r|
					r.add Section.new().tap{|s|
						s.add StyledMultilineElement.new("From: foo\nTo: bar\nSubject: Hey there\n\nThis is very simple!")
					}
				}, true)
								
			dvc.activateController(np)
		end
	end
end

module Sample

	class AppDelegate
	
		def demoContainerStyle()
			root = RootElement.new("Container Style").tap do |r|
				r.add Section.new("A").tap{ |s|
					s.add StringElement.new("Another kind of")
					s.add StringElement.new("TableView, just by setting the")
					s.add StringElement.new("Style property")
				}
				r.add Section.new("C").tap{ |s|
					s.add StringElement.new("Chaos")
					s.add StringElement.new("Corner")
				}
				r.add Section.new("Style").tap{ |s|	
					"Hello there, this is a long text that I would like to split in many different nodes for the sake of all of us".split(' ').each{ |a|
						s.add StringElement.new(a)
					}
				}
			end
			dvc = DialogViewController.new(root, true).tap do |c|
				c.style = UITableViewStylePlain
			end
			@navigation.pushViewController(dvc, animated: true)
		end
		
	end #class
end #module
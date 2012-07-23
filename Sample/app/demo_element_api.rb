
module Sample

	class AppDelegate
		
		def demoElementApi
			root = createRoot()
			dv = DialogViewController.new(root, true)
			@navigation.pushViewController(dv, animated:true)
		end
		
		def createRoot
			return RootElement.new("Settings").tap{|r|
				r.add Section.new.tap{|s1|
					s1.add BooleanElement.new("Airplane Mode", false)
					s1.add RootElement.new("Notifications", 0, 0).tap{|r1|
						r1.add Section.new(nil, "Turn off Notifications to disable Sounds\n" +
							     "Alerts and Home Screen Badges for the\napplications below.").tap{|s1r1|
							s1r1.add BooleanElement.new("Notifications", false)
						}
					}
				}
				r.add Section.new.tap{|s2|
					s2.add self.createSoundSection()
					s2.add RootElement.new("Brightness").tap{|r1|
						r1.add Section.new().tap{|s1r1|
							s1r1.add FloatElement.new(nil, nil, 0.5)
							s1r1.add BooleanElement.new("Auto-brightness", false)
						}
					}
					s2.add RootElement.new("Wallpaper").tap{|r2|
						r2.add Section.new().tap{|s1r2|
							s1r2.add ImageElement.new(nil)
							s1r2.add ImageElement.new(nil)
							s1r2.add ImageElement.new(nil)
						}
					}
				}
				r.add Section.new().tap{|s3|
					s3.add EntryElement.new("Login", "Your login name", "alessandro")
					s3.add EntryElement.new("Password", "Your password", "password", true)
					s3.add DateElement.new("Select Date", Time.now)
					s3.add TimeElement.new("Select Time", Time.now)
				}
				r.add Section.new().tap{|x|
					x.add self.createGeneralSection()
				}
				r.add Section.new().tap{|s5|
					s5.add HtmlElement.new("About me", "http://www.berbenni.com")
					s5.add MultilineElement.new("An apple a day\nkeeps the doctor\naway")
				}
			}		
		end
		
		def createSoundSection
			return RootElement.new("Sounds").tap{|r|
				r.add Section.new("Silent").tap{|s1|
					s1.add BooleanElement.new("Vibrate", true)
				}
				r.add Section.new("Ring").tap{|s2|
					s2.add BooleanElement.new("Vibrate", true)
					s2.add FloatElement.new(nil, nil, 0.8)
					s2.add RootElement.new("Ringtone", RadioGroup.new(0)).tap{|s2r1|
						s2r1.add Section.new("Custom").tap{|s1s2r1|
							s1s2r1.add RadioElement.new("Circus Music")
							s1s2r1.add RadioElement.new("True Blood")
						}
						s2r1.add(Section.new("Standard").tap{|s2s2r1|
							"Marimba,Alarm,Ascending,Bark,Xylophone".split(',').each{|n|
								s2s2r1.add RadioElement.new(n)
							}
						})
					}
					s2.add RootElement.new("New Text Message", RadioGroup.new(3)).tap{|s2r2|
						s2r2.add Section.new().tap{ |s1s2r2|
							"None,Tri-tone,Chime,Glass,Horn,Bell,Eletronic".split(',').each{|n|
								s1s2r2.add RadioElement.new(n)
							}
						}
					}
					s2.add BooleanElement.new("New Voice Mail", false)
					s2.add BooleanElement.new("New Mail", false)
					s2.add BooleanElement.new("Sent Mail", true)
					s2.add BooleanElement.new("Calendar Alerts", true)
					s2.add BooleanElement.new("Lock Sounds", true)
					s2.add BooleanElement.new("Keyboard Clicks", false)
				}
			}
		end
		
		def createGeneralSection
			return RootElement.new("General").tap{|x|
				x.add Section.new().tap{|x|
					x.add RootElement.new("About").tap{|x|
						x.add Section.new("My Phone").tap{|x|
							x.add RootElement.new("Network", RadioGroup.new(nil, 0)).tap{|x|
								x.add Section.new().tap{|x|
									x.add RadioElement.new("My First Network")
									x.add RadioElement.new("Second Network")
								}
							}
							x.add StringElement.new("Songs", "23")
							x.add StringElement.new("Videos", "3")
							x.add StringElement.new("Photos", "24")
							x.add StringElement.new("Applications", "50")
							x.add StringElement.new("Capacity", "14.6GB")
							x.add StringElement.new("Available", "12.8GB")
							x.add StringElement.new("Version", "3.0 (FOOBAR)")
							x.add StringElement.new("Carrier", "My Carrier")
							x.add StringElement.new("Serial Number", "555-3434")
							x.add StringElement.new("Model", "The")
							x.add StringElement.new("Wi-Fi Address", "11:22:33:44:55:66")
							x.add StringElement.new("Bluetooth", "aa:bb:cc:dd:ee:ff:00")
						}
						x.add Section.new().tap{|x|
							x.add HtmlElement.new("MotionDialog", "https://github.com/aberbenni/MotionDialog")
						}
					}
					x.add RootElement.new("Usage").tap{|x|
						x.add Section.new("Time since last full charge").tap{|x|
							x.add StringElement.new("Usage", "0 minutes")
							x.add StringElement.new("Standby", "0 minutes")
						}
						x.add Section.new("Call time").tap{|x|
							x.add StringElement.new("Current Period", "4 days, 21 hours")
							x.add StringElement.new("Lifetime", "7 days, 20 hours")
						}
						x.add Section.new("Celullar Network Data").tap{|x|
							x.add StringElement.new("Sent", "10 bytes")
							x.add StringElement.new("Received", "30 TB")
						}
						x.add Section.new(nil, "Last Reset: 1/1/08 4:44pm").tap{|x|
							x.add StringElement.new("Reset Statistics").tap{|x|
								x.alignment = UITextAlignmentCenter
							}
						}
					}
				}
				x.add Section.new().tap{|x|
					x.add RootElement.new("Network").tap{|x|
						x.add Section.new(nil, "Using 3G loads data faster\nand burns the battery").tap{|x|
							x.add BooleanElement.new("Enable 3G", true)
						}
						x.add Section.new(nil, "Turn this on if you are Donald Trump").tap{|x|
							x.add BooleanElement.new("Data Roaming", false)
						}
						x.add Section.new().tap{|x|
							x.add RootElement.new("VPN", 0, 0).tap{|x|
								x.add Section.new().tap{|x|
									x.add BooleanElement.new("VPN", false)
								}
								x.add Section.new("Choose a configuration").tap{|x|
									x.add StringElement.new("Add VPN Configuration")
								}
							}
						}
					}
					x.add RootElement.new("Bluetooth", 0, 0).tap{|x|
						x.add Section.new().tap{|x|
							x.add BooleanElement.new("Bluetooth", false)
						}
					}
					x.add BooleanElement.new("Location Services", true)
				}
				x.add Section.new().tap{|x|
					x.add RootElement.new("Auto-Lock", RadioGroup.new(0)).tap{|x|
						x.add Section.new().tap{|x|
							x.add RadioElement.new("1 Minute")
							x.add RadioElement.new("2 Minutes")
							x.add RadioElement.new("3 Minutes")
							x.add RadioElement.new("4 Minutes")
							x.add RadioElement.new("5 Minutes")
							x.add RadioElement.new("Never")
						}
					}
					x.add BooleanElement.new("Restrictions", false)
				}
				x.add Section.new().tap{|x|
					x.add RootElement.new("Home", RadioGroup.new(2)).tap{|x|
						x.add Section.new("Double-click the Home Button for:").tap{|x|
							x.add RadioElement.new("Home")
							x.add RadioElement.new("Search")
							x.add RadioElement.new("Phone favorites")
							x.add RadioElement.new("Camera")
							x.add RadioElement.new("iPod")
						}
						x.add Section.new(nil, "When playing music, show iPod controls").tap{|x|
							x.add BooleanElement.new("iPod Controls", true)
						}
					}
					x.add RootElement.new("Date & Time").tap{|x|
						x.add Section.new().tap{|x|
							x.add BooleanElement.new("24-Hour Time", false)
						}
						x.add Section.new().tap{|x|
							x.add BooleanElement.new("Set Automatically", false)
						}
					}
					x.add RootElement.new("Keyboard").tap{|x|
						x.add Section.new(nil, "Double tapping the space bar will\ninsert a period followed by a space").tap{|x|
							x.add BooleanElement.new("Auto-Correction", true)
							x.add BooleanElement.new("Auto-Capitalization", true)
							x.add BooleanElement.new("Enable Caps Lock", false)
							x.add BooleanElement.new("\".\" Shortcut", true)
						}
						x.add Section.new().tap{|x|
							x.add RootElement.new("International Keyboards", Group.new("kbd")).tap{|x|
								x.add Section.new("Using Checkboxes").tap{|x|
									x.add CheckboxElement.new("English", true, "kbd")
									x.add CheckboxElement.new("Spanish", false, "kbd")
									x.add CheckboxElement.new("French", false, "kbd")
								}
								x.add Section.new("Using BooleanElement").tap{|x|
									x.add BooleanElement.new("Portuguese", true, "kbd")
									x.add BooleanElement.new("German", false, "kbd")
								}
								x.add Section.new("Or mixing them").tap{|x|
									x.add BooleanElement.new("Italian", true, "kbd")
									x.add CheckboxElement.new("Czech", true, "kbd")
								}
							}
						}
					}
				}
			}

		end
			
	end #class
	
end #module

class AppDelegate
  
  def application(application, didFinishLaunchingWithOptions: launchOptions)  
    # get the frame for the window
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    
    # instantiate a new object of the MainViewController
    # and assign it as the root controller.
    @window.rootViewController = MainViewController.new

    # this makes the window a receiver of events (for now we are using touch)
    @window.makeKeyAndVisible
    
    # update the count of number of times app opened and ask for App Store reviews
    update_count
    ask_for_review
    
    # because this method must return true
    true
  end
  
  # app has been opened
  def applicationWillEnterForeground(notification)
    update_count
    ask_for_review
  end
  
  # update count of number of times used
  def update_count
    count = NSUserDefaults.standardUserDefaults.integerForKey('count')
    NSUserDefaults.standardUserDefaults.setBool(true, forKey: 'review') if count == 0      
    NSUserDefaults.standardUserDefaults.setInteger(count + 1, forKey: 'count')
  end
  
  # send notification to controller
  def ask_for_review
    if NSUserDefaults.standardUserDefaults.integerForKey('count') % 5 == 0 &&
       NSUserDefaults.standardUserDefaults['review']
      NSNotificationCenter.defaultCenter.postNotificationName('review', object: nil)
    end
  end
  
end

class MainViewController < UIViewController
  
  #
  # initialize constants
  #
  
  MONEY_COLOR      = UIColor.colorWithRed(6 / 256.0, green: 92 / 256.0, blue: 39 / 256.0, alpha: 1)
  LIGHT_GRAY_COLOR = UIColor.colorWithRed(224 / 256.0, green: 224 / 256.0, blue: 224 / 256.0, alpha: 1)
  MID_GRAY_COLOR   = UIColor.colorWithRed(192 / 256.0, green: 192 / 256.0, blue: 192 / 256.0, alpha: 1)
  sym = NSUserDefaults.standardUserDefaults['currency']
  sym == nil ? SYM = '$' : SYM = sym
  sep = NSUserDefaults.standardUserDefaults['separators']
  sep == nil ? SEP = 0 : SEP = sep
  
  #
  # launch sequence
  #
  
  def preferredStatusBarStyle
    UIStatusBarStyleLightContent
  end
  
  def iphone_4_inch?
    UIScreen.mainScreen.bounds.size.height == 568.0
  end
  
  # view loaded depends on screen size (autolayout would be nice here)
  def loadView
    if iphone_4_inch?
      views = NSBundle.mainBundle.loadNibNamed 'MainView', owner: self, options: nil
    else
      views = NSBundle.mainBundle.loadNibNamed 'MainViewShort', owner: self, options: nil
    end
    self.view = views.first
  end
  
  # initialize stuff here
  def viewDidLoad
    super # must be called
    
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'open_review_view', name: 'review', object: nil)
    
    @model = MainModel.new
    @scope = 0
    
    # load views via tags
    load_tock_sound
    load_numeric_keys
    load_decimal_key
    load_delete_key
    load_clear_key
    load_splitter
    load_tip_chooser
    load_displays
    load_custom
    load_other_selector
    redisplay
  end
  
  #
  # load actions
  #
  
  def load_numeric_keys
    (1..10).each do |num|
      key = self.view.viewWithTag(num)
      key.addTarget(self, action: 'key_touch_down:', forControlEvents: UIControlEventTouchDown,
                                                                       UIControlEventTouchDragInside,
                                                                       UIControlEventTouchDragEnter)
      key.addTarget(self, action: 'key_exit:', forControlEvents: UIControlEventTouchDragOutside,
                                                                 UIControlEventTouchDragExit,
                                                                 UIControlEventTouchUpOutside)
      key.addTarget(self, action: 'num_touch_up:', forControlEvents: UIControlEventTouchUpInside)
    end
  end
  
  def load_decimal_key
    key = self.view.viewWithTag(11)
    key.setTitle(',', forState: UIControlStateNormal) if SEP == 1
    key.addTarget(self, action: 'key_touch_down:', forControlEvents: UIControlEventTouchDown,
                                                                     UIControlEventTouchDragInside,
                                                                     UIControlEventTouchDragEnter)
    key.addTarget(self, action: 'key_exit:', forControlEvents: UIControlEventTouchDragOutside,
                                                               UIControlEventTouchDragExit,
                                                               UIControlEventTouchUpOutside)
    key.addTarget(self, action: 'decimal_touch_up:', forControlEvents: UIControlEventTouchUpInside,
                                                                       UIControlEventTouchDragInside,
                                                                       UIControlEventTouchDragEnter)
  end
  
  def load_delete_key
    key = self.view.viewWithTag(12)
    key.setBackgroundColor(LIGHT_GRAY_COLOR)
    key.addTarget(self, action: 'key_touch_down:', forControlEvents: UIControlEventTouchDown,
                                                                     UIControlEventTouchDragInside,
                                                                     UIControlEventTouchDragEnter)
    key.addTarget(self, action: 'key_exit:', forControlEvents: UIControlEventTouchDragOutside,
                                                               UIControlEventTouchDragExit,
                                                               UIControlEventTouchUpOutside)
    key.addTarget(self, action: 'delete_touch_up:', forControlEvents: UIControlEventTouchUpInside,
                                                                      UIControlEventTouchDragInside,
                                                                      UIControlEventTouchDragEnter)
  end
  
  def load_clear_key
    @clear_key = self.view.viewWithTag(13)
    @clear_key.setBackgroundColor(LIGHT_GRAY_COLOR)
    @clear_key.addTarget(self, action: 'key_touch_down:', forControlEvents: UIControlEventTouchDown,
                                                                            UIControlEventTouchDragInside,
                                                                            UIControlEventTouchDragEnter)
    @clear_key.addTarget(self, action: 'key_exit:', forControlEvents: UIControlEventTouchDragOutside,
                                                                      UIControlEventTouchDragExit,
                                                                      UIControlEventTouchUpOutside)
    @clear_key.addTarget(self, action: 'clear_touch_up:', forControlEvents: UIControlEventTouchUpInside,
                                                                            UIControlEventTouchDragInside,
                                                                            UIControlEventTouchDragEnter)
  end
  
  def load_splitter
    @plus = self.view.viewWithTag(14)
    @plus.addTarget(self, action: 'add_split:', forControlEvents: UIControlEventTouchUpInside)
    
    @minus = self.view.viewWithTag(15)
    @minus.setEnabled(false)
    @minus.addTarget(self, action: 'subtract_split:', forControlEvents: UIControlEventTouchUpInside)
  end
  
  def load_tip_chooser
    none = self.view.viewWithTag(16)
    none.addTarget(self, action: 'tip_touch_down:', forControlEvents: UIControlEventTouchDown)
    
    ten = self.view.viewWithTag(17)
    ten.addTarget(self, action: 'tip_touch_down:', forControlEvents: UIControlEventTouchDown)
    
    fifteen = self.view.viewWithTag(18)
    fifteen.addTarget(self, action: 'tip_touch_down:', forControlEvents: UIControlEventTouchDown)
    
    twenty = self.view.viewWithTag(19)
    twenty.addTarget(self, action: 'tip_touch_down:', forControlEvents: UIControlEventTouchDown)
    
    other = self.view.viewWithTag(20)
    other.addTarget(self, action: 'tip_touch_down:', forControlEvents: UIControlEventTouchDown)
    
    @chooser = [none, ten, fifteen, twenty, other]
  end
  
  def load_displays
    @bill_display = self.view.viewWithTag(21)
    
    @tip_display = self.view.viewWithTag(22)
    @tip_display.setHidden(true)
    
    @total_display = self.view.viewWithTag(23)
    @total_display.setHidden(true)
    
    @split_display = self.view.viewWithTag(24)
  end
  
  # for custom tip percentages
  def load_custom
    @custom_view = NSBundle.mainBundle.loadNibNamed('Custom', owner: self, options: nil).first
    @custom_view.center = CGPointMake(160, 226)
    
    cancel = @custom_view.viewWithTag(25)
    cancel.setTitleColor(MONEY_COLOR, forState: UIControlStateNormal)
    cancel.addTarget(self, action: 'cancel:', forControlEvents: UIControlEventTouchUpInside)
    
    @ok = @custom_view.viewWithTag(26)
    @ok.addTarget(self, action: 'ok:', forControlEvents: UIControlEventTouchUpInside)
    @ok.setEnabled(false)
    
    @custom_display = @custom_view.viewWithTag(27)
  end
  
  # special selection box for 'Other'
  def load_other_selector
    @other_selector = NSBundle.mainBundle.loadNibNamed('Other', owner: self, options: nil).first
    @other_selector.subviews.each do |subview|
      subview.setBackgroundColor(MONEY_COLOR)
    end
    @other_selector.center = CGPointMake(288, 226)
  end
  
  #
  # define actions
  #
  
  # redisplay all
  def redisplay
    if @scope == 0
      redisplay_bill
    else
      redisplay_custom
    end
    redisplay_tip_and_total
    redisplay_splits
    redisplay_clear
  end
  
  def redisplay_bill
    @bill_display.setText("#{SYM}#{formated_num(@model.bill)}")
  end
  
  def redisplay_tip_and_total
    if @model.bill == '0'
      @total_display.setHidden(true)
      @tip_display.setHidden(true)
    else
      @tip_display.setHidden(false)
      @total_display.setHidden(false)
      @tip_display.setText("#{SYM}#{formated_num(@model.calculate_tip)}")
      if @model.splits > 1
        @total_display.setText("#{SYM}#{formated_num(@model.calculate_total)} * #{@model.splits}")
      else
        @total_display.setText("#{SYM}#{formated_num(@model.calculate_total)}")
      end
    end
  end
  
  def redisplay_splits
    if @model.splits > 1
      @split_display.setText("Split #{@model.splits} ways")
      @minus.setEnabled(true)
      @plus.setEnabled(false) if @model.splits >= 99
    else
      @split_display.setText("Split #{@model.splits} way")
      @minus.setEnabled(false)
      @plus.setEnabled(true) if @model.splits < 99
    end
  end
  
  def redisplay_custom
    @custom_display.setText("#{@model.custom}%")
    if @model.custom == '0'
      @ok.setEnabled(false)
      @ok.setTitleColor(MID_GRAY_COLOR, forState: UIControlStateNormal)
    else
      @ok.setEnabled(true)
      @ok.setTitleColor(MONEY_COLOR, forState: UIControlStateNormal)
    end
  end
  
  def redisplay_clear
    if (@scope == 0 && @model.bill != '0') || (@scope == 1 && @model.custom != '0')
      @clear_key.setTitle('C', forState: UIControlStateNormal)
    else
      @clear_key.setTitle('AC', forState: UIControlStateNormal)
    end
  end
  
  def tip_touch_down(sender)
    if sender.tag == 20
      change_scope
      redisplay
    else
      @model.set_tip(sender.tag)
      update_tip_chooser(sender)
    end
  end
  
  def update_tip_chooser(sender)
    @chooser.each do |choice|
      if choice.tag == sender.tag
        choice.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        choice.setBackgroundColor(MONEY_COLOR)
        @other_selector.removeFromSuperview
      else
        choice.setTitleColor(MONEY_COLOR, forState: UIControlStateNormal)
        choice.setBackgroundColor(UIColor.whiteColor)
      end
    end
    redisplay
  end
  
  def reset_tip_chooser(clear = false)
    @chooser.each do |choice|
      if choice.tag == 16 && clear
        choice.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        choice.setBackgroundColor(MONEY_COLOR)
      else
        choice.setTitleColor(MONEY_COLOR, forState: UIControlStateNormal)
        choice.setBackgroundColor(UIColor.whiteColor)
      end
    end
    redisplay
  end
  
  def change_scope
    if @scope == 0
      @scope = 1
      self.view.addSubview(@custom_view)
    else
      @scope = 0
      @custom_view.removeFromSuperview
      load_custom
    end
  end
    
  def add_split(sender)
    @model.add_split
    redisplay
  end
  
  def subtract_split(sender)
    @model.sub_split
    redisplay
  end
  
  def ok(sender)
    unless @model.custom == '0'
      @model.set_tip_from_custom
      self.view.addSubview(@other_selector)
      reset_tip_chooser
      change_scope
      redisplay
    end
  end
  
  def cancel(sender)
    change_scope
    redisplay
  end
  
  def key_exit(sender)
    if sender.tag == 12 || sender.tag == 13
      sender.setBackgroundColor(LIGHT_GRAY_COLOR)
    else
      sender.setBackgroundColor(UIColor.whiteColor)
    end
  end
  
  def key_touch_down(sender)
    if sender.tag == 12 || sender.tag == 13
      sender.backgroundColor = MID_GRAY_COLOR
    else
      sender.backgroundColor = LIGHT_GRAY_COLOR
    end
    play_tock
  end
  
  def animate_touch_up(sender)
    UIView.animateWithDuration(0.3,
      delay: 0,
      options: UIViewAnimationOptionAllowUserInteraction,
      animations: lambda {
        if sender.tag == 12 || sender.tag == 13
          sender.setBackgroundColor(LIGHT_GRAY_COLOR)
        else
          sender.setBackgroundColor(UIColor.whiteColor)
        end
      },
      completion: lambda { |finished| }
    )
  end
  
  def num_touch_up(sender)
    if @scope == 0
      @model.append_to_bill(sender.tag - 1)
    else
      @model.append_to_custom(sender.tag - 1)
    end
    redisplay
    animate_touch_up(sender)
  end
  
  def delete_touch_up(sender)
    if @scope == 0
      @model.delete(@scope)
    else
      @model.delete(@scope)
    end
    redisplay
    animate_touch_up(sender)
  end
  
  def decimal_touch_up(sender)
    if @scope == 0
      @model.append_to_bill('.')
    else
      @model.append_to_custom('.')
    end
    redisplay
    animate_touch_up(sender)
  end
  
  def clear_touch_up(sender)
    if @model.needs_full_reset(@scope)
      reset_tip_chooser(true)
      @other_selector.removeFromSuperview
      change_scope if @scope == 1
    end
    @model.clear(@scope)
    redisplay
    animate_touch_up(sender)
  end
  
  def play_tock
    @tock_sound.play
  end
  
  def load_tock_sound
    session = AVAudioSession.sharedInstance
    session.setCategory(AVAudioSessionCategoryAmbient, error: nil)
    
    mainBundle = NSBundle.mainBundle
    file_path = mainBundle.pathForResource('Tock', ofType: 'mp3')
    file_data = NSData.dataWithContentsOfFile(file_path)
    
    @tock_sound = AVAudioPlayer.alloc.initWithData(file_data, error: nil)
    @tock_sound.setDelegate(self)
    @tock_sound.setVolume(0.2)
    @tock_sound.prepareToPlay
  end
  
  def formated_num(num)
    if SEP == 0
      num.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
    else
      if num.to_i < 1000
        num.sub('.', ',')
      else
        decimal = num.include?('.')
        num = num.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join('.')
        if decimal
          num = num.sub('.', ',')
        end
        num.reverse
      end
    end
  end
  
  def open_review_view
    msg = 'Would you like to review CheckMate on the App Store?'
    alert = UIAlertView.alloc.initWithTitle('Review CheckMate',
                                            message: msg,
                                            delegate: self,
                                            cancelButtonTitle: 'No',
                                            otherButtonTitles: nil)
    alert.addButtonWithTitle('Yes')
    alert.show
  end
  
  def alertView(alertView, clickedButtonAtIndex: buttonIndex)
    if buttonIndex == 1
      NSUserDefaults.standardUserDefaults.setBool(false, forKey: 'review')
      str = 'http://itunes.apple.com/app/id782864867'
      UIApplication.sharedApplication.openURL(NSURL.URLWithString(str))
    end
  end
  
end

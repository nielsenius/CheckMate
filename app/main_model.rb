class MainModel
  
  attr_accessor :tip
  attr_accessor :bill
  attr_accessor :splits
  attr_accessor :custom
  
  def initialize
    setup
  end
  
  def setup
    @tip    = 0.00
    @bill   = '0'
    @splits = 1
    @custom = '0'
  end
  
  def set_tip(tag)
    case tag
    when 16
      @tip = 0.00
    when 17
      @tip = 0.10
    when 18
      @tip = 0.15
    when 19
      @tip = 0.20
    end
  end
  
  def append_to_bill(value)
    if value == '.'
      if @bill.include?('.')
        return
      else
        @bill << '.'
      end
    elsif @bill == '0'
      @bill = value.to_s
    else
      @bill << value.to_s
    end
  end
  
  def append_to_custom(value)
    if value == '.'
      if @custom.include?('.')
        return
      else
        @custom << '.'
      end
    elsif @custom == '0'
      @custom = value.to_s
    else
      @custom << value.to_s
    end
  end
  
  def delete(view_scope)
    if view_scope == 0 && @bill != '0'
      if @bill.length == 1
        @bill = '0'
      else
        @bill.chop!
      end
    elsif view_scope == 1 && @custom != '0'
      if @custom.length == 1
        @custom = '0'
      else
        @custom.chop!
      end
    end
  end
  
  def clear(view_scope)
    if view_scope == 0
      if @bill == '0'
        setup
      else
        @bill = '0'
      end
    else
      if @custom == '0'
        setup
      else
        @custom = '0'
      end
    end
  end
  
  def needs_full_reset(view_scope)
    if view_scope == 0
      @bill == '0'
    else
      @custom == '0'
    end
  end
  
  def set_tip_from_custom
    @tip = @custom.to_f / 100.0
  end
  
  def add_split
    @splits += 1 if @splits < 100
  end
  
  def sub_split
    @splits -= 1 if @splits > 1
  end
  
  def calculate_tip
    "%.2f" % (@bill.to_f * @tip)
  end
  
  def calculate_total
    "%.2f" % ((@bill.to_f + (@bill.to_f * @tip)) / @splits)
  end
  
end

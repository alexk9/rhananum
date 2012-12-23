require "com/frostbean/rhannanum/plugin/plugin"

module PosProcessor
  include Plugin

  def do_process(st)
    raise NoMothodException.new
  end

end
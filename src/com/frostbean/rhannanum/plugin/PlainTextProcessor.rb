require "com/frostbean/rhannanum/plugin/plugin"

module PlainTextProcessor
  include Plugin

  def do_process( plain_sentence)
    raise NoMethodError.new
  end

  def has_remaining_data?
    raise NoMethodError.new
  end

  def flush
    raise NoMethodError.new
  end

end
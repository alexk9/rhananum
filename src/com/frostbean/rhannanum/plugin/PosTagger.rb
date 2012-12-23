require "com/frostbean/rhannanum/plugin/plugin"


##
# The plug-in interface is for Part Of Speech Tagger.
module PosTagger
  def tagPOS(sos)
    raise NoMethodException.new
  end
end

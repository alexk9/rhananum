require "com/frostbean/rhannanum/plugin/plugin"

##
# The plug-in interface is for morphological analysis
# 
# - Phase: The Second Phase
# - Type: Major Plug-in
class MorphAnalyzer 
  include Plugin
  
  
  ##
  # It performs morphological analysis on the specified plain sentence, and returns the all analysis result where
  # each plain eojeol has more than one morphologically analyzed eojeol.
  # @param ps - the plain sentence to be morphologically analyzed
  # @return - the set of eojeols where each eojeol has at least one morphological analysis result
  def morph_analyze(ps)
     raise NoMethodError.new
  end
end  

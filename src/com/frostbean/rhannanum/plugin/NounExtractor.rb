require "com/frostbean/rhannanum/plugin/PosProcessor"

##
#This plug-in extracts the morphemes recognized as a noun after Part Of Speech tagging was done.
#It is a POS Processor plug-in which is a supplement plug-in of phase 3 in HanNanum work flow.

class NounExtractor
  include PosProcessor

  def initialize
    #the buffer for noun morphemes
    @nounMorphemes = []
    # the buffer for tags of the morphemes */
	  @nounTags = nil
  end

  def second_initialize( baseDir, configFile )
    nounMorphemes = []
    nounTags = []
  end

  def shutdown

  end

	##
	# It extracts the morphemes which were recognized as noun after POS tagging.
  def do_process(st)

		eojeols = st.get_eojeols()

    for i in 0..(eojeols.length-1) do
      morphemes = eojeols[i].get_morphemes()
      tags = eojeols[i].get_tags()

      @nounMorphemes.clear
      @nounTags.clear

      for j in 0..(tags.length-1) do
        c = tags[i][0]
        if c == "n" then
          @nounMorphemes << morphemes[j]
          @nounTags << tags[j]
        elsif c == "f" then
          @nounMorphemes << morphemes[j]
          @nounTags << "ncn"
        end
      end

      eojeols[i].set_morphemes(@nounMorphemes)
      eojeols[i].set_tags(@nounTags)
    end

    st.set_eojeols(eojeols)

		return st
	end
end
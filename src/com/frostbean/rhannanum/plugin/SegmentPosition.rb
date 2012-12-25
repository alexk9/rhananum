
#This class is for segmentation of morphemes in a given eojeol.
class SegmentPosition
	#This class marks the position of segmentation.
  class Position
    attr_accessor :key, :state, :nextPosition, :sIndex, :uIndex, :nIndex, :morphCount, :morpheme
		def initialize
      #the consonant or vowel of this position */
      @key = 0;
      # the processing state */
      @state;
      # the index of next segment position */
      @nextPosition;
      #the temporary index for system dictionary */
      @sIndex;
      #the temporary index for user dictionary */
      @uIndex;
      #the temporary index for number dictionary */
      @nIndex;
      #the number of morphemes possible at this position */
      @morphCount;
      #the list of morphemes possible at this position */
      @morpheme = Array.new(MAX_MORPHEME_COUNT)
    end
	end

	# the maximum number of segmentation */
	MAX_SEGMENT = 1024;

	# the maximum number of morphemes possible */
	MAX_MORPHEME_COUNT = 512;

	# the processing state - dictionary search */
	SP_STATE_N = 0;

	# the processing state - expansion regarding phoneme change phenomenon */
	SP_STATE_D = 1;

	# the processing state - recursive processing */
	SP_STATE_R = 2;

	# the processing state - connection rule */
	SP_STATE_M = 3;

	# the processing state - failure */
	SP_STATE_F = 4;

	# the key of the start node for data structure */
	POSITION_START_KEY = 0;

	def initialize
    @positionEnd = 0;
		@position = Array.new(MAX_SEGMENT){Position.new}
	end

  def add_position(key)
		@position[@positionEnd].key = key;
		@position[@positionEnd].state = SP_STATE_N;
		@position[@positionEnd].morphCount = 0;
		@position[@positionEnd].nextPosition = 0;
		@position[@positionEnd].sIndex = 0;
		@position[@positionEnd].uIndex = 0;
		@position[@positionEnd].nIndex = 0;
    ret_val = @positionEnd
    @positionEnd+=1
		return ret_val
	end

	def get_position( index)
		return @position[index]
	end

	def init( str,  simti)
		prevIndex = 0;
		nextIndex = 0;

		positionEnd = 0;
		prevIndex = add_position(POSITION_START_KEY);
		position[prevIndex].state = SP_STATE_M;

		rev = "";

		for i in (str.length() - 1)..0 do
			rev += str[i]
		end

		for i in 0..(str.length()-1) do
			c = str[i]
			nextIndex = add_position(c);
			set_position_link(prevIndex, nextIndex);
			prevIndex = nextIndex;

			simti.insert(rev[0, str.length() - i],nextIndex);
		end

		#for marking the end of the eojeol */
		set_position_link(prevIndex, 0)
	end

	def next_position( index)
		return position[index].nextPosition;
	end


	def print_position()
		#System.err.println("positionEnd: " + positionEnd);
		#for (int i = 0; i < positionEnd; i++) {
		#	System.err.format("position[%d].key=%c nextPosition=%d\n", i, Code
		#			.toCompatibilityJamo(position[i].key),
		#			position[i].nextPosition);
		#}
	end


	def set_position_link( prevIndex,  nextIndex)
		position[prevIndex].nextPosition = nextIndex;
		return prevIndex;
	end
end
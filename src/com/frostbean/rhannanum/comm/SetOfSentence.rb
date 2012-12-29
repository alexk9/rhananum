# * This class represents the set of sentences that were results of the morphological analysis
# * about a input sentence. Each eojeol has more than one morphological analysis result which consists of
# * a morpheme list and their tags. So a morphologically analyzed sentence is a sequence of
# * analysis result of each eojeol. For example, <br>
# *
# * <table>
# * <tr><td>나는</td>						<td>학교에</td>					<td>간다.</td></tr>
# * <tr><td>-------------------------</td><td>-------------------------</td><td>-------------------------</td></tr>
# * <tr><td>나/ncn+는/jxc</td>			<td>학교/ncn+에/jca</td>			<td>갈/pvg+ㄴ다/ef+./sf</td></tr>
# * <tr><td>나/npp+는/jxc</td>			<td></td>						<td>가/pvg+ㄴ다/ef+./sf</td></tr>
# * <tr><td>나/pvg+는/etm</td>			<td></td>						<td>가/px+ㄴ다/ef+./sf</td></tr>
# * <tr><td>나/px+는/etm</td>				<td></td>						<td></td></tr>
# * <tr><td>나/pvg+아/ecs+는/jxc</td>		<td></td>						<td></td></tr>
# * <tr><td>나/pvg+아/ef+는/etm</td>		<td></td>						<td></td></tr>
# * <tr><td>나/px+아/ecs+는/jxc</td>		<td></td>						<td></td></tr>
# * <tr><td>나/px+아/ef+는/etm</td>		<td></td>						<td></td></tr>
# * <tr><td>날/pvg+는/etm</td>			<td></td>						<td></td></tr>
# * </table>
# * <br>
# * In this example, there are 9 x 1 x 3 = 27 morphologically analyzed sentences.<br>

class SetOfSentences < CommObject
  attr_accessor :length

	def initialize( documentID, sentenceID, endOfDocument, plainEojeolArray, eojeolSetArray)
	  #The number of eojeols.
	  @length = 0
    #The array of the morphologically analyzed eojeol lists.
	  @eojeolSetArray = []
    #The array of the plain eojeols.
	  @plainEojeolArray = []

		@document_id = documentID
		@sentence_id = sentenceID
		@end_of_document = endOfDocument

    if eojeolSetArray != nil then
      @length = eojeolSetArray.size
      @eojeolSetArray = eojeolSetArray
    end

    if plainEojeolArray != nil then
      @plainEojeolArray = plainEojeolArray
    end
  end

	def get_plain_eojeol_array()
		return @plainEojeolArray
	end

	def set_plain_eojeol_array( plainEojeolArray)
		@plainEojeolArray = plainEojeolArray
	end

	def add_plain_eojeol( eojeol)
		return @plainEojeolArray << eojeol
	end

	def add_eojeol_set( eojeols)
		return @eojeolSetArray<<(eojeols)
	end

	def get_eojeol_set_array()
		return @eojeolSetArray
	end

	def set_eojeol_set_array( eojeolSetArray)
		@eojeolSetArray = eojeolSetArray;
	end

	#
	#Returns the string representation of the morphologically analyzed sentences.
	#For example,
	#
	#	나는
	#		나/ncn+는/jxc
	#		나/npp+는/jxc
	#		나/pvg+는/etm
	#		나/px+는/etm
	#		나/pvg+아/ecs+는/jxc
	#		나/pvg+아/ef+는/etm
	#		나/px+아/ecs+는/jxc
	#		나/px+아/ef+는/etm
	#		날/pvg+는/etm
	#
	#	학교에
	#		학교/ncn+에/jca
	#
	#	간다.
	#		갈/pvg+ㄴ다/ef+./sf
	#		가/pvg+ㄴ다/ef+./sf
	#		가/px+ㄴ다/ef+./sf
	#
	#
	def to_s()
		#String str = "";
		#for (int i = 0; i < length; i++) {
		#	str += plainEojeolArray.get(i) + "\n";
		#	Eojeol[] eojeolArray = eojeolSetArray.get(i);
		#	for (int j = 0; j < eojeolArray.length; j++) {
		#		str += "\t" + eojeolArray[j] + "\n";
		#	}
		#	str += "\n";
		#}
		#return str;
	end
end
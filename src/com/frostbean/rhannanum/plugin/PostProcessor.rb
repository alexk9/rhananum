#encoding:utf-8
#This class is for post processing of morphological analysis.
 
class PostProcessor 
  def initialize 
    # the triple character representation of '하' */
    @HA = nil;
    # the triple character representation of '아' */
    @AR = nil;
    # the triple character representation of '어' */
    @A_ = nil;
    # the triple character representation of 'ㅏㅑㅗ' */
    @PV = nil;
    # the triple character representation of '끄뜨쓰크트' */
    @XEU = nil;
    # the triple character representation of '돕' */
    @DOB = nil;
    # the triple character representation of '곱' */
    @GOB = nil;
    # the triple character representation of '으' */
    @EU = nil;
    # the triple character representation of '습니' */
    @SU = nil;
    # the triple character representation of '는다' */
    @NU = nil;

		@HA = Code.to_triple_string("하");
		@AR = Code.to_triple_string("아");
		@A_ = Code.to_triple_string("어");
		@PV = Code.to_triple_string("ㅏㅑㅗ");
		@XEU = Code.to_triple_string("끄뜨쓰크트");
		@DOB = Code.to_triple_string("돕");
		@GOB = Code.to_triple_string("곱");
		@EU = Code.to_triple_string("으");
		@SU = Code.to_triple_string("습니");
		@NU = Code.to_triple_string("는다");
	end
	
	def do_post_processing(sos)
		eojeolSetArray = sos.get_eojeol_set_array();

    for eojeolSet in eojeolSetArray do
			prevMorph = "";
			
			for i in 0..(eojeolSet.length-1) do
				eojeol = eojeolSet[i]
				morphemes = eojeol.get_morphemes()
				tags = eojeol.get_tags();
				puts "#{eojeol}@do_post_processing"
        puts "morphemes:#{morphemes.to_s}@do_post_processing"
				for j in 0..(eojeol.length-1) do
					tri = Code.to_triple_string(morphemes[j]);
					if (tags[j].index("e")==0) then
						prevLen = prevMorph.length()
						
						if (tri.startsWith(A_)) then		#* 어 -> 아 */
							if (prevLen >= 4 && prevMorph.charAt(prevLen-1) == EU.charAt(1) && !isXEU(prevMorph.charAt(prevLen-2)) && ((Code.isJungseong(prevMorph.charAt(prevLen-3)) && isPV(prevMorph.charAt(prevLen-3))) || (Code.isJongseong(prevMorph.charAt(prevLen-3)) && isPV(prevMorph.charAt(prevLen-4))))) then
								morphemes[j] = Code.to_string(AR.toCharArray());
							elsif (prevLen >= 3 && prevMorph.charAt(prevLen-1) == DOB.charAt(2) && (prevMorph.substring(prevLen-3).equals(DOB) == false || prevMorph.substring(prevLen-3).equals(GOB) == false)) then
								#for 'ㅂ' irregular */
							elsif (prevLen>=2 && prevMorph.substring(prevLen-2).equals(HA)) then
							elsif (prevLen>=2 && ( (Code.isJungseong(prevMorph.charAt(prevLen-1)) && isPV(prevMorph.charAt(prevLen-1))) || (Code.isJongseong(prevMorph.charAt(prevLen-1)) && isPV(prevMorph.charAt(prevLen-2))) )) then
								morphemes[j] = Code.toString(AR.toCharArray());
							end
						elsif (tri.startsWith(EU.substring(0, 2)) || tri.startsWith(SU.substring(0, 4)) || tri.startsWith(NU.substring(0, 4))) then
							# elision of '으', '스', '느' */
							if (prevLen >= 2 && (Code.isJungseong(prevMorph.charAt(prevLen-1)) || prevMorph.charAt(prevLen-1) == 0x11AF)) then
								morphemes[j] = Code.toString(tri.substring(2).toCharArray());
							end
						end
					end
					
					prevMorph = Code.to_triple_string(morphemes[j]);
				end
			end
		end

		return sos;
	end

  def is_PV?(c)
		if (@PV.index(c) == nil) then
			return false;
		end
		return true;
	end

  def is_XEU?( c)
		if (XEU.index(c) == nil) then
			return false;
		end
		return true;
	end
end

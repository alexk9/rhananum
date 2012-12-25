#encoding:utf-8

require "com/frostbean/rhannanum/plugin/SegmentPosition"
require "com/frostbean/rhannanum/plugin/Exp"
 #* This class is for the lattice style morpheme chart which is a internal data structure for morphological analysis without backtracking.
class MorphemeChart 
	#A morpheme node in the lattice style chart.
	class Morpheme
    attr_accessor :tag, :phoneme, :nextPosition, :state, :connectionCount, :connection, :str
    def initialize
      #morpheme tag */
      @tag = 0
      # phoneme */
      @phoneme =0  
      #the index of the next node */
      @nextPosition = 0
      #the type of the next morpheme */
      @nextTagType = 0
      #the state of current processing */
      @state = 0
      #the number of morphemes connected */
      @connectionCount = 0
      #the list of the morphemes connected */
      @connection = Array.new(MAX_MORPHEME_CONNECTION)
      # plain string */
      @str = ""
    end
	end
	
	# the reserved word for replacement of Chinese characters */
	CHI_REPLACE = "HAN_CHI"
	
	#the reserved word for replacement of English alphabets */
	ENG_REPLACE = "HAN_ENG"
	
	#the maximum number of connections between one morpheme and others */
	MAX_MORPHEME_CONNECTION = 30;
	
	#the maximum number of morpheme nodes in the chart */
	MAX_MORPHEME_CHART = 2046;
	
	#the processing state - incomplete */
	MORPHEME_STATE_INCOMPLETE = 2;

	#the processing state - success */
	MORPHEME_STATE_SUCCESS = 1;

	# the maximum number of analysis results */
	MAX_CANDIDATE_NUM = 100000;
	
	# the processing state - fail */
	MORPHEME_STATE_FAIL = 0;
	
	def initialize(tagSet, connection, systemDic, userDic, numDic, simti, resEojeolList) 
    	#the list for the replacement of Chinese character */
	    @chiReplacementList = nil
	
	    #the list for the replacement of English alphabets */
	    @engReplacementList = nil;
	
	    #the index for replacement of English alphabets */
	    @engReplaceIndex = 0;
	
	    #the index for replacement of Chinese characters */
	    @chiReplaceIndex = 0;
	
      #the morpheme chart */
      @chart = nil;

      #the last index of the chart */
      @chartEnd = 0;

      #the morpheme tag set */
      @tagSet = nil;

      #the connection rules */
      @connection = nil;

      #segment position */
      @sp = nil;

      #string buffer */
      @bufString = "";

      # path of segmentation */
      @segmentPath = Array.new(SegmentPosition::MAX_SEGMENT)

      # chart expansion */
      exp = nil;

      #system morpheme dictionary */
      @systemDic = nil;

      #user morpheme dictionary */
      @userDic = nil;

      #number dictionary - automata */
      @numDic = nil;

      #SIMple Trie Index */
      @simti = nil;

      #the number of analysis results printed */
      @printResultCnt = 0;

      #the list of eojeols analyzed */
      @resEojeols = nil;

      #the list of morphemes analyzed */
      @resMorphemes = nil;

      #the list of morpheme tags analyzed */
      @resTags = nil;

      @chart = Array.new(MAX_MORPHEME_CHART)
      for i in 0..(MAX_MORPHEME_CHART-1) do
        @chart[i] = Morpheme.new
      end

      @sp = SegmentPosition.new
      @tagSet = tagSet;
      @connection = connection;
      @exp = Exp.new(self, tagSet);
      @systemDic = systemDic;
      @userDic = userDic;
      @numDic = numDic;
      @simti = simti;
      @resEojeols = resEojeolList;

      @resMorphemes = []
      @resTags = []

      @chiReplacementList = []
      @engReplacementList = []
	end
	
	#Adds a new morpheme to the chart.
	def add_morpheme(tag, phoneme, nextPosition, nextTagType)
		@chart[@chartEnd].tag = tag;
		@chart[@chartEnd].phoneme = phoneme;
		@chart[@chartEnd].nextPosition = nextPosition;
		@chart[@chartEnd].nextTagType = nextTagType;
		@chart[@chartEnd].state = MORPHEME_STATE_INCOMPLETE;
		@chart[@chartEnd].connectionCount = 0;
    ret_val = @chartEnd
    @chartEnd+=1;
    return ret_val
	end
	
   #It inserts the reverse of the given string to the SIMTI data structure.
  def alt_segment(str)
    prev = 0;
    next_n = 0;
    match = 0
    len= 0
    to=0

    len = str.length();

    rev = "";
    for i in (len - 1)..0 do
      rev += str[i]
    end

    revStrArray = rev

    match = simti.search(revStrArray);
    to = simti.fetch(rev[0, match])

    for i in 0..(str.length()-1) do
      if (len <= match) then
        break
      end
      next_n = sp.add_position(str[i]);
      if (prev != 0) then
        sp.set_positionLink(prev, next_n)
      end

      simti.insert(rev[0, len], next_n);
      prev = next_n;
      len-=1
    end

    if (prev != 0) then
      sp.set_position_link(prev, to);
    end

    return simti.fetch(revStrArray);
  end

 #It performs morphological analysis on the morpheme chart constructed.
  def analyze()
    res = 0

    res = analyze(0, TagSet::TAG_TYPE_ALL)

    if (res > 0) then
      return res;
    else
      return analyze_unknown();
    end
  end
	
	# It performs morphological anlysis on the morpheme chart from the specified index in the chart.
	def analyze_with_index_type(chartIndex, tagType)
		from, to =0,0
		i,j,x, y =0,0,0,0
		mp=0
		 c=0
		nc_idx=0
		node=nil
		infoList = nil
		info = nil;
		
		sidx = 1;
		uidx = 1;
		nidx = 1;
		fromPos = nil;
		toPos = nil;
		morph = Array.new(chartIndex)
		from = morph.nextPosition;
		fromPos = sp.getPosition(from);

    case sp.get_position(from).state
		  #dictionary search */
      when SegmentPosition.SP_STATE_N then
        i = 0;
        bufString = "";

        # searches all combinations of words segmented through the dictionaries
        to = from
        while to != SegementPosition::POSITION_START_KEY do
          toPos = sp.get_position(to);
          c = toPos.key;

          if (sidx != 0) then
            sidx = systemDic.node_look(c, sidx);
          end
          if (uidx != 0) then
            uidx = userDic.node_look(c, uidx);
          end
          if (nidx != 0) then
            nidx = numDic.node_look(c, nidx);
          end

          toPos.sIndex = sidx;
          toPos.uIndex = uidx;
          toPos.nIndex = nidx;

          bufString += c;
          segmentPath[i] = to;
          i+=1
          to = sp.next_position(to)
        end

        nidx = 0

        while i>0 do
          to = segmentPath[i-1];
          toPos = sp.get_position(to);

          # system dictionary
          if (toPos.sIndex != 0) then
            node = systemDic.get_node(toPos.sIndex);
            if ((infoList = node.info_list) != nil) then
              for j in 0..(infoList.size()-1) do

                info = infoList[j]
                nc_idx = add_morpheme(info.tag, info.phoneme, sp.next_position(to), 0);
                @chart[nc_idx].str = bufString[0, i]
                fromPos.morpheme[fromPos.morphCount] = nc_idx;
                fromPos.morphCount+=1
              end
            end
          end

          #user dictionary
          if (toPos.uIndex != 0) then
            node = userDic.get_node(toPos.uIndex);
            if ((infoList = node.info_list) != nil) then
              for i in 0..(infoList.size-1) do

                info = infoList[j]
                nc_idx = add_morpheme(info.tag, info.phoneme, sp.next_position(to), 0)
                @chart[nc_idx].str = bufString.substring(0, i);
                fromPos.morpheme[fromPos.morphCount] = nc_idx;
                fromPos.morphCount+=1
              end
            end
          end

          #number dictionary
          if (nidx == 0 && toPos.nIndex != 0) then
            if (numDic.isNum(toPos.nIndex)) then
              nc_idx = add_morpheme(tagSet.numTag, TagSet::PHONEME_TYPE_ALL, sp.next_position(to), 0)
              @chart[nc_idx].str = bufString[0, i]
              fromPos.morpheme[fromPos.morphCount] = nc_idx;
              fromPos.morphCount+=1
              nidx = toPos.nIndex
            else
              nidx = 0;
            end
          end
          i-=1
        end

        fromPos.state = SegmentPosition::SP_STATE_D;
        # chart expansion regarding various rules */
        #case SegmentPosition.SP_STATE_D:
        exp.prule(from, morph.str, bufString, sp);
        sp.get_position(from).state = SegmentPosition::SP_STATE_R;

        # recursive processing */
        #case SegmentPosition.SP_STATE_R:
        x = 0;
        for i in 0..(fromPos.morphCount-1) do
          mp = fromPos.morpheme[i];

          #It prevents a recursive call for '습니다', which needs to be improved.
          if (tagSet.check_tag_type(tagType, chart[mp].tag) == false) then
            next
          end

          #It prevents some redundant processing
          if (chart[mp].state == MORPHEME_STATE_INCOMPLETE) then
            y = analyze_with_index_type(mp, chart[mp].nextTagType);
            x += y;

            if (y != 0) then
              chart[mp].state = MORPHEME_STATE_SUCCESS;
            else
              chart[mp].state = MORPHEME_STATE_FAIL;
            end
          else
            x += chart[mp].connectionCount;
          end
        end

        if (x == 0) then
          if (tagType == TagSet::TAG_TYPE_ALL) then
            fromPos.state = SegmentPosition.SP_STATE_F;
          end
          return 0;
        end

        if (tagType == TagSet::TAG_TYPE_ALL)  then
          fromPos.state = SegmentPosition::SP_STATE_M;
        end


        # connecton rule */
        #case SegmentPosition.SP_STATE_M:
        for i in 0..(fromPos.morphCount-1) do
          mp = fromPos.morpheme[i];

          if (chart[mp].state == MORPHEME_STATE_SUCCESS && connection.checkConnection(tagSet,morph.tag,chart[mp].tag,morph.str.length(),chart[mp].str.length(),morph.nextTagType)) then
            morph.connection[morph.connectionCount] = mp;
            morph.connectionCount+=1
          end
        end
		  #chart expansion regarding various rules */
      when SegmentPosition::SP_STATE_D then
        exp.prule(from, morph.str, bufString, sp);
        sp.get_position(from).state = SegmentPosition::SP_STATE_R;

        # recursive processing */
        #case SegmentPosition.SP_STATE_R:
        x = 0;
        for i in 0..(fromPos.morphCount-1) do
          mp = fromPos.morpheme[i];

          #It prevents a recursive call for '습니다', which needs to be improved.
          if (tagSet.check_tag_type(tagType, chart[mp].tag) == false) then
            next
          end

          #It prevents some redundant processing
          if (chart[mp].state == MORPHEME_STATE_INCOMPLETE) then
            y = analyze_with_index_type(mp, chart[mp].nextTagType);
            x += y;

            if (y != 0) then
              chart[mp].state = MORPHEME_STATE_SUCCESS;
            else
              chart[mp].state = MORPHEME_STATE_FAIL;
            end
          else
            x += chart[mp].connectionCount;
          end
        end

        if (x == 0) then
          if (tagType == TagSet::TAG_TYPE_ALL) then
            fromPos.state = SegmentPosition.SP_STATE_F;
          end
          return 0;
        end

        if (tagType == TagSet::TAG_TYPE_ALL)  then
          fromPos.state = SegmentPosition::SP_STATE_M;
        end


        # connecton rule */
        #case SegmentPosition.SP_STATE_M:
        for i in 0..(fromPos.morphCount-1) do
          mp = fromPos.morpheme[i];

          if (chart[mp].state == MORPHEME_STATE_SUCCESS && connection.checkConnection(tagSet,morph.tag,chart[mp].tag,morph.str.length(),chart[mp].str.length(),morph.nextTagType)) then
            morph.connection[morph.connectionCount] = mp;
            morph.connectionCount+=1
          end
        end

		#recursive processing */
        when SegementPosition::SP_STATE_R then
        x = 0;
        for i in 0..(fromPos.morphCount-1) do
          mp = fromPos.morpheme[i];

          #It prevents a recursive call for '습니다', which needs to be improved.
          if (tagSet.check_tag_type(tagType, chart[mp].tag) == false) then
            next
          end

          #It prevents some redundant processing
          if (chart[mp].state == MORPHEME_STATE_INCOMPLETE) then
            y = analyze_with_index_type(mp, chart[mp].nextTagType);
            x += y;

            if (y != 0) then
              chart[mp].state = MORPHEME_STATE_SUCCESS;
            else
              chart[mp].state = MORPHEME_STATE_FAIL;
            end
          else
            x += chart[mp].connectionCount;
          end
        end

        if (x == 0) then
          if (tagType == TagSet::TAG_TYPE_ALL) then
            fromPos.state = SegmentPosition.SP_STATE_F;
          end
          return 0;
        end

        if (tagType == TagSet::TAG_TYPE_ALL)  then
          fromPos.state = SegmentPosition::SP_STATE_M;
        end


        # connecton rule */
        #case SegmentPosition.SP_STATE_M:
        for i in 0..(fromPos.morphCount-1) do
          mp = fromPos.morpheme[i];

          if (chart[mp].state == MORPHEME_STATE_SUCCESS && connection.checkConnection(tagSet,morph.tag,chart[mp].tag,morph.str.length(),chart[mp].str.length(),morph.nextTagType)) then
            morph.connection[morph.connectionCount] = mp;
            morph.connectionCount+=1
          end
        end

    		#connecton rule */
        when  SegmentPosition::SP_STATE_M then
          for i in 0..(fromPos.morphCount-1) do
              mp = fromPos.morpheme[i];

              if (chart[mp].state == MORPHEME_STATE_SUCCESS && connection.checkConnection(tagSet,morph.tag,chart[mp].tag,morph.str.length(),chart[mp].str.length(),morph.nextTagType)) then
                morph.connection[morph.connectionCount] = mp;
                morph.connectionCount+=1
              end
          end
        else
          return 0;
		end
		return morph.connectionCount;
	end

	#It segments all phonemes, and tags 'unknown' to each segment, and then performs chart analysis,
	def analyze_unknown()
		i =0;
		nc_idx =0
		
		bufString = ""
		
		pos_1 = sp.get_position(1);

    i =1
    while i!=0 do
      pos = sp.get_position(i);
      bufString += pos.key;

			nc_idx = add_morpheme(tagSet.unkTag, TagSet::PHONEME_TYPE_ALL, sp.next_position(i), TagSet::TAG_TYPE_ALL)
			chart[nc_idx].str = bufString;

			pos_1.morpheme[pos_1.morphCount] = nc_idx;
      pos_1.morphCount+=1
			pos_1.state = SegmentPosition.SP_STATE_R;
      i = sp.next_position(i)
    end

		chart[0].connectionCount = 0;
		
		return analyze_with_index_type(0, 0);
	end
	
	#Checks the specified morpheme is exist in the morpheme chart.
	def check_chart(morpheme, morphemeLen, tag, phoneme, nextPosition, nextTagType, str)
		for i in 0..(morphemeLen-1) do
			morph = chart[morpheme[i]];
			if (morph.tag == tag &&
					morph.phoneme == phoneme &&
					morph.nextPosition == nextPosition &&
					morph.nextTagType == nextTagType &&
					morph.str == str) then
				return true;
			end
    end
		return false;
	end
	
	# Generates the morphological analysis result based on the morpheme chart where the analysis is performed.
	def get_result()
		printResultCnt = 0;
		print_chart(0);
	end

	#Initializes the morpheme chart with the specified word.
	def init(word)
		simti.init();
		word = pre_replace(word);
		sp.init(Code.to_triple_string(word), simti)
		
		chartEnd = 0;
		p = sp.get_position(0);
		p.morpheme[p.morphCount] = chartEnd;
    p.morphCount+=1
		chart[chartEnd].tag = tagSet.iwgTag;
		chart[chartEnd].phoneme = 0;
		chart[chartEnd].nextPosition = 1;
		chart[chartEnd].nextTagType = 0;
		chart[chartEnd].state = MORPHEME_STATE_SUCCESS;
		chart[chartEnd].connectionCount = 0;
		chart[chartEnd].str = "";
		chartEnd+=1;
	end
	
	#It expands the morpheme chart to deal with the phoneme change phenomenon.
	def phoneme_change(from, front, back, ftag, btag, phoneme)
		node = nil;
		size = 0;
		x, y =false,false
		next_n =0
		nc_idx =0
		
		# searches the system dictionary for the front part
		node = systemDic.fetch(front)
		if (node != nil && node.info_list != nil)  then
			size = node.info_list.size();
		end
		
		pos = sp.get_position(from)
		
		for i in 0..(size-1) do
			info = node.info_list[i]

			#comparison of the morpheme tag of the front part
			x = tagSet.check_tag_type(ftag, info.tag)
			
			# comparison of the phoneme of the front part
			y = tagSet.check_phoneme_type(phoneme, info.phoneme);
			
			if (x && y) then
				next_n = alt_segment(back);
				
				if (checkChart(pos.morpheme, pos.morphCount, info.tag, info.phoneme, next_n, btag, front) == false)  then
					nc_idx = add_morpheme(info.tag, info.phoneme, next_n, btag)
					chart[nc_idx].str = front;
					pos.morpheme[pos.morphCount] = nc_idx;
          pos.morphCount+=1
				else
					pus "phonemeChange: exit"
					exit
				end
			end
		end
	end
	
	#It generates the final mophological analysis result from the morpheme chart.
	def print_chart(chartIndex)
		morph = @chart[chartIndex];
		engCnt = 0;
		chiCnt = 0;

		if (chartIndex == 0) then
			for i in 0..(morph.connectionCount-1) do
				resMorphemes.clear();
				resTags.clear();
				printChart(morph.connection[i]);
			end
		else
			morphStr = Code.to_string(morph.str)
			idx = 0;
			engCnt = 0;
			chiCnt = 0;
			while (idx != -1) do
				if ((idx = morphStr.index(ENG_REPLACE)) != -1) then
					engCnt+=1
					morphStr = morphStr.replace_first(ENG_REPLACE, engReplacementList.get(engReplaceIndex));
          engReplaceIndex+=1
				elsif ((idx = morphStr.index(CHI_REPLACE)) != -1) then
					chiCnt+=1
					morphStr = morphStr.replace_first(CHI_REPLACE, chiReplacementList.get(chiReplaceIndex));
          chiReplaceIndex+=1
				end
			end
			
			resMorphemes.add(morphStr);
			resTags.add(tagSet.get_tag_name(morph.tag));

			i=0
      while i < morph.connectionCount && printResultCnt < MAX_CANDIDATE_NUM do
        if (morph.connection[i] == 0) then
					mArray = resMorphemes
					tArray = resTags
					resEojeols.add(Eojeol.new(mArray, tArray));

					printResultCnt+=1
				else
					printChart(morph.connection[i]);
				end
        i+=1
      end

			
			resMorphemes.remove(resMorphemes.size() - 1);
			resTags.remove(resTags.size() - 1);
			if (engCnt > 0) then
				engReplaceIndex -= engCnt;
			end
			if (chiCnt > 0) then
				chiReplaceIndex -= chiCnt;
			end
		end
	end
	
	#It prints the all data in the chart to the console.
  def print_morpheme_all()
		# System.err.println("chartEnd: " + chartEnd);
		#for (int i = 0; i < chartEnd; i++) {
		#	System.err.println("chartID: " + i);
		#	System.err.format("%s/%s.%s nextPosition=%c nextTagType=%s state=%d ",
		#			Code.toString(chart[i].str.toCharArray()),
		#			tagSet.getTagName(chart[i].tag),
		#			tagSet.getIrregularName(chart[i].phoneme),
		#			Code.toCompatibilityJamo(sp.getPosition(chart[i].nextPosition).key),
		#			tagSet.getTagName(chart[i].nextTagType),
		#			chart[i].state);
		#	System.err.print("connection=");
		#	for (int j = 0; j < chart[i].connectionCount; j++) {
		#		 System.err.print(chart[i].connection[j] + ", ");
		#	}
		#	System.err.println();
		#}
	end
	
	#Replaces the English alphabets and Chinese characters in the specified string with the reserved words.
  def pre_replace(str)
		result = "";
		engFlag = false;
		chiFlag = false;
		buf = "";
		
		engReplacementList.clear();
		chiReplacementList.clear();
		engReplaceIndex = 0;
		chiReplaceIndex = 0;

		for i in 0..(str.length()-1) do
			c = str[i]

			if (((c >= 'a' && c <= 'z') || c >= 'A' && c <= 'Z')) then
				# English Alphabets */
				if (engFlag) then
					buf += c;
				else
					if (engFlag) then
						engFlag = false;
						engReplacementList.add(buf);
						buf = "";
					end
					result += ENG_REPLACE;
					buf += c;
					engFlag = true;
				end

			elsif (((c >= 0x2E80 && c <= 0x2EFF) || (c >= 0x3400 && c <= 0x4DBF)) || (c >= 0x4E00 && c < 0x9FBF) ||
					(c >= 0xF900 && c <= 0xFAFF) && chiFlag) then
				# Chinese Characters */
				if (chiFlag) then
					buf += c;
				else
					if (chiFlag) then
						chiFlag = false;
						chiReplacementList.add(buf);
						buf = "";
					end
					result += CHI_REPLACE;
					buf += c;
					chiFlag = true;
				end
			else
				result += c;
				if (engFlag) then
					engFlag = false;
					engReplacementList.add(buf);
					buf = "";
				end
				if (chiFlag) then
					chiFlag = false;
					chiReplacementList.add(buf);
					buf = "";
				end
			end
		end
		if (engFlag) then
			engReplacementList.add(buf);
		end
		if (chiFlag) then
			chiReplacementList.add(buf);
		end
		return result;
	end
end

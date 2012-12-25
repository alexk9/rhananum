class TagSet
  #KAIST tag set */
  TAG_SET_KAIST = 0

  # tag type - all */
  TAG_TYPE_ALL = 0

  #/** tag type - verb */
  TAG_TYPE_VERBS = 1

  #/** tag type - noun */
  TAG_TYPE_NOUNS = 2

  #/** tag type - pronoun */
  TAG_TYPE_NPS = 3

  #/** tag type - adjective */
  TAG_TYPE_ADJS = 4

  #/** tag type - bound noun */
  TAG_TYPE_NBNP = 5

  #/** tag type - josa(particle) */
  TAG_TYPE_JOSA = 6

  #/** tag type - yongeon(verb, adjective) */
  TAG_TYPE_YONGS = 7

  #/** tag type - eomi(ending) */
  TAG_TYPE_EOMIES = 8

  #/** tag type - predicative particle */
  TAG_TYPE_JP = 9

  #/** the number of tag types */
  TAG_TYPE_COUNT = 10

  #/** phoneme type - all */
  PHONEME_TYPE_ALL = 0

  def initialize
    #/** the name of tag set */
    @title = ""
    #/** the version of tag set */
    @version = ""
		@copyright = "";
		@author = "";
		@date = "";
		@editor = "";
		@tagList = []
		@irregularList = []
		@tagSetMap = {}
		@tagTypeTable = Array.new(TAG_TYPE_COUNT)


    @indexTags = nil
    #the list of unknown tags */
    @unkTags = nil
    #the start tag */
    @iwgTag = 0
    #the unknown tag */
    @unkTag = 0
    #the number tag */
    @numTag = 0

    # 'ㅂ' irregular */
    @irr_type_b = nil

    #'ㅅ' irregular */
    @irr_type_s = nil

    #'ㄷ' irregular */
    @irr_type_d = nil

    #'ㅎ' irregular */
    @irr_type_h = nil

    # '르' irregular */
    @irr_type_reu = nil

    # '러' irregular */
    @irr_type_reo = nil

  end

	def check_phoneme_type(phonemeType, phoneme)
    if phonemeType == PHONEME_TYPE_ALL then
      return true
    end

    return phonemeType == phoneme
  end

  def check_tag_type(tagType, tag)
    if tagType == TAG_TYPE_ALL then
      return true
    end

    for i in 0..(@tagTypeTable[tagType].length-1) do
      if @tagTypeTable[tagType][i] == tag then
        return true
      end
    end

    return false
  end

  def clear
    @title = ""
    @version = ""
    @copyright = ""
    @author = ""
    @date = ""
    @editor = ""
    @tagList.clear()
    @irregularList.clear()
    @tagSetMap.clear()
  end

  def get_irregular_id(irregular)
    return @irregularList.index(irregular)
  end

	def get_irregular_name(irregularID)
    return @irregularList[irregularID]
  end

	def get_tag_count()
    return @tagList.size
  end

  def get_tag_id(tag)
    return @tagList.index(tag)
  end

  def get_tag_name(tagID)
    return @tagList[tagID]
  end

  def get_tags(tagSetName)
    return @tagSetMap[tagSetName]
  end

  def init(filePath, tagSetFlag)
    f = File.open(filePath,"r:utf-8")


		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@tagList.clear()
		@irregularList.clear()
		@tagSetMap.clear()

		tempTagNumbers = []

    while f.eof? == false do
      line = f.readline()
      toks = line.split(/\t/)
      if toks.length == 0 then
        next
      end

      if toks[0].index("@") == 0 then
				if "@title" == toks[0] then
					@title = toks[1]
				elsif "@version" == toks[0] then
					@version = toks[1]
        elsif "@copyright" == toks[0] then
					@copyright = toks[1]
				elsif "@author" == toks[0] then
					@author = toks[1]
				elsif "@date" == toks[0] then
					@date = toks[1]
				elsif "@editor"== toks[0] then
					@editor = toks[1]
				end
      elsif toks[0] == "TAG" then
        @tagList << toks[1]
      elsif toks[0] == "TSET" then
        tagSetName = toks[1]

        tag_toks = toks[2].split(/ /)

        for tagToken in tag_toks do
          tagNumber = @tagList.index(tagToken.rstrip)

          if tagNumber != nil then
            tempTagNumbers << tagNumber
          else
            values = @tagSetMap[tagToken]
            if values != nil then
              for value in values
                tempTagNumbers << value
              end
            end
          end
        end

        tagNumbers = Array.new(tempTagNumbers.size)
        for i in 0..(tempTagNumbers.size-1) do
          tagNumbers[i] = tempTagNumbers[i]
        end
				@tagSetMap[tagSetName] = tagNumbers
        tempTagNumbers.clear
      elsif "IRR" == toks[0] then
        @irregularList << toks[1]
      end
    end

    set_tag_types(tagSetFlag)
    @indexTags = @tagSetMap["index"]
    @unkTags = @tagSetMap["unkset"]
    @iwgTag = @tagList.index("iwg")
    @unkTag = @tagList.index("unk")
    @numTag = @tagList.index("nnc")

    @irr_type_b = get_irregular_id("irrb")
    @irr_type_s = get_irregular_id("irrs")
    @irr_type_d = get_irregular_id("irrd")
    @irr_type_h = get_irregular_id("irrh")
    @irr_type_reu = get_irregular_id("irrlu")
    @irr_type_reo = get_irregular_id("irrle")
  end

	def set_tag_types(tagSetFlag)
    if tagSetFlag == TAG_SET_KAIST then
      list = []
      values = []

      #verb
      values = @tagSetMap["pv"]

      values.each {|a_value|
        list << a_value
        }

      values = @tagSetMap["xsm"]
      values.each {|a_value|
        list << a_value
      }

      list << @tagList.index("px")

      @tagTypeTable[TAG_TYPE_VERBS] = Array.new(list.size)

      for i in 0..(list.size-1) do
        @tagTypeTable[TAG_TYPE_VERBS][i] = list[i]
      end

			list.clear

			#noun
      @tagTypeTable[TAG_TYPE_NOUNS] = @tagSetMap["n"]

			# nps
			@tagTypeTable[TAG_TYPE_NPS] = @tagSetMap["np"]

			#adjs
			@tagTypeTable[TAG_TYPE_ADJS] = @tagSetMap["pa"]

			#eomies
			@tagTypeTable[TAG_TYPE_EOMIES] = @tagSetMap["e"]

			#yongs
			values = @tagSetMap["p"]
      values.each { |a_value|
        list << a_value
      }

			values = @tagSetMap["xsv"]
      values.each {|a_value|
        list << a_value
      }

			values = @tagSetMap["xsm"]
      values.each {|a_value|
        list << a_value
      }

			list << @tagList.index("ep")
			list << @tagList.index("jp")

			@tagTypeTable[TAG_TYPE_YONGS] = Array.new(list.size())
      for i in 0..(list.size-1) do
        @tagTypeTable[TAG_TYPE_YONGS][i] = list[i]
      end
			list.clear()

			# jp
			@tagTypeTable[TAG_TYPE_JP] = [@tagList.index("jp")]

			# nbnp
			@tagTypeTable[TAG_TYPE_NBNP] = [@tagList.index("nbn"),@tagList.index("npd"),@tagList.index("npp")]

			# josa
			@tagTypeTable[TAG_TYPE_JOSA] = [@tagList.index("jxc"), @tagList.index("jco"),@tagList.index("jca"),@tagList.index("jcm"),@tagList.index("jcs"),@tagList.index("jcc")]
    end
  end
end
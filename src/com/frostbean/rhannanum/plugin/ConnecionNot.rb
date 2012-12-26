require "log4r"

class ConnecionNot
	def initialize
    @obj_logger = Log4r::Logger["ObjectsLogger"]
		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@startTag = ""
	end

	def check_connection
    return true
  end

  def clear
		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@startTag = ""
		@ruleCount = 0
		@notTagTable = nil
		@notMorphTable = nil
	end

	def init(filePath, tagSet)
		read_file(filePath, tagSet)
    @obj_logger.debug "ConnectionNot Initialize."
    @obj_logger.debug "@title:#{@title}"

    for i in (0..@notMorphTable.size()-1) do
        @obj_logger.debug "@notMorphTable[#{i}]:#{@notMorphTable[i]}"
    end

    for i in (0..@notTagTable.size()-1) do
      @obj_logger.debug "@notTagTable[#{i}]:#{@notTagTable[i]}"
    end
	end

	def read_file(filePath, tagSet)
		f = File.open(filePath, "r:utf-8")
    line = ""
		ruleList = []

		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@startTag = ""
		@ruleCount = 0

    while f.eof? == false do
      line = f.readline
      lineTokenizer = line.split(/\t/)
		  if lineTokenizer.size == 0 then
        next
      end

			lineToken = lineTokenizer[0]

      if lineToken.index("@")==0 then
				if "@title"== lineToken then
					@title = lineTokenizer[1]
				elsif "@version"== lineToken then
					@version = lineTokenizer[1]
				elsif "@copyright"== lineToken then
					@copyright =  lineTokenizer[1]
				elsif "@author"== lineToken then
					@author =  lineTokenizer[1]
				elsif "@date"== lineToken then
					@date =  lineTokenizer[1]
				elsif "@editor"== lineToken then
					@editor =  lineTokenizer[1]
				end
			elsif "CONNECTION_NOT" == lineToken then
				ruleList <<  lineTokenizer[1]
			end
		end

		@ruleCount = ruleList.size
		@notTagTable= Array.new(@ruleCount){Array.new(2)}
    @notMorphTable = Array.new(@ruleCount){Array.new(2)}

    for i in 0..(ruleList.size-1) do
      rule = ruleList[i]
      st = rule.split(/ /)
      @notMorphTable[i][0] = st[0]
      @notTagTable[i][0] = tagSet.get_tag_id(st[1].rstrip)
      @notMorphTable[i][1] = st[2]
      @notTagTable[i][1] = tagSet.get_tag_id(st[3].rstrip)
    end
    ruleList.clear
	end
end

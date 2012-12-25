
##
# This class is for the connection rules of morphemes. It is used to check whether the morphemes
# can appear consecutively.

require "set"

class Connection
	def initialize
		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@startTag = ""
		@connectionTable = nil
  end
  # Checks whether two morpheme tags can appear consecutively.
  def check_connection(tagSet, tag1, tag2, len1,len2, typeOfTag2)
    tag1Name = tagSet.get_tag_name(tag1)
    tag2Name = tagSet.get_tag_name(tag2)

    if (tag1Name.index("nc") == 0 or tag1Name[0] =="f") and tag2Name[0]=="n" then
      if tag2Name.index("nq") == 0 then
        return false
      elsif len1<4 or len2 < 2 then
        return false
      end
    end

		return @connectionTable[tag1][tag2] && tagSet.check_tag_type(typeOfTag2, tag2)
  end

	def clear
		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@startTag = ""
		@connectionTable = nil
	end

	def init( filePath, tagCount, tagSet)
    read_file(filePath, tagCount, tagSet)
  end


  def read_file( filePath, tagCount, tagSet)
    tagSetA = Set.new
    tagSetB = Set.new

		@title = ""
		@version = ""
		@copyright = ""
		@author = ""
		@date = ""
		@editor = ""
		@startTag = ""
		@connectionTable = Array.new(tagCount){Array.new(tagCount)}

    for i in 0..(tagCount-1) do
      for j in 0..(tagCount-1) do
        @connectionTable[i][j] = false
			end
		end


    f = File.open(filePath.to_s, "r:utf-8")

    while f.eof? == false do
      line = f.readline
      tokens = line.split(/\t/)

      if tokens.size == 0 then
        next
      end

      lineToken = tokens[0]

			if lineToken.index("@")== 0 then
				if "@title"==lineToken then
					@title = tokens[1]
				elsif "@version"== lineToken then
					@version = tokens[1]
				elsif "@copyright"== lineToken then
					@copyright = tokens[1]
				elsif "@author"==lineToken then
					@author = tokens[1]
				elsif "@date"== lineToken then
					@date = tokens[1]
				elsif "@editor"== lineToken then
					@editor = tokens[1]
        end
      elsif "CONNECTION"== lineToken then
				lineToken = tokens[1]
        tagLists = lineToken.split(/\*/,2)

        tag_tokens = tagLists[0].split(/[,()]/)

        tag_tokens.each { |tagToken|
          tok = tagToken.split(/-/)
          for x in 0..(tok.size-1) do
            t = tok[x].rstrip
            fullTagIDSet = tagSet.get_tags(t)
            if fullTagIDSet != nil then
              for i in 0..(fullTagIDSet.size() -1) do
                tagSetA << fullTagIDSet[i]
              end
            else
              tagSetA << tagSet.get_tag_id(t)
            end

            for y in (x+1)..(tok.size()-1) do
              tagSetA.delete(tagSet.get_tag_id(tok[y]))
            end
            break
          end
        }

        tagTokenizer = tagLists[1].split(/[,()]/).delete_if{|item| item.empty?}

        for tagToken in tagTokenizer do
				  tok = tagToken.split(/-/).delete_if{|item| item.rstrip.empty?}
          for t_idx in 0..(tok.length-1) do
            t = tok[t_idx]
						fullTagIDSet = tagSet.get_tags(t);

						if (fullTagIDSet != nil) then
							for i in 0..(fullTagIDSet.length-1) do
								tagSetB << fullTagIDSet[i]
							end
						else
							tagSetB << tagSet.get_tag_id(t)
            end
            for t_idx2 in (t_idx+1)..(tok.length-1) do
							tagSetB.delete(tagSet.get_tag_id(tok[t_idx2]) )
            end
            #for t_idx2루프를끝내고나면 탈출한다.
            break
					end
				end


        for leftSide in tagSetA do
				  for b_side in tagSetB do
						@connectionTable[leftSide][b_side] = true;
					end
				end

				tagSetA.clear
				tagSetB.clear
			elsif ("START_TAG" == lineToken) then
				@startTag = tokens[1]
			end
		end
	end
end




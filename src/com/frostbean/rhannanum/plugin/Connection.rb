
##
# This class is for the connection rules of morphemes. It is used to check whether the morphemes
# can appear consecutively.

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

		String line = null;
  def read_file( filePath, tagCount, tagSet)
    tagSetA = {}
    tagSetB = {}

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


    f = File.open(filePath, "r:utf-8")

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
        tagLists = lineToken.split(/\\*/,2)

        tag_tokens = tagLists[0].split(/[,()]/)

        tag_tokens.each { |tagToken|
          tok = tagToken.split(/-/)
          for x in 0..(tok.size-1) do
            t = tok[x]
            fullTagIDSet = tagSet[t]
            if fullTagIDSet != nil then
              for i in 0..(fullTagIDSet.size -1) do
                tagSetA << fullTagIDSet[i]
              end
            else
              tagSetA << tagSet.get_tag_id(t)
            end

            for y in x..(tok.size-1) do
              tagSetA.delete(tagSet.get_tag_id(tok[y]))
              x = y
            end
          end
        }

        tagTokenizer = tagLists[1].split(/[,()]/)

        #
				#tagTokenizer = new StringTokenizer(tagLists[1], ",()");
				#while (tagTokenizer.hasMoreTokens()) {
				#	String tagToken = tagTokenizer.nextToken();
        #
				#	StringTokenizer tok = new StringTokenizer(tagToken, "-");
				#	while (tok.hasMoreTokens()) {
				#		String t = tok.nextToken();
				#		int[] fullTagIDSet = tagSet.getTags(t);
        #
				#		if (fullTagIDSet != null) {
				#			for (int i = 0; i < fullTagIDSet.length; i++) {
				#				tagSetB.add(fullTagIDSet[i]);
				#			}
				#		} else {
				#			tagSetB.add(tagSet.getTagID(t));
				#		}
				#		while (tok.hasMoreTokens()) {
				#			tagSetB.remove(tagSet.getTagID(tok.nextToken()));
				#		}
				#	}
				#}

	#			Iterator<Integer> iterA = tagSetA.iterator();
  #
	#			while (iterA.hasNext()) {
	#				int leftSide = iterA.next();
	#				Iterator<Integer> iterB = tagSetB.iterator();
  #
	#				while (iterB.hasNext()) {
	#					connectionTable[leftSide][iterB.next()] = true;
	#				}
	#			}
  #
	#			tagSetA.clear();
	#			tagSetB.clear();
	#		} else if ("START_TAG".equals(lineToken)) {
	#			startTag = lineTokenizer.nextToken();
	#		}
	#	}
	#	br.close();
	#}
      end
    end
  end
end




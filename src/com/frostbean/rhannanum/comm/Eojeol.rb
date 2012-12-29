class Eojeol
	def initialize(morphemes=nil,tags=nil)
    #Morphemes in the eojeol.
	  @morphemes =morphemes
    #Morpheme tags of each morpheme.
    @tags = tags

    #The number of morphemes in this eojeol.
    @length = 0

    if ( @morphemes != nil and @tags != nil and @morphemes.size > @tags.size ) then
      @length = @morphemes.size
    elsif @tags != nil
      @length = @tags.size
    end
  end

	def get_morphemes()
		return morphemes
	end
	
	#주어진 인덱스에 대한 형태소를 리턴한다.
	def get_morpheme(index)
		return morphemes[index]
	end
	
	def set_morphemes( morphemes)
		@morphemes = morphemes
		if tags != nil && @tags.length < @morphemes.length then
			@length = @tags.length
		else
			@length = @morphemes.length
		end
	end
	
	def set_morpheme( index,  morpheme)
		if (index >= 0 && index < @morphemes.length) then
			@morphemes[index] = morpheme;
			return index
		else
			return -1
		end
	end
	
	def get_tags()
		return tags;
	end
	
	def get_tag( index)
		return @tags[index]
  end


	def set_tags(tags)
		@tags = tags;
		if (@morphemes != nil && @morphemes.length < @tags.length) then
			@length = @morphemes.length;
		else
			@length = @tags.length;
		end
	end

  def set_tag( index,  tag)
		if (index >= 0 && index < @tags.length) then
			@tags[index] = tag
			return index;
		else
			return -1;
		end
	end

	def to_s
		str = "";
		for  i in 0..(@length-1)
			if (i != 0) then
				str += "+"
			end
			str += @morphemes[i] + "/" + @tags[i];
		end
		return str;
	end
end
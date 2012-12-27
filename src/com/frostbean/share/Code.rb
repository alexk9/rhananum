#coding:utf-8

 #* This class is for code conversion. HanNanum internally uses triple encoding, which represents
 #* an Korean eumjeol with three characters - CHOSEONG(beginning consonant), JUNGSEONG(vowel), JONGSEONG(final consonant).
 #* This class converts the Korean encoding from unicode to triple encoding, and vice versa.
class Code
	#/** triple encoding */
	ENCODING_TRIPLE = 0

	#/** unicode */
	ENCODING_UNICODE = 1;

	#/** CHOSEONG(beginning consonant) */
	JAMO_CHOSEONG = 0;

	#/** JUNGSEONG(vowel) */
	JAMO_JUNGSEONG = 1;

	#/** JONGSEONG(final consonant) */
	JAMO_JONGSEONG = 2;

	#/** hangul filler in unicode */
	HANGUL_FILLER = 0x3164;

	#/** the list of CHOSEONG - beginning consonant */
	CHOSEONG_LIST =['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ']

	#/** the list of JONGSEONG - final consonant */
	JONGSEONG_LIST =
		[HANGUL_FILLER, 'ㄱ','ㄲ','ㄳ','ㄴ','ㄵ','ㄶ','ㄷ','ㄹ','ㄺ','ㄻ','ㄼ','ㄽ','ㄾ','ㄿ','ㅀ','ㅁ','ㅂ','ㅄ','ㅅ','ㅆ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ']

	#/** the list of JONGSEONG for reverse */
	CHOSEONG_LIST_REV =
		[0,1,-1,2,-1,-1,3,4,5,-1,-1,-1,-1,-1,-1,-1,6,7,8,-1,9,10,11,12,13,14,15,16,17,18]

	#/** the list of JONGSEONG for reverse */
	JONGSEONG_LIST_REV =
		[1,2,3,4,5,6,7,-1,8,9,10,11,12,13,14,15,16,17,-1,18,19,20,21,22,-1,23,24,25,26,27]

	#/**
	# * It changes the encoding of text file between UTF-8 and the triple encoding.
	def convert_file(srcFileName, desFileName, srcEncoding, desEncoding)
    f_src = File.open(srcFileName,"r:utf-8")
    f_des= File.open(desFileName,"w:utf-8")

    if srcEncoding == ENCODING_UNICODE and desEncoding == ENCODING_TRIPLE then
      while f_src.eof? == false do
        line = f_src.readline()
        buf = to_triple_array(line)
        f_des.write(buf+"\n")
      end
    elsif srcEncoding == ENCODING_TRIPLE && desEncoding == ENCODING_UNICODE then
      while f_src.eof? == false do
        line = f_src.readline
        buf = to_string(line)
        bw.write(buf+"\n")
      end
		end
  end


	# It checks whether the specified character is choseong.
	def self.is_choseong?(c)
		if c.to_i >= 0x1100 && c.to_i <= 0x1112 then
			return true;
		else
			return false;
		end
	end

	#It checks whether the specified character is jongseong.
	def self.is_jongseong?( c)
		if c.to_i >= 0x11A8 && c.to_i <= 0x11C2 then
			return true;
		else
			return false;
		end
	end

	#It checks whether the specified character is jungseong.
	def self.is_jungseong?(c)
		if c.to_i >= 0x1161 && c.to_i <= 0x1175 then
			return true;
		else
			return false;
		end
	end

	# It changes the specified jongseong to choseong.
	def self.to_choseong(jongseong)
		if jongseong >= 0x11A8 && jongseong <= 0x11C2 then
			jongseong -= 0x11A7;
			# 종성
			tmp = JONGSEONG_LIST[jongseong];
			tmp -= 0x3131;
			if CHOSEONG_LIST_REV[tmp] != -1 then

        #byte를문자열로고치는거체크하기
				return (CHOSEONG_LIST_REV[tmp] + 0x1100)
			end
		end
		return jongseong;
	end

	#Changes the unicode Hangul jamo to unicode compatibility Hangul jamo.
	def self.to_compatibility_jamo(jamo)
		if jamo >= 0x1100 && jamo < 0x1100 + CHOSEONG_LIST.length then
			return CHOSEONG_LIST[jamo - 0x1100];
		end
		if jamo >= 0x1161 && jamo <= 0x1175 then
      #byte -> char
			return (jamo - 0x1161 + 0x314F)
		end
		if jamo == 0 then
			return HANGUL_FILLER
		else
			if jamo >= 0x11A8 && jamo < 0x11A7 + JONGSEONG_LIST.length then
				return JONGSEONG_LIST[jamo - 0x11A7]
			end
		end
		return jamo;
	end

	#It changes the unicode Hangul compatibility jamo to Hangul jamo - choseong, jungseong, or jongseong.
	def self.to_jamo( jamo,  flag)
		result = 0
    case flag
      when JAMO_CHOSEONG then
        if jamo >= 0 && jamo <= 0x12 then
          #to char
				  result = (jamo + 0x1100)
			  end
			when JAMO_JUNGSEONG then
        if jamo >= 0 && jamo <= 0x14 then
          #to char
          result = (jamo + 0x1161)
        end
      when JAMO_JONGSEONG then
        if jamo >= 1 && jamo <= 0x1B then
          #to char
          result = (jamo + 0x11A7)
        end
    end
		return result
	end

	#Converts the encoding of the text from Hangul triple encoding to unicode.
	def self.to_string(tripleArray)
		result = ""
		i = 0;
		len = tripleArray.length

		cho,jung,jong= 0,0,0

		if len == 0 then
			return ""
		end

		c = tripleArray[i]


		while (i < len)  do
			if (c.to_i >= 0x1100 && c.to_i <= 0x1112)  then
				cho = c - 0x1100

        i+=1
				if (i < len) then
					c = tripleArray[i];
				end
				if (c.to_i >= 0x1161 && c.to_i <= 0x1175 && i < len) then
					jung = c - 0x1161;
          i+=1
					if (i < len) then
						c = tripleArray[i]
					end
					if (c.to_i >= 0x11A8 && c.to_i <= 0x11C2 && i < len) then
						jong = c - 0x11A7;

						# choseong + jungseong + jongseong ; to char
						result += (0xAC00 + (cho * 21 * 28) + (jung * 28) + jong)
            i+=1
						if (i < len) then
							c = tripleArray[i]
						end
					else
						# choseong + jungseong to char
						result += (0xAC00 + (cho * 21 * 28) + (jung * 28));
					end
				else
					# choseong: a single choseong is represented as ^consonant
					tmp = CHOSEONG_LIST[cho];
					if (tmp == 'ㅃ' || tmp == 'ㅉ' || tmp == 'ㄸ')  then
						result += CHOSEONG_LIST[cho];
					else
						result += "^" + CHOSEONG_LIST[cho];
					end
				end
			elsif (c.to_i >= 0x1161 && c.to_i <= 0x1175 && i < len)  then
				jung = c - 0x1161;

			  # jungseong
				result += (jung + 0x314F);

        i+=1
				if (i < len) then
					c = tripleArray[i];
				end
			elsif (c.to_i >= 0x11A8 && c.to_i <= 0x11C2 && i < len) then
				jong = c - 0x11A7;

				# jongseong
				result += JONGSEONG_LIST[jong];
        i+=1
				if (i < len) then
					c = tripleArray[i];
				end
			else
				result += c;

        i+=1
				if (i < len) then
					c = tripleArray[i];
				end
			end
		end
		return result;
	end

	#Converts the encoding of the text from Hangul triple encoding to unicode.
	def self.to_string_with_len(tripleArray, len)
		result = ""
		i = 0

		cho,jung,jong =0,0,0

		c = tripleArray[i+=1]

		while (i < len) do
			if (c.to_i >= 0x1100 && c.to_i <= 0x1112 && i < len)  then
				cho = c - 0x1100;
				c = tripleArray[i+=1];
				if (c.to_i >= 0x1161 && c.to_i <= 0x1175 && i < len) then
					jung = c - 0x1161;
					c = tripleArray[i+=1];
					if (c.to_i >= 0x11A8 && c.to_i <= 0x11C2 && i < len) then
						jong = c - 0x11A7;
						# choseong + jungseong + jongseong
						result += (0xAC00 + (cho * 21 * 28) + (jung * 28) + jong);
						c = tripleArray[i+=1];
					else
						# choseong + jongseong
						result += (0xAC00 + (cho * 21 * 28) + (jung * 28));
					end
				else
					# choseong: a single choseong is represented as ^consonant
					tmp = CHOSEONG_LIST[cho];
					if (tmp == 'ㅃ' || tmp == 'ㅉ' || tmp == 'ㄸ') then
						result += CHOSEONG_LIST[cho];
					else
						result += "^" + CHOSEONG_LIST[cho];
					end
				end
			elsif (c.to_i >= 0x1161 && c.to_i <= 0x1175 && i < len) then
				jung = c - 0x1161;
				# jungseong
				result += (jung + 0x314F);
				c = tripleArray[i+=1];
			elsif (c.to_i >= 0x11A8 && c.to_i <= 0x11C2 && i < len) then
				jong = c - 0x11A7;
				# jongseong
				result += JONGSEONG_LIST[jong];
				c = tripleArray[i+=1];
			else
				result += c;
				c = tripleArray[i+=1];
			end
		end
		return result;
	end

	#It combines the specified choseong, jungseong, and jongseong to one unicode Hangul syllable.
	def self.to_syllable(cho, jung, jong)
		if (cho >= 0x1100 && cho <= 0x1112) then
			cho -= 0x1100;
			if (jung >= 0x1161 && jung <= 0x1175) then
				jung -= 0x1161;
				if (jong >= 0x11A8 && jong <= 0x11C2) then
					jong -= 0x11A8;
					# choseong + jungseong + jongseong
					return (0xAC00 + (cho * 21 * 28) + (jung * 28) + jong)
				else
					# choseong + jungseong
					return (0xAC00 + (cho * 21 * 28) + (jung * 28))
				end
			else
				# choseong
				return CHOSEONG_LIST[cho];
			end
		elsif (jung >= 0x1161 && jung <= 0x1175) then
			jung -= 0x1161;
			# jungseong
			return (jung + 0x314F);
		elsif (jong >= 0x11A8 && jong <= 0x11C2)  then
			jong -= 0x11A;
			# jongseong
			return JONGSEONG_LIST[jong];
		end
		return HANGUL_FILLER
	end

	#It converts the encoding of the specified text from unicode to triple encoding.
	def self.to_triple_array( str)
		result = nil
    charList = []
		c , cho, jung,jong =0,0,0,0

		for i in 0..(str.length()-1) do
      #문자하나를떼어서c라고함
			c = str[i]
      #그문자하나를byte배열로바꿈
      c = c.unpack("U*")
      #배열중첫원소를c로함
      c = c[0]
      #to_i 부분은디버깅하면서 수정해야함
			if(c >= 0xAC00 && c <= 0xD7AF) then
				combined = c - 0xAC00
				if ((cho = toJamo((combined / (21 * 28)), JAMO_CHOSEONG)) != 0) then
					charList << cho
				end
				combined %= (21 * 28)
				if ((jung = toJamo((combined / 28), JAMO_JUNGSEONG)) != 0) then
					charList << jung
				end
				if ((jong = toJamo((combined % 28), JAMO_JONGSEONG)) != 0) then
					charList << jong
				end
			elsif (c >= 0x3131 && c <= 0x314E) then
				c -= 0x3131
				if (JONGSEONG_LIST_REV[c] != -1) then
					# a single consonant is regarded as a final consonant
					charList << (JONGSEONG_LIST_REV[c] + 0x11A7)
				elsif (CHOSEONG_LIST_REV[c] != -1) then
					# a single consonant which can not be a final consonant becomes a beginning consonant
					charList << (CHOSEONG_LIST_REV[c] + 0x1100)
				else
					# exception (if it occur, the conversion array has some problem)
					charList << (c + 0x3131)
				end
			elsif (c >= 0x314F && c <= 0x3163)  then
				# a single vowel changes jungseong
				charList  << (c - 0x314F + 0x1161)
			elsif (c == '^' && str.length() > i + 1 && str[i+1] >= 0x3131 && str[i+1] <= 0x314E) then
				# ^consonant changes to choseong
				c = (str.charAt(i+1) - 0x3131)
				if (CHOSEONG_LIST_REV[c] != -1)then
					charList << (CHOSEONG_LIST_REV[c] + 0x1100)
					i+=1
				else
					charList <<  '^'
				end
			else
				# other characters
				charList << c
			end
		end

		result = Array.new(charList.size())

		for i in 0..(result.length-1) do
			result[i] = charList[i]
		end

		return result;
	end

	#It returns the unicode representation of triple encoding text.
	def self.to_triple_string(str)
		return to_triple_array(str)
	end
end
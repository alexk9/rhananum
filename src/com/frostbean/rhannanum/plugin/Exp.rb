#encoding:utf-8

#This class for expansion of morphological analysis regarding rules such as
#elision, contractions, and irregular rules.

class Exp 
	 #* TAG_TYPE_YONGS : TAG_TYPE_YONGS
	 #* TAG_TYPE_EOMIES : TAG_TYPE_EOMIES
	 #* IRR_TYPE_S : IRR_TYPE_S
	 #* ᆮ Irregular rule : IRR_TYPE_D
	 #* ᆸ Irregular rule : IRR_TYPE_B
	 #* ᇂ Irregular rule : IRR_TYPE_H
	 #* 르 Irregular rule : IRR_TYPE_REU
	 #* 러 Irregular rule : IRR_TYPE_REO

	def initialize( mc, tagSet)
    	#The last index of pset
      @pset_end = 0;
      #The lattice style morpheme chart
      @mc = nil;
      #Morpheme tag set
      @tagSet = nil;
      #The list for expansion rules.
      pset = 
        [
          ["초성","ᄀᄁᄂᄃᄄᄅᄆᄇᄈᄉᄊᄋᄌᄍᄎᄏᄐᄑᄒ"],
          ["종성","ᆨᆩᆪᆫᆬᆭᆮᆯᆰᆱᆲᆳᆴᆵᆶᆷᆸᆹᆺᆻᆼᆽᆾᆿᇀᇁᇂ"],
          ["중성","ᅡᅣᅥᅧᅩᅭᅮᅲᅳᅵᅢᅤᅦᅨᅬᅱᅴᅪᅯᅫᅰ"],

          ["음성모음","ᅥᅮᅧᅲᅦᅯᅱᅨ"],
          ["양성모음","ᅡᅩᅣᅢᅪᅬᅤ"],
          ["중성모음","ᅳᅵ"],

          # rules on '것' : 걸로, 걸, 겁니다, 건 거면 */
          ["rule_것l",""],
          ["rule_것","ᄂᄆᄅᆫᆯᆸ"],
          ["rule_것r",""],

          # 'ᆯ' elision-1 */
          ["l11","ᅡᅣᅥᅧᅩᅭᅮᅲᅳᅵᅢᅤᅦᅨᅬᅱᅴᅪᅯᅫᅰ"],
          ["11"," ᆫᆯᆷᆸᄂᄉ"],
          ["r11",""],

          # 'ᆯ' elision-2 */
          ["l11-1","ᅡᅣᅥᅧᅩᅭᅮᅲᅳᅵᅢᅤᅦᅨᅬᅱᅴᅪᅯᅫᅰ"],
          ["11-1","ᄂᄉ"],
          ["r11-1",""],

          # 'ᅳ'  elision*/
          ["l12",""],
          ["12","ᅡᅥ"],
          ["r12",""],

          # 'ᅡ' elision */
          ["l13",""],
          ["13","ᅡ"],
          ["r13",""],

          # 'ᅥ' elision */
          ["l14",""],
          ["14","ᅥᅦᅧᅢ"],
          ["r14",""],

          # 'ᆮ' irregular */
          ["l21","ᆯ"],
          ["21","ᄋ"],
          ["r21","ᅥᅡᅳ"],

          # 'ᆺ' irregular */
          ["l22","ᅡᅥᅮᅳᅵ"],
          ["22","ᄋ"],
          ["r22","ᅥᅡᅳ"],

          # 'ᆸ' irregular-1 */
          ["l23","ᄋ"],
          ["23","ᅮ"],
          ["r23",""],

          # 'ᆸ' irregular-2 */
          ["l24","ᄋ"],
          ["24","ᅪ"],
          ["r24",""],

          # 'ᆸ' irregular-3 */
          ["l25","ᄋ"],
          ["25","ᅯ"],
          ["r25",""],

          # 'ᇂ' irregular-1 */
          ["l26","ᄀᄃᄅᄆᄋ"],
          ["26","ᅡᅣ"],
          ["r26",""],

          # 'ᇂ' irregular-2 */
          ["l27","ᄀᄃᄅᄆᄄᄋ"],
          ["27","ᅢᅤ"],
          ["r27",""],

          # 'ᇂ' irregular-3 */
          ["l28","ᄀᄃᄅᄆᄄᄋ"],
          ["28","ᅥ"],
          ["r28",""],

          # '르' irregular */
          ["l29","ᆯ"],
          ["29","ᄅ"],
          ["r29","ᅥᅡ"],

          # '러' irregular */
          ["l30","ᅳ"],
          ["30","ᄅ"],
          ["r30","ᅥ"],

          # '우' irregular */
          ["l31","ᄑ"],
          ["31","ᅥ"],
          ["r31",""],

          # '여' irregular-1 */
          ["l32","ᄒ"],
          ["32","ᅡ"],
          ["r32","ᄋ"],

          # '여' irregular-2 */
          ["l33","ᄒ"],
          ["33","ᅢ"],
          ["r33",""],

          # 'ᅩ', 'ᅮ' contraction */
          ["l51",""],
          ["51","ᅪᅯ"],
          ["r51",""],

          # 'ᅬ' contraction */
          ["l52",""],
          ["52","ᅫ"],
          ["r52",""],

          # 'ᅵ' contraction */
          ["l53",""],
          ["53","ᅧ"],
          ["r53",""],

          #'으(eomi)' elision
          # the rule l54 is shared for '으', '스', '느'
          ["l54","ᆯᅡᅣᅥᅧᅩᅭᅮᅲᅳᅵᅢᅤᅦᅨᅬᅱᅴᅪᅯᅫᅰ"],
          ["54"," ᆫᆯᆷᆸᄂᄅᄆᄉᄋ"],
          ["r54",""]
        ];
    @mc = mc;
		@tagSet = tagSet;
		@pset_end = pset.length;
	end

	def insert(str1, cur,str2)
		return str1[0, cur] + str2 + str1[cur..-1]
	end

	def	pcheck(base, idx, rule) 
		
		if (idx < base.length()) then
			c = base[idx]
		else
			c = '\0';
		end

		for i in 0..(pset_end-1) do
			if (pset[i][0].equals(rule)) then
				if (pset[i][1].length() == 0) then
					return 1;
				else
					index = pset[i][1].index(c)
					if (index == nil) then
						return 0;
					else
						return index + 1;
					end
				end
			end
		end
		return 0;
	end

	
	def prule(from, str1, str2, sp) 
		
		rule_NP(from, str1, str2);
		# sp.printPosition();

		for i in 0..(str2.length()-1) do
			rule_rem(from,str1,str2,i);
			# sp.printPosition();
			rule_irr_word(from,str1,str2,i);
			# sp.printPosition();
			rule_irr_word2(from,str1,str2,i);
			# sp.printPosition();
			rule_shorten(from,str1,str2,i);
			# sp.printPosition();
			rule_eomi_u(from,str1,str2,i);
			# sp.printPosition();
			rule_johwa(from,str1,str2,i);
			# sp.printPosition();
			rule_i(from,str1,str2,i);
			# sp.printPosition();
			rule_gut(from,str1,str2,i);
			# sp.printPosition();
		end
	end

	def replace( str1, cur, str2) 
		array = str1
		
		if (str2.length() == 0) then
			pyts "Exp.java: replace(): s is to short"
			exit
		end
		array[cur] = str2[0]
		
		return array
	end

	def rule_eomi_u(from, prev, str, cur)

		if (cur > str.length()) then
			return;
		end

		if ((cur>0 && pcheck(str,cur-1,"l54")!=0) &&pcheck(str,cur,"54")!=0 &&pcheck(str,cur+1,"r54")!=0) then
			new_str=insert(str,cur,"으");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phoneme_change(from,buf,buf2,TagSet::TAG_TYPE_YONGS,TagSet::TAG_TYPE_EOMIES,0);
		end
		if ((cur>0 && pcheck(str,cur-1,"l54")!=0) && strncmp(str,cur,"ᆸ니",0,3)==0) then
			new_str=insert(str,cur,"스");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phoneme_change(from,buf,buf2,TagSet::TAG_TYPE_YONGS,TagSet::TAG_TYPE_EOMIES,0);
		end
		if ((cur>0 && pcheck(str,cur-1,"l54")!=0) && strncmp(str,cur,"ᆫ다",0,3)==0)  then
			new_str=insert(str,cur,"느");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phoneme_change(from,buf,buf2,TagSet::TAG_TYPE_YONGS,TagSet::TAG_TYPE_EOMIES,0);
		end
	end

	def rule_gut(from,prev,str,cur)

		if (cur >= str.length()) then
			return;
		end

		if (cur>1&& strncmp(str,cur-2,"거",0,2)==0 && 	pcheck(str,cur,"rule_것")!=0) then
			if (str[cur]=='ᆸ') then
				if (strncmp(str,cur,"ᆸ니",0,3)==0) then
					new_str=insert(str,cur,"ᆺ이");
					buf = new_str.substring(0,cur+1);
					buf2 = new_str.substring(cur+1);
					mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_NBNP,TagSet.TAG_TYPE_JP,0);
				end
			else
				if (strncmp(str,cur,"ᆯ로",0,3)==0) then
					new_str=replace(str,cur,"ᆺ");
					new_str=insert(new_str,cur+1,"으");
					buf = new_str.substring(0,cur+1);
					buf2 = new_str.substring(cur+1);
					mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_NBNP,TagSet.TAG_TYPE_JOSA,0);

				elsif (str.charAt(cur)=='ᆯ'||str.charAt(cur)=='ᆫ') then
					if (str.length() != cur + 1) then
						new_str=insert(str,cur,"ᆺ이");
						buf = new_str.substring(0,cur+1);
						buf2 = new_str.substring(cur+1);
						mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_NBNP,TagSet.TAG_TYPE_JP,0);
					end

					new_str=insert(str,cur,"ᆺ으");
					buf = new_str.substring(0,cur+1);
					buf2 = new_str.substring(cur+1);
					mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_NBNP,TagSet.TAG_TYPE_JOSA,0);
				else
					new_str=insert(str,cur,"ᆺ이");
					buf = new_str.substring(0,cur+1);
					buf2 = new_str.substring(cur+1);
					mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_NBNP,TagSet.TAG_TYPE_JP,0);
				end
			end
		end
	end

  def rule_i(from, prev, str,cur)
		if (cur+2 > str.length()) then
			return;
		end

		if ((prev!=nil&&prev.length() != 0&&cur==0)	&&pcheck(prev,prev.length()-1,"중성")!=0) then
			if (strncmp(str,0,"여",0,2)==0) then
				new_str=replace(str,cur+1,"ᅥ");
				new_str=insert(new_str,cur+1,"ᅵᄋ");
				buf = new_str.substring(0,cur+2);
				buf2 = new_str.substring(cur+2);
				mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_JP,TagSet.TAG_TYPE_EOMIES,0);
			else
				if (pcheck(str,0,"종성")!=0||
						strncmp(str,0,"는",0,3)==0||strncmp(str,0,"은",0,3)==0||
						strncmp(str,0,"음",0,3)==0||strncmp(str,2,"는",0,3)==0) then
					return;
        end
				mc.phonemeChange(from,"이",str,TagSet.TAG_TYPE_JP,TagSet.TAG_TYPE_EOMIES,0);
				buf = "이" + str;
				rule_eomi_u(from,prev,buf,cur+2);
			end
		end
	end

	def rule_irr_word(from,prev,str,cur)
		len = str.length();

		# 'ᆮ' irregular rule */
		if ((cur>0&&cur<=len&&pcheck(str,cur-1,"l21")!=0)	&&pcheck(str,cur,"21")!=0	&&pcheck(str,cur+1,"r21")!=0) then
			new_str = replace(str,cur-1,"ᆮ");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_D);
		end

		# 'ᆺ' irregular rule */
		if ((cur>0&&cur<len&&pcheck(str,cur-1,"l22")!=0) &&pcheck(str,cur,"22")!=0 &&pcheck(str,cur+1,"r22")!=0) then
			new_str=insert(str,cur,"ᆺ");
			buf = new_str[0,cur+1]
			buf2 = new_str[cur+1..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_S);
		end

		#'ㅂ' irregular rule */
		if ((cur>0&&cur<=len&&pcheck(str,cur-1,"l23")!=0)	&&pcheck(str,cur,"23")!=0	&&pcheck(str,cur+1,"r23")!=0) then
			new_str=replace(str,cur,"ᅳ");
			new_str=insert(new_str,cur-1,"ᆸ");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_B);
		end

		# 'ᆸ' irregular rule */
		if ((cur>0&&cur<=len&&pcheck(str,cur-1,"l24")!=0)	&&pcheck(str,cur,"24")!=0	&&pcheck(str,cur+1,"r24")!=0) then
			new_str=replace(str,cur,"ᅥ");
			new_str=insert(new_str,cur-1,"ᆸ");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_B);
		end

		# 'ㅂ' irregular rule */
		if ((cur>0&&cur<=len&&pcheck(str,cur-1,"l25")!=0) &&pcheck(str,cur,"25")!=0	&&pcheck(str,cur+1,"r25")!=0) then
			new_str=replace(str,cur,"ᅥ");
			new_str=insert(new_str,cur-1,"ᆸ");
			buf = new_str[0,cur]
			buf2 = new_str[cur..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_B);
		end

		# 'ᇂ' irregular rule */
		if ((cur>0&&cur+1<len&&pcheck(str,cur-1,"l26")!=0)	&&pcheck(str,cur,"26")!=0 &&pcheck(str,cur+1,"r26")!=0) then
			new_str=insert(str,cur+1,"ᇂ으");
			buf = new_str[0,cur+2]
			buf2 = new_str[cur+2..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_H);
		end

		#'ㅎ' irregular rule */
		if ((cur>0&&cur+1<len&&pcheck(str,cur-1,"l27")!=0) &&pcheck(str,cur,"27")!=0 &&pcheck(str,cur+1,"r27")!=0) then
			if (str.charAt(cur)=='ᅢ') then
				new_str=replace(str,cur,"ᅡ");
			else
				new_str=replace(str,cur,"ᅣ");
			end
			new_str=insert(new_str,cur+1,"ᇂ어");
			buf = new_str[0,cur+2]
			buf2 = new_str[cur+2..-1]
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_H);
			if (str.charAt(cur)=='ᅢ') then
				new_str = replace(str,cur,"ᅥ");
			else
				new_str = replace(str,cur,"ᅧ");
			end
			new_str=insert(new_str,cur+1,"ᇂ어");
			buf = new_str.substring(0,cur+2);
			buf2 = new_str.substring(cur+2);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_H);
		end
		
		#'ㅎ' irregular rule */
		if ((cur>0&&cur+1<len&&pcheck(str,cur-1,"l28")!=0) &&pcheck(str,cur,"28")!=0 &&pcheck(str,cur+1,"r28")!=0) then
			new_str=replace(str,cur,"ᅥ");
			new_str=insert(new_str,cur+1,"ᇂᄋ");
			buf = new_str.substring(0,cur+2);
			buf2 = new_str.substring(cur+2);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_H);
		end

    # '르' irregular rule */
		if ((cur>0&&cur<len&&pcheck(str,cur-1,"l29")!=0)&&pcheck(str,cur,"29")!=0&&pcheck(str,cur+1,"r29")!=0) then
			new_str = replace(str,cur,"ᅳ");
			if (new_str.charAt(cur+1)=='ᅡ') then
				new_str = new_str.substring(0, cur+1) + 'ᅥ' + new_str.substring(cur+2);
			end
      new_str = insert(new_str,cur+1,"ᄋ");
			new_str = new_str.substring(0, cur-1) + Code.toChoseong(new_str.charAt(cur-1)) + new_str.substring(cur);

			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_REU);
		end
		
		# '러' irregular rule */
		if ((cur>0&&cur<=len&&pcheck(str,cur-1,"l30")!=0)&&pcheck(str,cur,"30")!=0&&pcheck(str,cur+1,"r30")!=0&&(cur-2>=0&&str.charAt(cur-2)=='ᄅ')) then
			new_str=replace(str,cur,"ᄋ");
			buf = new_str.substring(0,cur);
			buf2 = new_str.substring(cur);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,tagSet.IRR_TYPE_REO);
		end
	end

	
	def rule_irr_word2(from,prev,str,cur)
	
		if (cur >= str.length()) then
			return;
		end

		#'우' irregular rule */
		if ((cur>0&&pcheck(str,cur-1,"l31")!=0)&&pcheck(str,cur,"31")!=0&&pcheck(str,cur+1,"r31")!=0) then
			new_str=replace(str,cur,"ᅮ");
			new_str=insert(new_str,cur+1,"어");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end

		#'여' irregular rule */
		if ((cur>0&&pcheck(str,cur-1,"l32")!=0)&&pcheck(str,cur,"32")!=0&&pcheck(str,cur+1,"r32")!=0&&str.charAt(cur+2)=='ᅧ') then
			new_str=replace(str,cur+2,"ᅥ");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end

		#'여' irregular rule */
		if ((cur>0&&pcheck(str,cur-1,"l33")!=0)&&pcheck(str,cur,"33")!=0&&pcheck(str,cur+1,"r33")!=0) then
			new_str=replace(str,cur,"ᅡ");
			new_str=insert(new_str,cur+1,"어");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end
	end

	def rule_johwa(from,prev,str,cur)	
		if (cur>0&&pcheck(str,cur-1,"양성모음")!=0) then
			if (cur+2<str.length()&&str.charAt(cur+1)=='ᄋ'&&str.charAt(cur+2)=='ᅡ') then
				new_str=replace(str,cur+2,"ᅥ");
				buf = new_str.substring(0,cur+1);
				buf2 = new_str.substring(cur+1);
				mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
			elsif (cur+1<str.length()&&str.charAt(cur)=='ᄋ'&&str.charAt(cur+1)=='ᅡ') then
				new_str=replace(str,cur+1,"ᅥ");
				buf = new_str.substring(0,cur);
				buf2 = new_str.substring(cur);
				mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
			end
		end
	end

	def rule_NP(from,prev,str) 

		if (strncmp(str,0,"내가",0,4)==0) then
			mc.phonemeChange(from,"나",str+2,TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strncmp(str,0,"네가",0,4)==0) then
			mc.phonemeChange(from,"너",str+2,TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strncmp(str,0,"제가",0,4)==0) then
			mc.phonemeChange(from,"저",str+2,TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strcmp(str,0,"내",0)==0) then
			mc.phonemeChange(from,"나","의",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strcmp(str,0,"네",0)==0) then
			mc.phonemeChange(from,"너","의",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strcmp(str,0,"제",0)==0) then
			mc.phonemeChange(from,"저","의",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strncmp(str,0,"내게",0,4)==0) then
			mc.phonemeChange(from,"나",buf,TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strncmp(str,0,"네게",0,4)==0) then
			buf = "에" + str.substring(2);
			mc.phonemeChange(from,"너",buf,TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strncmp(str,0,"제게",0,4)==0) then
			buf = "에" + str.substring(2);
			mc.phonemeChange(from,"저",buf,TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		elsif (strncmp(str,0,"나",0,2)==0) then
			if (str.length()==3&&str.charAt(2)=='ᆫ') then
				mc.phonemeChange(from,"나","는",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
			elsif (str.length() == 3&&str.charAt(2)=='ᆯ') then
				mc.phonemeChange(from,"나","를",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
			end
		elsif (strncmp(str,0,"너",0,2)==0) then
			if (str.length() == 3&&str.charAt(2)=='ᆫ') then
				mc.phonemeChange(from,"너","는",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
			elsif (str.length() == 3&&str.charAt(2)=='ᆯ') then
				mc.phonemeChange(from,"너","를",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
			end
		elsif (strncmp(str,0,"누구",0,4)==0) then
			if (str.length() == 5&&str.charAt(4)=='ᆫ') then
				mc.phonemeChange(from,"누구","는",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
			elsif (str.length() == 5&&str.charAt(4)=='ᆯ') then
				mc.phonemeChange(from,"누구","를",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
			end
		elsif (strcmp(str,0,"무언가",0)==0) then
			mc.phonemeChange(from,"무엇","인가",TagSet::TAG_TYPE_NBNP,TagSet::TAG_TYPE_JOSA,0);
		end
	end

	def rule_rem(from,prev,str,cur) 

		if (cur >= str.length()) then
			return;
		end

		# 'ㄹ' elision rule */
		if ((cur>0&&pcheck(str,cur-1,"l11")!=0) &&(pcheck(str,cur,"11")!=0 || strncmp(str,cur,"오",0,2)==0)&&pcheck(str,cur+1,"r11")!=0) then

			buf3;
			new_str=insert(str,cur,"ᆯ");
			buf3 = new_str;

			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
			rule_eomi_u(from,prev,buf3,cur+1);
		end

		# 'ㅡ' elision rule */
		if ((cur>0&&pcheck(str,cur-1,"l12")!=0)&&pcheck(str,cur,"12")!=0&&pcheck(str,cur+1,"r12")!=0||(cur==1&&str.charAt(cur)!='ᅡ')) then
			new_str = replace(str,cur,"ᅥ");
			new_str = insert(new_str,cur,"ᅳᄋ");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end

		# 'ㅏ' elision rule */
		if ((cur>0&&pcheck(str,cur-1,"l13")!=0)&&pcheck(str,cur,"13")!=0 &&pcheck(str,cur+1,"r13")!=0) then
			new_str = insert(str,cur+1,"어");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end

		# 'ㅓ' elision rule */
		if ((cur>0&&pcheck(str,cur-1,"l14")!=0)&&pcheck(str,cur,"14")!=0&&pcheck(str,cur+1,"r14")!=0) then
			new_str=insert(str,cur+1,"어");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end
	end

	def rule_shorten(from,prev,str,cur)
	
		if (cur >= str.length()) then
			return;
		end

		# 'ㅗ', 'ㅜ' contraction rule */
		if ((cur>0&&pcheck(str,cur-1,"l51")!=0)&&pcheck(str,cur,"51")!=0&&pcheck(str,cur+1,"r51")!=0) then
			if (str.charAt(cur)=='ᅪ') then
				new_str=replace(str,cur,"ᅩ");
			else
				new_str=replace(str,cur,"ᅮ");
			end
			new_str=insert(new_str,cur+1,"어");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			# System.out.println("Prev: " + Code.toString(prev.toCharArray()) + ", " + "Str: " + Code.toString(str.toCharArray()) + ", " + "Cur: " + cur);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end

		# 'ㅚ' contraction rule */
		if ((cur>0&&pcheck(str,cur-1,"l52")!=0)&&pcheck(str,cur,"52")!=0&&pcheck(str,cur+1,"r52")!=0) then
			new_str=replace(str,cur,"ᅬ");
			new_str=insert(new_str,cur+1,"어");
			buf = new_str.substring(0,cur+1);
			buf2 = new_str.substring(cur+1);
			# System.out.println("Prev: " + Code.toString(prev.toCharArray()) + ", " + "Str: " + Code.toString(str.toCharArray()) + ", " + "Cur: " + cur);
			mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
		end

		# 'ㅣ' contraction rule */
		if (cur>0) then
			if (((cur>1 || (str.charAt(cur-1)!='ᄋ'))&&pcheck(str,cur-1,"l53")!=0)&&pcheck(str,cur,"53")!=0&&pcheck(str,cur+1,"r53")!=0) then

				new_str=replace(str,cur,"ᅵ");
				new_str=insert(new_str,cur+1,"어");
				buf = new_str.substring(0,cur+1);
				buf2 = new_str.substring(cur+1);
				# System.out.println("Prev: " + Code.toString(prev.toCharArray()) + ", " + "Str: " + Code.toString(str.toCharArray()) + ", " + "Cur: " + cur);
				mc.phonemeChange(from,buf,buf2,TagSet.TAG_TYPE_YONGS,TagSet.TAG_TYPE_EOMIES,0);
			end
		end
	end


	def  strcmp(s1, i1, s2, i2)
		l1 = s1.length() - i1;
		l2 = s2.length() - i2;

		len = l1;
		diff = false;

		if (len > l2) then
			len = l2;
		end

		while (len > 0) do
			if (s1[i1] != s2[i2]) then
        i1+=1
        i2+=1
				diff = true;
				break;
      else
        i1+=1
        i2+=1
      end
      len-=1
		end

		if (diff == false && l1 != l2) then
			if (l1 > l2) then
				return s1[i1]
			else
				return -s2[i2]
			end
		end
		return s1[i1-1] - s2[i2-1]
	end


	def strncmp_with_len(s1, i1, s2, i2, len)
		if (s1.length() - i1 < len) then
			return 1;
		elsif (s2.length() - i2 < len) then
			return -1;
		end
		while (len > 0) do
			if (s1.charAt(i1) != s2.charAt(i2)) then
        i1+=1
        i2+=1
				break;
      else
        i1+=1
        i2+=1
      end
      len-=1
		end
		return s1[i1-1] - s2.charAt[i2-1]
	end
end



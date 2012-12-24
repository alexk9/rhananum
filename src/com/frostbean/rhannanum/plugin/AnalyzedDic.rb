
##
# This class is the data structure for the pre-analyzed dictionary.
class AnalyzedDic
  def initialize( dictionaryFileName=nil)
    @dictionary = {}
    if dictionaryFileName != nil then
      readDic(dictionaryFileName)
    end
  end

  def clear
    @dictionary.clear
  end

  def get(item)
    return @dictionary[item]
  end

  def readDic(dictionaryFileName)
		dictionary.clear()
		str=""

    f = File.open(dictionaryFileName,"r:utf-8")

    while f.eof? == false do
      str = f.readline()
      str= str.strip
      if str == "" then
        next
      end

      str_toks = str.split(/\t/)
      key = str_toks[0]
      str_toks.delete_at(0)
      value = ""
      for a_tok in str_toks do
        value += a_tok + "\n"
      end

      @dictionary[key] = value.strip
    end
	end
end
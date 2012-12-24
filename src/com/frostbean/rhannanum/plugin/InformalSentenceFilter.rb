require "com/frostbean/rhannanum/plugin/PlaintextProcessor"

##
# This plug-in filters informal sentences in which an eojeol is quite long and some characters were
# repeated many times. These informal patterns occur poor performance of morphological analysis
# so this plug-in should be used in HanNanum work flow which will analyze documents with informal sentences.
# It is a Plain Text Processor plug-in which is a supplement plug-in of phase 1 in HanNanum work flow.
class InformalSentenceFilter 
  include PlainTextProcessor
  
  REPEAT_CHAR_ALLOWED = 5
    
  
  ##
  # It recognizes informal sentences in which an eojeol is quite long and some characters were
  # repeated many times. To prevent decrease of analysis performance because of those unimportant
  # irregular pattern, it inserts some blanks in those eojeols to seperate them.
  def do_process(ps )
    word = nil
    buf = ""
    tokens = ps.sentence.split(/[ \t]/)
    
    for word in tokens do
      #문자열의 길이가 최대 허용치보다 길다면...
      if word.length() > REPEAT_CHAR_ALLOWED then
        repaedCnt = 0
        checkChar = word[0]
        
        buf << checkChar
        
        for i in 1..(word.length-1) do
          if checkChar == word[i] then
            if repaetCnt == (REPEAT_CHAR_ALLOWED-1) then
              buf << " "
              buf << word[i]
              repeatCnt = 0
            else
              buf << word[i]
              repeadCnt +=1
            end
          else
            if checkChar == "." then
              buf << " "
            end
            
            buf << word[i]
            checkChar = word[i]
            repeadCnt = 0
          end
        end
      else
        buf << word
      end
      buf << " "
    end
    ps.sentence=buf
    return ps
  end
  
  def second_initialize(baseDir, configFile)
  end
  
  def flush
    return nil
  end
  
  def shutdown
  end
  
  def has_remaining_data?
    return false
  end
end
  
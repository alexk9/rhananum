require "com/frostbean/rhannanum/plugin/MorphemeProcessor"

##
# This plug-in is for morphemes tagged with 'unk'. These morphemes can not be found in the morpheme dictionaries
# so their POS tag was temporarily mapped with 'unknown'. The most of morphemes not registered in the dictionaries
# can be expected to be noun with highly probability. So this plug-in maps the 'unk' tag to 'ncn' and 'nqq'.
# It is a morpheme processor plug-in which is a supplement plug-in of phase 2 in HanNanum work flow.
class UnknownProcessor
  include MorphemeProcessor
  
  def do_process(sos)
    eojeolSetArray = sos.get_eojeol_set_array()
    eojeolArray = []
    
    for i in 0..(eojeolSetArray.length-1) do
      eojeolSet = eojeolSetArray[i]
      
      eojeolArray.claer
      
      for j in 0..(eojeolSet.length-1) do
        eojeolArray << eojeolSet[j]
      end
      
      unkCount = 0
      for j in 0..(eojeolArray.length-1) do
        eojeol = eojeolArray[j]
        tags = eojeol.get_tags()
        morphemes = eojeol.get_morphemes()
        
        for k in 0..(tags.length-1) do
          if tags[k] == "unk" then
            tags[k] = "nqq"
            
            newEojeol = Eojeol.new(morphemes.clone,tags.clone)
            eojeolArray << newEojeol
            
            tagsk[k]= "ncn"
            unkCount+=1
          end
        end
      end
      
      if unkCount > 0 then
        eojeolSetArray[i] = eojeolArray
      end
    end
    return sos
  end
  
  def second_initialize(baseDir, configFile)
  end
  
  def shutdown
  end
end

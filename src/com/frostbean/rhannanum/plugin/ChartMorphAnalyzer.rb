require "com/frostbean/rhannanum/plugin/MorphAnalyzer"
require "json"

##
# Chart-based Morphological Analyzer.
# It is a morphological analyzer plug-in which is a major plug-in of phase 2 in HanNanum work flow.
# This uses the lattice-style chart as a internal data structure, which makes it possible to
# do morphological analysis without back tracking.
class ChartMorphAnalyzer < MorphAnalyzer
  PLUG_IN_NAME = "MorphAnalyzer"
 
  def initialize
    #Pre-analyzed dictionary. */
    @analyzedDic = nil
    #Default morpheme dictionary. */
    @systemDic = nil
    #Additional morpheme dictionary that users can modify for their own purpose. */
    @userDic = nil
    #Number dictionary, which is actually a automata. */
    @numDic = nil
    #Morpheme tag set */
    @tagSet = nil
    #Connection rules between morphemes. */
    @connection = nil
    #Impossible connection rules. */
    @connectionNot = nil
    #Lattice-style morpheme chart. */
    @chart = nil
    #SIMTI structure for reverse segment position. */
    @simti = nil
    #The file path for the impossible connection rules. */
    @fileConnectionsNot = ""
    #The file path for the connection rules. */
    @fileConnections = ""
    #The file path for the pre-analyzed dictionary. */
    @fileDicAnalyzed = ""
    #The file path for the default morpheme dictionary. */
    fileDicSystem = ""
    #The file path for the user morpheme dictionary. */
    fileDicUser = ""
    #The file path for the tag set. */
    fileTagSet = ""
    #Eojeol list */
    eojeolList = []
    #Post-processor to deal with some exceptions 
    postProc = nil
  end
  
  def get_name
    return PLUG_IN_NAME
  end
  
  def process_eojeol( plainEojeol)
    analysis = analyzedDic.get(plainEojeol)
    eojeolList.clear
    
    if analysis != nil then
      #the eojeol was registered in the pre-analyzed dictionary
      analyzed_list = analysis.split("^")
      for analyzed in analyzed_list do
        #아래 정규식은 ... 디버깅이 필요함 
        tokens = analyzed.split(/\\+|/)
        
        morphemes = []
        tags = []
        for i in 0..(tokens-1) do
          morphemes << tokens[i*2]
          tags << tokens[i*2+1]
        end
        eojeol = Eojeol.new(morphemes, tags)
        eojeolList << eojeol
        
      end
    else
      chart.init(plainEojeol)
      chart.analyze()
      chart.get_result()
    end
    return eojeolList            
  end
  
  ##
  # Analyzes the specified plain sentence, and returns all the possible analysis results.
  # @return all the possible morphological analysis results
  def morph_analyze(ps    )
    plainEojeol = nil
    plainEojeols = ps.sentence.split(/[ \t]/)
    eojeolNum = plainEojeols.length
    
    plainEojeolArray = []
    eojeolSetArray = []
    
    for plainEojeol in plainEojeols do
      plainEojeolArray << plainEojeol
      eojeolSetArray << process_eojeol(plainEojeol)
    end
    
    sos = SetOfSentences.new(ps.document_id, ps.sentence_id, ps.end_of_document, plainEojeolArray, eojeolSetArray)    
    sos = postProc.do_post_processing(sos)
    return sos
  end
  
  def second_initialize( baseDir, configFile)
    json_hash = JSON.parse(configFile)
    
    fileDicSystem = baseDir + "/" + json_hash["dic_system"]
    fileDicUser = baseDir + "/" +json_hash["dic_user"]
    fileConnections = baseDir + "/" + json_hash["connections"]
    fileConnectionsNot = baseDir + "/" + json_hash["connections_not"]
    fileDicAnalyzed = baseDir + "/" + json_hash["dic_analyzed"]
    fileTagSet = baseDir + "/" + json_hash["tagset"]
    
    tagSet = TagSet.new
    tagSet.init(fileTagSet, TagSet:TAG_SET_KAIST)
    
    connection = Connection.new
    connection.init(fileConnetions, tagSet.get_tag_count, tagSet)
    
    connectionNot = ConnectionNot.new
    connectionNot.init(fileConnectionsNot, tagSet)
    
    analyzedDic = AnalyzedDic.new
    analyzedDic.read_dic(fileDicSystem,tagSet)
    
    systemDic = Trie.new(Trie:DEFAULT_TRIE_BUF_SYZE_SYS)
    systemDic.read_dic(fileDicSystem,tagSet)

    userDic = Trie(Trie.DEFAULT_TRIE_BUF_SIZE_USER)
    userDic.read_dic(fileDicUser, tagSet)

    numDic = NumberDic.new
    simti = Simti.new
    simti.init()
    eojeolList = []
    
    chart = MorphemeChart.new(tagSet, connection, systemDic, userDic, numDic, simti, eojeolList)
    postProc = PostProcessor.new
  end
  
  def shutdown()
  end
end

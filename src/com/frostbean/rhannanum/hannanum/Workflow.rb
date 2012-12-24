$: << "/Users/alexk/Documents/workspace/rhannanum-eclipse/src" 

require "thread"
require "com/frostbean/rhannanum/comm/PlainSentence"

class Workflow
  MAX_SUPPLEMENT_PLUGIN_NUM = 8



  def initialize base_dir = ".", maxSupplementPluginNum = MAX_SUPPLEMENT_PLUGIN_NUM
    @maxSupplementPluginNum = maxSupplementPluginNum
    @outputPhaseNum = 0
    @isThreadMode = false
    @outputQueueNum = 0

    #아마도 이것은 나중에 사용하게 될 듯
    @threadList = []

    #주요 플러그인들

    @morphAnalyzer = nil

    #config file for the morphological analyzer
    @morphAnalyzerConfFile = nil

    #세번째 phase , 주요 플러그인 - 포스 태거
    @posTagger = nil
    @posTaggerConfFile = nil

    #보조플러그인들
    #1. PlainTextProcessor
    @plainTextProcessors = []
    @plainTextProcessorConfFiles = []

    #num of the plain text processors
    @plainTextPluginCnt = 0


    #The second phase, supplement plug-ins, morpheme processors.
    @morphemeProcessors = []

    @morphemeProcessorsConfFiles = []

    @morphemePluginCnt = 0

    #The third phase, supplement plug-ins, pos processors.
    @posProcessors = []

    #The configuration file for the pos processors.
    @posProcessorConfFiles = []

    #The number of pos processors.
    @posPluginCnt = 0

    #It is true when the work flow is ready for analysis.
    @isInitialized = false

    #The path for the base directory data and configuration files.
    @baseDir =  nil


    # Communication Queues

    #The communication queues for the fist phase plug-ins.
    @queuePhase1 = []

    #The communication queues for the second phase plug-ins.
    @queuePhase2 = []

    #The communication queues for the third phase plug-ins.
    @queuePhase3 = []

    @isInitialized = true

    @baseDir = base_dir
  end

  def set_morph_analyzer( ma, configFile)
    @morphAnalyzer = ma
    @morphAnalyzerConfFile = @baseDir + "/" +configFile
  end

  def set_pos_tagger tagger, configFile
    @posTagger = tagger
    @posTaggerConfFile = configFile
  end

  def activate_workflow threadMode
    if threadMode then
      raise NotImplementedError
    else
      @isThreadMode = false

      @queuePhase1 << Queue.new

      for i in 0..(@plainTextPluginCnt-1) do
        @plainTextProcessors[i].second_initialize( @baseDir, @plainTextProcessorConfFiles[i]) ;
        @queuePhase1 << Queue.new
      end

      if @morphAnalyzer == nil then
        @outputPhaseNum = 1
        @outputQueueNum = @plainTextPluginCnt
        return
      end

      # initialize the second phase major plug-in and the communication queue
      @morphAnalyzer.second_initialize(@baseDir, @morphAnalyzerConfFile)
			@queuePhase2 << Queue.new

      for i in 0..(@morphemePluginCnt-1) do
        @morphemeProcessors[i].second_initialize( @baseDir, @morphemeProcessorsConfFiles[i])
        @queuePhase2 << Queue.new
      end

      if @posTagger == nil then
        @outputPhaseNum = 2
        @outputQueueNum = @morphemePluginCnt
        return
      end

      @posTagger.second_initialize( @baseDir, @posTaggerConfFile)
      @queuePhase3 << Queue.new

      for i in 0..(@posPluginCnt-1) do
        @posProcessors[i].second_initialize(@baseDir, @posProcessorConfFiles[i])
        @queuePhase3 << Queue.new
      end

      @outputPhaseNum = 3
      @outputQueueNum = @posPluginCnt

    end

  end

  def clear
    if @isInitialized then
      @queuePhase1.clear
      @queuePhase2.claer
      @queuePhase3.clear
      @isThreadMode = false
      @outputPhaseNum = 0
      @outputQueueNum = 0
      @plainTextPluginCnt = 0
      @posPluginCnt = 0
      @morphAnalyzer = nil
      @posTagger = nil
    end
  end

  def analyze( document )
    strArray = document.split("\n")
    queue = @queuePhase1[0]

    if queue == nil then
      return nil
    end

    for i in 0..(strArray.length-2) do
      queue << PlainSentence.new(0,i,false,strArray[i].rstrip)
    end

    queue << PlainSentence.new(0, strArray.length-1 , true, strArray[strArray.length-1].strip )

    analyze_in_single_thread

  end

  def get_result_of_sentence
    res = nil
    case @outputPhaseNum
      when 1 then
        out1 = @queuePhase1[@outputQueueNum]
        res = out1.pop.to_s
      when 2 then
        out2 = @queuePhase2[@outputQueueNum]
        res = out2.pop.to_s
      when 3 then
        out3 = @queuePhase3[@outputQueueNum]
        res = out3.pop.to_s
    end
    return res

  end

  def get_result_of_document
    buf = nil

    case @outputPhaseNum
      when 1 then
        out = @queuePhase1[@outputQueueNum]
        while true do
          ps = out1.pop
          buf << ps
          buf << "\n"
          if ps.is_end_of_document then
            break
          end
        end
      when 2 then
        out2 = @queuePhase2[@outputQueueNum]
        while true do
          sos = out2.pop
          buf << sos
          buf << "\n"
          if sos.is_end_of_document then
            break
          end
        end
      when 3 then
        out3 = @queuePhase3[@outputQueueNum]
        while true do
          sent = out3.pop
          buf << sent
          buf << "\n"
          if sent.is_end_of_document then
            break
          end
        end
    end
    buf.to_s
  end




  def analyze_in_single_thread
    if @plainTextPluginCnt == 0 then
      return
    end

    outQueue1 = @queuePhase1[0]

    for i in 0..(@plainTextPluginCnt-1) do
      inQueue1= outQueue1
      outQueue1 = @queuePhase1[i+1]

      begin
        while true do
          #아래의  pop에서 exception이 발생해야 끝난다.
          #pop할 것이 없을때 exception이 발생하기 때문임.
          ps = inQueue1.pop(true)
          if (ps = @plainTextProcessors[i].do_process(ps)) != nil then
            outQueue1 << ps
          end

          while @plainTextProcessors[i].has_remaining_data? do
            if (ps = @plainTextProcessors[i].do_process(nil)) != nil then
              outQueue1 << ps
            end
          end

          if (ps = @plainTextProcessors[i].flush()) != nil then
            outQueue1 << ps
          end
        end
      rescue Exception => e
        #inQueue1의 아이템들이 모두 소진되었음 
        puts e.to_s+"@Workflow.rb"
      end
    end

    #second phase

    if @morphAnalyzer == nil then
      return
    end

    inQueue1 = outQueue1
    outQueue2 = @queuePhase2[0]

    begin
      while true do
        ps = inQueue1.pop(true)
        if (sos = @morphAnalyzer.morph_analyze(ps)) != nil then
          outQueue2 << sos
        end
      end
    rescue Exception => e
      puts e
    end

    if @morphemePluginCnt == 0 then
      return
    end

    for i in 0..(@morphemePluginCnt-1) do
      inQueue2 = @queuePhase2[i+1]

      begin
        while true do
          sos= inQueue2.pop(true)
          if (sos = @morphemeProcessors[i].do_process(sos))!= nil then
            outQueue2 << sos
          end
        end
      rescue Exception => e
      end

    end

    #third phase
    if @posTagger == nil then
      return
    end

    inQueue2 = outQueue2
    outQueue3 = @queuePhase3[0]

    begin
      while true do
        sos = inQueue2.pop(true)
        if (sent = @posTagger.tag_POS(sos))!= nil then
          outQueue3 << sent
        end
      end
    rescue Exception => e

    end

    if @posPluginCnt == 0 then
      return
    end

    for i in 0..(@posPluginCnt-1) do
      inQueue3 = outQueue3
      outQueue3 = @queuePhase3[i+1]

      begin
        while true do
          sent = inQueue3.pop(true)
          if (sent=@posProcessors[i].do_process(sent))!= nil then
            outQueue3 << sent
          end
        end
      rescue Exception => e
        puts e
      end
    end

    
  end

  def append_plain_text_processor (plugin, configFile)
    @plainTextProcessorConfFiles[@plainTextPluginCnt] = @baseDir + "/" + configFile.to_s
    @plainTextProcessors[@plainTextPluginCnt] = plugin
    @plainTextPluginCnt += 1
  end

  ##
	# Appends the morpheme processor plug-in, which is the supplement plug-in on the second phase, on the work flow.
  def append_morpheme_processor(plugin, configFile)
    @morphemeProcessorsConfFiles[@morphemePluginCnt] = @baseDir + "/" +configFile.to_s
    @morphemeProcessors[@morphemePluginCnt] = plugin
    @morphemePluginCnt+=1
  end

  ##
  #Appends the POS processor plug-in, which is the supplement plug-in on the third phase, on the work flow.
	def append_pos_processor(plugin, configFile)
    @posProcessorConfFiles[@posPluginCnt] = @baseDir + "/" +configFile.to_s
    @posProcessors[@posPluginCnt] = plugin
    @posPluginCnt +=1
  end

  def get_result_of_document( a)
    list = []
    if a.class == PlainSentence then
      if @outputPhaseNum != 1 then
        raise Exception.new
      end
      queue = @queuePhase1[@outputQueueNum]
      while true do
        ps = queue.pop
        list << ps
        if ps.is_end_of_document? then
          break
        end

      end
  #  elsif a.class == SetOfSentences then
    elsif a.class == Sentence then
      if @outputPhaseNum != 3 then
        raise Exception.new
      end

      queue = @queuePhase3[@outputQueueNum]
      begin
        while true do
          sent = queue.pop(true)
          list << sent

          if sent.is_end_of_document? then
            break
          end
        end
      rescue Exception => e
        puts e
      end

    else
      raise Exception.new
    end
    return list
  end

end


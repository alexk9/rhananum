#encoding:utf-8
require "com/frostbean/rhannanum/plugin/PosTagger"
require "com/frostbean/rhannanum/plugin/ProbabilityDBM"

##
# Hidden Markov Model based Part Of Speech Tagger.
# It is a POS Tagger plug-in which is a major plug-in of phase 3 in HanNanum work flow. It uses
# Hidden Markov Model regarding the features of Korean Eojeol to choose the most promising morphological
# analysis results of each eojeol for entire sentence.
class HMMTagger
  include PosTagger
  
  ##
  #Markov Model 을 위한 Node
  class MNode
    def initialize
      # eojeol */
      @eojeol = nil
      # 어절 태그 */
      @wp_tag = nil
      #the probability of this node - P(T, W) */
      @prob_wt = nil
      #the accumulated probability from start to this node */
      @prob = 0.0
      #back pointer for viterbi algorithm */
      @backptr = 0
      #the index for the next sibling */
      @sibling = 0
    end 
  end
  
  ##
  #header of an oejeol
  class WPhead 
    def initialize
      @iIdxOfNodeForEojeol
    end
  end
  
  # log 0.01 - smoothing factor */
  SF = -4.60517018598809136803598290936873
  #the default probability */
  PCONSTANT = -20.0
  #lambda value */
  LAMBDA = 0.9
  #lambda 1 */
  LAMBDA1 = LAMBDA
  #lambda 2 */
  LAMBDA2 = 1.0 - LAMBDA
  def initialize
    #the array of nodes for each eojeol */
    @aEojeol = []
    #the last index of eojeol list */
    @iLastIdxOfaEojeol = 0
    #the nodes for the markov model */
    @aNodeForMM = []
    #the last index of the markov model  */
    @iLastIdxOfMM = 0
    #for the probability P(W|T) */
    @pwt_pos_tf = nil
    #for the probability P(T|T) */
    @ptt_pos_tf = nil
    #for the probability P(T|T) for eojeols */
    @ptt_wp_tf = nil
    #the statistic file for the probability P(T|W) for morphemes */
    # 형태소에 대한 P(T|W) 통계 파일 */
    @PWT_POS_TDBM_FILE = nil 
    #the statistic file for the probability P(T|T) for morphemes */
    #형태소에 대한 P(T|T) 통계 파일 */
    @PTT_POS_TDBM_FILE = nil
    #the statistic file for the probability P(T|T) for eojeols */
    # 어절에 대한 P(T|T) 통계 파일 */
    @PTT_WP_TDBM_FILE= nil 
    
    @conn_pwt_pos = nil
    @conn_ptt_pos = nil
    @conn_ptt_wp = nil
      
  end
  
  def tag_pos(sos)
    v= 0
    prev_v = 0
    w = 0
    plainEojeolArray = sos.get_plain_eoejol_array()
    eojeolSetArray = sos.get_eojeol_set_array()
    
    reset()
    
    plainEojeolArray.each { |plainEojeol |
      for eojeolSet in plainEojeolArray do
        w = new_wp(plainEojeol )
        
        for i in 0..(eojeolSet.length-1) do
          now_tag = PhraseTag.get_phrase_tag(eojeolSet[i].get_tags())
          probability = compute_wt(eojeolSet[i])
          
          v = new_mnode(eojeolSet[i],now_tag,probability)
          if i==0 then
            aEojeol[w].iIdxOfNodeForEojeol = v
            prev_v = v
          else
            aNodeForMM[prev_v].sibling = v
            prev_v = v
          end
        end
      end  
    }
    return end_sentence(sos)
  end
  
  def second_initialize(baseDir, configFile)
    aEojeol = []
    for i in 0..4999 do
      aEojeol << WPhead.new
    end
    @iLastIdxOfaEojeol = 1
    
    aNodeForMM = []
    for i in 0..9999 do
      aNodeForMM << MNode.new
    end
    iLastIdxOfMM = 1

    content = ""

    f = File.open(baseDir+"/"+ configFile,"r:utf-8")
    f.each_line do |line|
      content += line
    end

    json_hash = JSON.parse( content )
    @PWT_POS_TDBM_FILE = baseDir + "/"+ json_hash["pwt.pos"]
    @PTT_POS_TDBM_FILE = baseDir + "/" + json_hash["ptt.pos"]
    @PTT_WP_TDBM_FILE = baseDir + "/" + json_hash["ptt.wp"]
      
    pwt_pos_tf =ProbabilityDBM.new(@PWT_POS_TDBM_FILE)
    ptt_wp_tf = ProbabilityDBM.new(@PTT_WP_TDBM_FILE)
    ptt_pos_tf = ProbabilityDBM.new(@PTT_POS_TDBM_FILE)
    
  end
  
  def shutdown
  end
  
  
  ##
  # Computes P(T_i, W_i) of the specified eojeol.
  # @param eojeol - the eojeol to compute the probability
  # @return P(T_i, W_i) of the specified eojeol
  def compute_wt(eojeol)
    tag = eojeol.get_tag(0)

    # the probability of P(t1|t0)
    # 시작부는 반드시 bnk로 시작한다. bnk-xxx 는 P(xxx|bnk)를 의미한다. 
    bitag = "bnk-" + tag

    if (prob = ptt_pos_tf.get(bitag)) != nil then
      # current = P(t1|t0) */
      tbigram = prob[0]
    else
      # current = P(t1|t0) = 0.01 */
      tbigram = PCONSTANT
    end


    # the probability of P(t1) */
    if (prob = ptt_pos_tf.get(tag)) != nil then
      # current = P(t1) */
      tunigram = prob[0]
    else 
      # current = P(t1) = 0.01 */
      tunigram = PCONSTANT
    end

    # the probability of P(w|t) */
    if (prob = pwt_pos_tf.get(eojeol.get_morpheme(0) + "/" + tag)) != nil then
      # current *= P(w|t1) */
      lexicon = prob[0];
    else
      # current = P(w|t1) = 0.01 */
      lexicon = PCONSTANT
    end
    #current = P(w|t1) * P(t1|t0) ~= P(w|t1) * (P(t1|t0))^Lambda1 * (P(t1))^Lambda2 (Lambda1 + Lambda2 = 1)
    current = lexicon + LAMBDA1*tbigram + LAMBDA2*tunigram

    #current = P(w|t1)/P(t1) * P(t1|t0)/P(t1)
    current = lexicon - tunigram + tbigram - tunigram

    # current = P(w|t1) * P(t1|t0)
    current = lexicon + tbigram 
    
    #current = P(w|t1) * P(t1|t0) / P(t1)
    current = lexicon + tbigram - tunigram
    oldtag = tag
    
    for i in 1..(eojeol.length-1) do
      tag = eojeol.get_tag(i)
    
      #P(t_i|t_i-1) */
      bitag = oldtag + "-" + tag

      if (prob = ptt_pos_tf.get(bitag)) != nil then
        tbigram = prob[0]
      else 
        tbigram=PCONSTANT
      end

      #P(w|t) */
      if (prob = pwt_pos_tf.get(eojeol.get_morpheme(i) + "/" + tag)) !=  nil then
        # current *= P(w|t) */
        lexicon = prob[0]
      else 
        lexicon = PCONSTANT
      end

      #P(t) */
      if (prob = ptt_pos_tf.get(tag)) != nil then
        #current = P(t) */
        tunigram = prob[0]
      else 
        #current = P(t)=0.01 */
        tunigram = PCONSTANT
      end

      current += lexicon - tunigram + tbigram - tunigram
      current += lexicon + tbigram
      current += lexicon + tbigram - tunigram

      oldtag = tag
    end
 
    #the blank at the end of eojeol */
    #끝부분은 반드시 bnk로 끝난다. */
    bitag = tag + "-bnk"

    # P(bnk|t_last) */
    if (prob = ptt_pos_tf.get(bitag)) != nil then
      tbigram = prob[0]
    else
      tbigram = PCONSTANT
    end

    #P(bnk) */
    if (prob = ptt_pos_tf.get("bnk")) != nil then
      tunigram = prob[0]
    else
      tunigram=PCONSTANT
    end

    #P(w|bnk) = 1, and ln(1) = 0 */
    #current += 0 - tunigram + tbigram - tunigram;
    #current += 0 + tbigram;
    current += 0 + tbigram - tunigram

    return current

  end
    
    ##
    # Runs viterbi to get the final morphological analysis result which has the highest probability.
    # 비터비 알고리즘을 통해서 최상의 확률을 갖는 형태소 분석 결과를 얻는다.
    # @param sos - 형태소 분석의 모든 후보 
    # @return 최상의 확률을 갖는 형태소 분석 결과
    def end_sentence( sos)
        
      # Ceartes the last node */
      i = new_wp(" ")
      aEojeol[i].iIdxOfNodeForEojeol = new_mnode(nil, "SF", 0)
  
      # Runs viterbi */
      for i in 1..(iLastIdxOfaEojeol-2) do
        j = aEojeol[i].iIdxOfNodeForEojeol
        while j!= 0 do
          k=aEojeol[i+1].iIdxOfNodeForEojeol
          while k!= 0 do
            update_prob_score(j,k)
            
            k = aNodeForMM[k].sibling
          end
          
          j= aNodeForMM[j].sibling
        end
      end
      
      i = sis.length
      eojeols = []
      k = aEojeol[i].iIdxOfNodeForEojeol
      while k!= 0 do
        i-=1
        eojeols[i] = aNodeForMM[k].eojeol
        
        k= aNodeForMM[k].backptr
      end
      
      return Sentence.new(sos.document_id, sos.sentence_id, sos.end_of_document, sos.get_plain_eojeol_array,eojeols)
    end

    ##
    #Adds a new node for the markov model.
    #@param eojeol - the eojeol to add
    #@param wp_tag - the eojeol tag
    #@param prob - the probability P(w|t)
    #@return the index of the new node
    def new_mnode(eojeol,wp_tag, prob)
      aNodeForMM[iLastIdxOfMM].eojeol = eojeol
      aNodeForMM[iLastIdxOfMM].wp_tag = wp_tag
      aNodeForMM[iLastIdxOfMM].prob_wt = prob
      aNodeForMM[iLastIdxOfMM].backptr = 0
      aNodeForMM[iLastIdxOfMM].sibling = 0
      
      ret_val = iLastIdxOfMM
      iLastIdxOfMM +=1
      return ret_val
          
    end
    
    ##
    # Adds a new header of an eojeol.
    #@param str - the plain string of the eojeol
    #@return the index of the new header
    def new_wp(str)
      aEojeol[iLastIdxOfaEojeol].iIdxOfNodeForEojeol = 0
      ret_val = iLastIdxOfaEojeol 
      iLastIdxOfEojeol += 1
      return ret_val
    end
  
    def reset
      iLastIdxOfaEojeol = 1
      iLastIdxOfMM = 1
    end
 

    ##
    #Updates the probability regarding the transition between two eojeols.
    #@param from - the previous eojeol
    #@param to - the current eojeol
    def udpate_prob_score(from, to)
      ptt = 0.0
      p = 0.0
      #the traisition probability P(T_i,T_i-1) */
      prob = ptt_wp_tf.get(aNodeForMM[from].wp_tag + "-" +aNodeForMM[to].wp_tag)
      
      if prob == nil then
        # ln(0.01). Smoothing Factor */
        ptt = SF
      else 
        ptt = prob[0]
      end
      
      # P(T_i,T_i-1) / P(T_i) */
      prob = ptt_wp_tf.get(aNodeForMM[to].wp_tag)
      
      if prob != nil then
        ptt -= prob[0]
      end
      
      # P(T_i,T_i-1) / (P(T_i) * P(T_i-1)) */
      # prob = ptt_wp_tf.get(mn[from].wp_tag);
   
      #if (prob != null) {
      # PTT -= prob[0];
      #}
  
      if aNodeForMM[from].backptr == 0 then
        aNodeForMM[from].prob = aNodeForMM[from].prob_wt
      end
  
      ## 
      # P = the accumulated probability to the previous eojeol * transition probability * the probability of current eojeol
      # PTT = P(T_i|T_i-1) / P(T_i)
      # mn[to].prob_wt = P(T_i, W_i)
      p = aNodeForMM[from].prob + ptt + aNodeForMM[to].prob_wt
  
      #for debugging
      #System.out.format("P:%f\t%s(%d:%s):%f -> %f -> %s(%d:%s):%f\n", P, mn[from].eojeol, 
      #     from, mn[from].wp_tag, mn[from].prob, PTT, 
      #      mn[to].eojeol, to, mn[to].wp_tag, mn[to].prob_wt );
    
      if aNodeForMM[to].backptr == 0 or p > aNodeForMM[to].prob then
        aNodeForMM[to].backptr = from
        aNodeForMM[to].prob = p
      end
    end
end
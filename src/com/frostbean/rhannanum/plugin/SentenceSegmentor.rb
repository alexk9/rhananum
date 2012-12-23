require "com/frostbean/rhannanum/plugin/PlaintextProcessor"

class SentenceSegmentor
  include PlainTextProcessor

  attr_accessor :document_id
  attr_reader :has_remaining_data

  def second_initialize base_dir, config_file
    @document_id = 0
    @sentence_id = 0
    @has_remaining_data = false
    @bufRes = nil
    @bufEojels = nil
    @bufEojeolsIdx = 0
    @end_of_document = false
  end

  def flush

  end

  def shutdown

  end

  def do_process ps
    eojeols = []
    res = ""
    is_first_eojeol = true
    is_eos = false
    i = j = 0

    if @bufEojels != nil then
      eojeols = @bufEojels
      i = @bufEojeolsIdx

      @bufEojels = nil
      @bufEojeolsIdx =0
    else
      if ps == nil then
        return nil
      end

      if @document_id != ps.document_id then
        @document_id = ps.document_id
        @sentence_id = 0
      end

      str = nil

      if (str = ps.sentence) == nil then
        return nil
      end

      eojeols = str.split("\s")
      @end_of_document = ps.end_of_document
    end

    while is_eos == false and i < eojeols.length do
      if not( /.*(\.|\!|\?).*/.match( eojeols[i])) then
        #이 어절에는 '.','!','?' 가없다.
        if is_first_eojeol then
          res = eojeols[i]
          is_first_eojeol = false
        else
          res += " " +eojeols[i]
        end
      else
        #어절에위의특수문자가있는경우
        ca = eojeols[i].split(//)
        j = 0
        while is_eos == false and j < ca.length do
          case ca[j]
            when "." then
              if j == 1 then
                #말줄임표
                next
              elsif j > 0
                #축약어
                if ca[j-1]==ca[j-1].downcase or ca[j-1]==ca[j-1].upcase then
                  next
                end
              elsif j < ca.length-1 then
                #number
                if ca[j+1].to_i.to_s == ca[j+1] then
                  next
                end
              end

              is_eos = true
            when "!" then
              is_eos = true
            when "?" then
              is_eos = true
          end

          if is_eos then
            if is_first_eojeol
              res = eojeols[i][0,j] + " " + ca[j]
              is_first_eojeol = false
            else
              res += " " + eojeols[i][0,j] + " " + ca[j]
            end
          end

          #a sequence of symbols such as '...', '?!!'
          while j< ca.length-1 do
            if is_symbol?( ca[j+1]) then
              j+= 1
              res += ca[j]
            else
              break
            end
          end
          j += 1
        end
        if is_eos  == false then
          if is_first_eojeol then
            res = eojeols[i]
            is_first_eojeol = false
          else
            res += " " +eojeols[i]
          end
        end
      end
      i += 1
    end
      i-=1
      j-=1

    if is_eos  then
      ##the remaining part of an eojeol after the end of sentence is stored in the buffer
      #if j+1 < eojeols[i].length then
      #  eojeols[i] = eojeols[i][j+1..-1]
      #  @bufEojels = eojeols
      #  @bufEojeolsIdx = i
      #  @has_remaining_data = true
      #else
      #  if i == eojeols.length-1 then
      #    #all eojeols were processed
      #    @has_remaining_data = false
      #  else
      #    #if there were some eojeols not processed, they were stored in the buffer
      #    @bufEojels = eojeols
      #    @bufEojeolsIdx = i +1
      #    @has_remaining_data = true
      #  end
      #end
      #if @bufRes == nil then
      #  @sentence_id +=1
      #  return PlainSentence.new(@document_id, @sentence_id, !@has_remaining_data and @end_of_document, res )
      #else
      #  res = @bufRes + " " + res
      #  @bufRes = nil
      #  @sentence_id +=1
      #  return PlainSentence.new(@document_id, @sentence_id, !@has_remaining_data and @end_of_document, res )
      #end
    else
      if res != nil and res.length > 0 then
        @bufRes = res

      end
      @has_remaining_data = false
      return nil
    end
  end
  
    
  def has_remaining_data? 
    return @has_remaining_data
  end


  private

  def is_symbol? char
    case char
      when ')' then
        return true
      when ']' then
        return true
      when '}' then return true
      when '?' then return true
      when '!' then return true
      when '.' then return true
      when '\'' then return true
      when '\"' then return true
      else
        return false
    end
  end

end

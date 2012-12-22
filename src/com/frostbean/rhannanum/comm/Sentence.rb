require "com/frostbean/rhannanum/comm/CommObject"

class Sentence < CommObject


  def initialize(document_id, sentence_id, end_of_document, plainEojeols=nil, eojeols=nil)


#    super.document_id = document_id
#    super.sentence_id = sentence_id
#    super.end_of_document = end_of_document
#
    @eojeols = eojeols
    @plainEojeols = plainEojeols

    if @eojeols != nil and @plainEojeols != nil then
      if @plainEojeols.length <= @eojeols.length then
        @length = @eojeols.length
      else
        @length = @plainEojeols.length
      end
    else
      @length = 0
    end
  end

  def get_eojeols
    return @eojeols
  end

  def get_eojeols(index)
    return @eojeols[index]
  end

  def set_eojeols( eojeols)
    @eojeols = eojeols
    @length = @eojeols.length
  end

  def set_eojeol(index, eojeol)
    @eojeols[index] = eojeol
  end

  def set_eojeol(index, morphemes, tags)
    eojeols[index] = Eojeol.new(morphemes, tags)
  end

  def toString
    str = ""
    for i in 0..(@length-1) do
      str += @plainEojeols[i] + "\n"
      str += "\t" + @eojeols.toString + "\n\n"
    end

    return str
  end

  def get_plain_eojeols
    return @plainEojeols
  end

  def set_plain_eojeols( plainEojeols)
    @plainEojeols = plainEojeols
  end

end

require "com/frostbean/rhannanum/comm/CommObject"

class PlainSentence < CommObject

  attr_accessor :sentence, :document_id

  def initialize document_id, sentence_id, end_of_document
    @document_id = document_id
    @sentence_id = sentence_id
    @end_of_document = end_of_document
  end

  def initialize document_id, sentence_id, end_of_document, sentence
    @document_id = document_id
    @sentence_id = sentence_id
    @end_of_document = end_of_document
    @sentence = sentence
  end


  def to_s
    if @sentence == nil then
      return ""
    else
      return @sentence
    end
  end

end
# encoding: utf-8
$: << File.join(File.expand_path(File.dirname(__FILE__)))



require "com/frostbean/rhannanum/comm/Sentence"
require "com/frostbean/rhannanum/hannanum/WorkflowFactory"

workflow = WorkflowFactory.get_predefined_workflow( WorkflowFactory::WORKFLOW_NOUN_EXTRACTOR)
# Analysis using the work flow
workflow.activate_workflow( false )
document = "지난 9일 오전 7시29분 서울역 승강장. 토요일 새벽 4시50분 부산역을 출발한 KTX 열차에서 책가방을 멘 젊은이들이 쏟아져 나왔다. 서울시 공무원 시험을 치르기 위해 지방에서 올라온 수험생들이다."
workflow.analyze(document)
#test
result_list = workflow.get_result_of_document( Sentence.new(0, 0, false))

for s in result_list do
  eojeolArray = s.get_eojeols

  for i in 0..(eojeolArray.length-1) do
    if eojeolArray[i].length > 0 then
      morphemes = eojeolArray[i].get_morphemes
      for j in 0..(morphemes.length-1) do
        puts morphemes[j]
      end
      puts ", "
    end
  end
end




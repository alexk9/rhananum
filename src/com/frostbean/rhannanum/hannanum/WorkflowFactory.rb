require "com/frostbean/rhannanum/hannanum/Workflow"
require "com/frostbean/rhannanum/plugin/SentenceSegmentor"

class WorkflowFactory

  WORKFLOW_NOUN_EXTRACTOR = 0x03

  def self.get_predefined_workflow workflowFlag
    workflow = Workflow.new

    case workflowFlag
      when WORKFLOW_NOUN_EXTRACTOR then
        workflow.append_plain_text_processor( SentenceSegmentor.new, nil)
        #workflow.appendPlainTextProcessor(new InformalSentenceFilter(), null);

        #workflow.setMorphAnalyzer(new ChartMorphAnalyzer(), "conf/plugin/MajorPlugin/MorphAnalyzer/ChartMorphAnalyzer.json");
        #workflow.appendMorphemeProcessor(new UnknownProcessor(), null);

        #workflow.setPosTagger(new HMMTagger(), "conf/plugin/MajorPlugin/PosTagger/HmmPosTagger.json");
        #workflow.appendPosProcessor(new NounExtractor(), null);
    end

    return workflow
  end
end
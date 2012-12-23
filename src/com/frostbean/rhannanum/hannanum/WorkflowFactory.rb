require "com/frostbean/rhannanum/hannanum/Workflow"
require "com/frostbean/rhannanum/plugin/SentenceSegmentor"
require "com/frostbean/rhannanum/plugin/InformalSentenceFilter"
require "com/frostbean/rhannanum/plugin/ChartMorphAnalyzer"
require "com/frostbean/rhannanum/plugin/UnknownProcessor"
require "com/frostbean/rhannanum/plugin/HMMTagger"
require "com/frostbean/rhannanum/plugin/NounExtractor"

class WorkflowFactory

  WORKFLOW_NOUN_EXTRACTOR = 0x03

  def self.get_predefined_workflow workflowFlag
    workflow = Workflow.new

    case workflowFlag
      when WORKFLOW_NOUN_EXTRACTOR then
        workflow.append_plain_text_processor( SentenceSegmentor.new, nil)
        workflow.append_plain_text_processor( InformalSentenceFilter.new, nil)

        workflow.set_morph_analyzer( ChartMorphAnalyzer.new, "conf/plugin/MajorPlugin/MorphAnalyzer/ChartMorphAnalyzer.json");
        workflow.append_morpheme_processor( UnknownProcessor.new, nil);

        workflow.set_pos_tagger(HMMTagger.new, "conf/plugin/MajorPlugin/PosTagger/HmmPosTagger.json");
        workflow.append_pos_processor(NounExtractor.new, nil)
    end

    return workflow
  end
end
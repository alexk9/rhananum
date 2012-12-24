

##
# This class is for statistic data which is important to the Hidden Markov Model.
class ProbabilityDBM

  def initialize( fileName)
    #hash table
    @table = {}
    init(fileName)
  end

  def get_table
    return @table
  end

  def clear
    @table.clear
  end

	def get( key)
		return @table.get[key]
	end


	def init(fileName)
		f = File.open(fileName,"r:utf-8")
    line = ""


    while f.eof? == false  do
      line = f.readline
      tokens = line.split(" ")
      numbers = Array.new(tokens.length-1)

      for i in 0..(tokens.length-2) do
        numbers[i] = tokens[i+1].to_f
      end

      if tokens == nil or tokens[0] == nil or numbers == nil then
        puts "hi"
      end

      @table[tokens[0]] = numbers
    end

  end
end
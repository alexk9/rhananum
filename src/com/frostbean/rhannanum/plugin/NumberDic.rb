
class NumberDic
  def initialize
    # number automata */
    @num_automata = [
        # ACC, +, -, ., ,, n, etc.     */
        [ 0, 0, 0, 0, 0, 0, 0], # 0 */
        [ 0, 9, 9, 0, 0, 2, 0], # 1 */
        [ 1, 0, 0,11, 5, 3, 0], # 2 */
        [ 1, 0, 0,11, 5, 4, 0], # 3 */
        [ 1, 0, 0,11, 5,10, 0], # 4 */
        [ 0, 0, 0, 0, 0, 6, 0], # 5 */
        [ 0, 0, 0, 0, 0, 7, 0], # 6 */
        [ 0, 0, 0, 0, 0, 8, 0], # 7 */
        [ 1, 0, 0, 0, 5, 0, 0], # 8 */
        [ 0, 0, 0, 0, 0,10, 0], # 9 */
        [ 1, 0, 0,11, 0,10, 0], # 10 */
        [ 1, 0, 0, 0, 0,12, 0], # 11 */
        [ 1, 0, 0, 0, 0,12, 0]  # 12 */
    ]


  end

	def is_num(idx)
		if @num_automata[idx][0] == 1 then
			return true
		else
			return false
		end
	end

	def node_look(c,nidx)
		inp =0
    case c
      when "+" then
        inp = 1
      when "-" then
        inp = 2
      when "." then
        inp = 3
      when "," then
        inp = 4
      else
        if (true if Float(c) rescue false ) then
          inp = 5
        else
          inp = 6
        end
    end
    return @num_automata[nidx][inp]
  end
end


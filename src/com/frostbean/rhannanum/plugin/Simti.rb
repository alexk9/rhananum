 #
 #* SIMTI(SIMple Trie Index) library.
class Simti

	class HEADI
    attr_accessor :n_size, :f_size, :s_node,:s_free
		def initialize
		  @s_free = ST_FREE.new
		  @s_node = ST_NODE.new
      @n_size = 0
      @f_size = 0
    end
	end

	class ST_FREE
    attr_accessor :size, :next
    def initialize
      @size = 0
      @next = 0
    end
  end

	class ST_NF
    attr_accessor :node, :free
		def initialize
		  @node = ST_NODE.new
      @free = ST_FREE.new
    end
  end


	class ST_NODE
    attr_accessor :K, :CS, :I, :child
    def initialize
      @K = ""
      @CS = ""
      @I = 0
      @child = 0
    end

	end

  ST_NF_DEFAULT = 300000

	ST_MAX_WORD = 1024

	def initialize
	  @search_end = 0
    @search_word = []
    @search_idx = []
    @head = HEADI.new
    @nf = Array.new(ST_NF_DEFAULT){ ST_NF.new}
  end

	def alloc( size)
    i,prev_i = 0,0

    i = @head.s_free.next
    while i!=0 do
		  if @nf[i].free.size >= size then
        break
      end
      prev_i = i
      i = @nf[i].free.next
    end
		# there is no free node
		if i == 0 then
			puts "alloc:NO FREE NODE\n"
			return 0
		end

		if prev_i == 0 then #the head node
			if size == @nf[i].free.size then
				@head.s_free.next = @nf[i].free.next
			else
				@nf[i + size].free.size = @nf[i].free.size - size
				@head.s_free.next = i + size
				@nf[i + size].free.next = @nf[i].free.next
			end
		else 					# not the head node
			if size == @nf[i].free.size then
				@nf[prev_i].free.next = @nf[i].free.next
			else
				@nf[i + size].free.size = @nf[i].free.size - size
				@nf[prev_i].free.next = i + size
				@nf[i + size].free.next = @nf[i].free.next
			end
		end
		@head.f_size -= size
		return i
	end

	def fetch( word)
		search(word)

		if @search_end != word.length or word.length == 0 then
			return 0
    else
      return @nf[@search_idx[@search_end-1]].node.I
    end
	end

	def binary_search(idx, size, key)
    left,right,middle =0,0,0
		node = nil

		right =  size - 1
    while left <= right do
			middle = (left + right) / 2
			node = @nf[middle + idx].node
			if key > node.K then
				left = middle + 1
			elsif key < node.K then
				right = middle - 1
			else
				return (idx + middle)
      end
    end

		return 0
	end

	def delete( word)
		i, d, j=0,0,0
		idx, newidx=0,0
		size =0
		temp = nil
		node = ST_NODE.new

		search(word)
		if @search_end < word.length || word.length == 0  then
			return 0
    end

    temp= @nf[@search_idx[@search_end-1]].node

		if temp.I == 0 then
			return 0
    end

		node_copy(node, temp)

    i = @search_end-1
    while i>0 and node.CS==0 and node.I == 0 do
      @search_end-=1
      if i==1 then
        node_copy(node,@head.s_node)
      else
        node_copy(node,@nf[@search_idx[i-1]].node)
      end
      if node.CS == 1 then
        free(node.child,1)
        node.CS = 0
        node.child = 0
      else
        idx = node.child
        d = @search_idx[i] = idx
        size = node.CS

        newidx = alloc(size-1)
        j =0
        while j< d do
          tmp = @nf[newidx+j].node
          @nf[newidx+j].node = @nf[idx+j].node
          @nf[idx+j].node= tmp
          j+=1
        end

        j=0
        while j<size-d-1 do
          tmp = @nf[newidx+j].node
          @nf[newidx+j].node = @nf[idx+j].node
          @nf[idx+j].node = tmp
          j+=1
        end
        free(idx,size)
        node.CS-=1
        node.child=newidx
      end

      if i==1 then
        node_copy(@head.s_node,node)
      else
        node_copy(@nf[@search_idx[i-1]].node,node)
      end
      i-=1
    end
    return 1
  end

	def firstkey(word)

		index = @head.s_node.child
		cs = @head.s_node.CS

		i=0

		while cs != 0 do
			word[i] = @search_word[i] = @nf[index].node.K
			@search_idx[i] = index
			i+=1
			if @nf[index].node.I != 0 then
				break
      end
			cs = @nf[index].node.CS
			index = @nf[index].node.child
		end
		word[i] = 0
		return @search_end = i
	end

  def free(idx, size)
		i, prev_i = 0,0
		start = nil

		if size <= 0 then
			return -1
    end

		if idx <= 0 || idx + size >= @head.n_size then
			return -1
    end

		i = @head.s_free.next

		#no free node
		if i == 0 then
			@head.s_free.next = idx
			@nf[idx].free.size = size
			@nf[idx].free.next = 0
			return 0
		end

		#idx is the smallest in free
		if idx < i then
			@head.s_free.next = idx
			if i == idx + size then
        @nf[idx].free.size = size + @nf[i].free.size
				@nf[idx].free.next = @nf[i].free.next
			else
				@nf[idx].free.size = size
				@nf[idx].free.next = i
			end
			@head.f_size += size
			return 0
		end

		#otherwise
		while i != 0 && i < idx do
			prev_i = i
			i = @nf[i].free.next
		end
		#prev_i != 0
		start = @nf[prev_i].free

		#next node is a free node
		if idx + size == i then
			size += @nf[i].free.size
			start.next = @nf[i].free.next
			@head.f_size -= @nf[i].free.size
		end

		if prev_i + start.size == idx then
			start.size += size
		else
			@nf[idx].free.size = size
			@nf[idx].free.next = start.next
			start.next = idx
		end
		@head.f_size += size
		return	0
	end

	def init()
		search_end = 0

		@head.n_size = ST_NF_DEFAULT
		@head.f_size = ST_NF_DEFAULT - 1

		@head.s_node.K = 0
		@head.s_node.CS = 0
		@head.s_node.I = 0
		@head.s_node.child = 0

		@head.s_free.size = 0
		@head.s_free.next = 1

		# nf[0] is not used */
		@nf[1].free.size = ST_NF_DEFAULT - 1
		@nf[1].free.next = 0
	end

	def insert( word,  arg_I)
		child_index, new_index = 0,0
		i, j, k =0,0,0
		cs =0
		parent =0
		tmp_node = ST_NODE.new

		tmp_node.child = 0
		tmp_node.CS = 0
		tmp_node.I = 0
		tmp_node.K = 0

		k = 0
		if word.length == 0 then
			return -1
    end

		search(word)
		k += @search_end

		if @search_end == 0 then
			parent = @head.s_node
		else
			parent = @nf[@search_idx[@search_end - 1]].node
		end

		while k < word.length do
			cs = parent.CS;
			if cs == 0 then 			# no child
				new_index = alloc(1);
				node_copy(@nf[new_index].node, tmp_node)
				@nf[new_index].node.K = word[k]

				parent.CS = 1
				parent.child = new_index
				@search_idx[@search_end] = new_index
				@search_word[@search_end] = word[k]
				@search_end+=1
				k+=1
				parent = @nf[new_index].node
			else
				new_index = alloc(cs + 1)
				child_index = parent.child
				for i in 0..(cs-1) do
					if @nf[child_index + i].node.K < word[k] then
						node = @nf[new_index + i].node
						@nf[new_index + i].node = @nf[child_index + i].node
						@nf[child_index + i].node = node
					else
						break
					end
				end

				node_copy(@nf[new_index + i].node, tmp_node)
				@nf[new_index + i].node.K = word[k]

				@search_idx[@search_end] = new_index + i
				@search_word[@search_end] = word[k]
				@search_end+=1
				k+=1

        j=i
        while j<cs do
        	node = @nf[new_index + j + 1].node
					@nf[new_index + j + 1].node = @nf[child_index + j].node
					@nf[child_index + j].node = node
          j+=1
        end
				parent.child = new_index
				parent.CS = cs + 1
				free(child_index, cs)

				parent = @nf[new_index + i].node
			end
		end

		if parent.I == 0 then
			parent.I = arg_I
			return 1
		else
			return 0
		end
	end

  def kcomp(a, b)
		return a.K - b.K
	end

	def lookup( word,  i_buffer)
		i= 0
		if search(word) == 0 then
			return 0
		else
			for i in 0..(@search_end-1) do
				i_buffer[i] = @nf[@search_idx[i]].node.I
			end
		end
		return @search_end
	end

	def nextkey( word)
		i, index, cs =0
		parent = nil

		if @search_end <= 0 then
			return 0
    end

		for i in 0..(@search_end-1) do
			word[i] = @search_word[i]

		  #i equals with the search_end
		  index = @search_idx[i - 1]
		  if i == 1 then
			  parent = @head.s_node
		  else
			  parent = @nf[@search_idx[i - 2]].node
      end
		  cs = @nf[index].node.CS

		  #parent -. index -. child
		  #          sibling
		  while i > 0 do
			  if cs != 0 then  			# there is a child
				  parent = @nf[index].node
				  index =  @nf[index].node.child
				  cs = @nf[index].node.CS

				  word[i] = @search_word[i] = @nf[index].node.K
				  @search_idx[i] = index
				  i+=1
				  if @nf[index].node.I != 0 then
					  break
				  end
			  elsif  index < parent.child + parent.CS - 1 # there is a sibling
				  index+=1
				  cs = @nf[index].node.CS

          word[i - 1] = @search_word[i - 1] = @nf[index].node.K
          @search_idx[i - 1] = index
          if @nf[index].node.I != 0 then
            break
          end
			  else 	#there is no child and sibling
				i-=1
				if i <= 0 then
					i = 0
					break
				end
				index = @search_idx[i - 1]
				if i == 1 then
					parent = @head.s_node
				else
					parent = @nf[@search_idx[i - 2]].node
				end
				cs = 0
			end
		end
		word[i] = 0

    end
      return @search_end = i
    end

	def node_copy(n1, n2)
		n1.child = n2.child
		n1.CS = n2.CS
		n1.I = n2.I
		n1.K = n2.K
	end

	def replace(word, arg_I)
		i = 0

		if word.length == 0 then
			return -1
    end

		search(word)
		i += @search_end

		if @search_end == 0 || i < word.length then
			return -1
		else
			@nf[@search_idx[@search_end - 1]].node.I = arg_I
			return 1
		end
	end

	def search( word)
		i, j, k =
		tmpnode = ST_NODE.new
		rnode = nil
		child= nil
		cs = nil

    i,j=0,0
    while  j < word.length && i < @search_end do
			if word[j] == @search_word[i] then
				j+=1
      else
        break
      end
      i+=1
		end

		@search_end = i
		if @search_end == 0  then
			cs = @head.s_node.CS
			child = @head.s_node.child
		else
			child = @search_idx[@search_end-1]
			cs = @nf[child].node.CS;
			child = @nf[child].node.child
    end

		while j < word.length && cs != 0 do
			tmpnode.K=word[j]
			rnode = nil

			for k in child..(child + cs-1) do
				if tmpnode.K == @nf[k].node.K then
					rnode = @nf[k].node
					break
				end
			end

			if rnode == nil then break
			else
				@search_word[@search_end] = word[j]
				@search_idx[@search_end] = k
				@search_end+=1
				j+=1
				child = @nf[k].node.child
				cs = @nf[k].node.CS
			end
		end
		return @search_end
	end
end

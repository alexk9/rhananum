
class Trie

  class FREE
    attr_accessor :size, :next_idx
  end

  class INFO
    attr_accessor :tag, :phoneme
  end

  class TNODE
    attr_accessor :key, :child_size, :child_idx, :info_list, :free

    def initialize
      @free = FREE.new
    end
  end

  #the default buffer size for the system dictionary */
	DEFAULT_TRIE_BUF_SIZE_SYS = 1060000

	#the default buffer size for the user dictionary */
	DEFAULT_TRIE_BUF_SIZE_USER = 106000

	#the index of the free node */
	FREE_NODE = 0

	#the index of the start node */
	START_NODE = 1

  def initialize(buf_size)
  	@search_idx = Array.new(256)
		@search_key = Array.new(256)
		@search_end = 0

		@trie_buf = Array.new(buf_size)
    for i in 0..(buf_size-1) do
      @trie_buf[i] = TNODE.new
    end

		@free_head = trie_buf[FREE_NODE].free
		@node_head = trie_buf[FREE_NODE]

		@node_head.key = 0
		@node_head.child_size = 0
		@node_head.info_list = []
		@node_head.child_idx = 0

		@free_head.size = 0
		@free_head.next_idx = 1

		# the node number 0 is not used
		@trie_buf[1].free.size = buf_size - 1
		@trie_buf[1].free.next_idx = FREE_NODE
	end

  def fetch(word)
	  x = search(word)
		if x == 0 then
			return nil
		else
			idx = @search_idx[x - 1]
			return @trie_buf[idx]
		end
	end

	def get_node(idx)
		return @trie_buf[idx]
	end

	def node_alloc(size)

		if size <= 0 then
			puts "node alloc: wrong size"
			return 0
		end

		pidx = FREE_NODE

    idx = @free_head.next_idx
    while idx != FREE_NODE do
      if @trie_buf[idx].free.size >= size then
        break
      end
      pidx = idx
      idx= @trie_buf[idx].free.next_idx
    end

    if idx ==0 then
      puts "node alloc: no space"
			return 0
		end

		if pidx == FREE_NODE then
			if size == @trie_buf[idx].free.size then
				@free_head.next_idx = @trie_buf[idx].free.next_idx
			else
				@trie_buf[idx + size].free.size = @trie_buf[idx].free.size - size
				@trie_buf[idx + size].free.next_idx = @trie_buf[idx].free.next_idx
				@free_head.next_idx = idx + size
			end
		else
			if size == @trie_buf[idx].free.size then
				@trie_buf[pidx].free.next_idx = @trie_buf[idx].free.next_idx
			else
				@trie_buf[idx + size].free.size = @trie_buf[idx].free.size - size
				@trie_buf[idx + size].free.next_idx = @trie_buf[idx].free.next_idx
				@trie_buf[pidx].free.next_idx = idx + size
			end
		end

		return idx
	end

	def node_free(fidx, size )
		idx, pidx = 0,0

		if size <= 0 or fidx <= FREE_NODE then
			puts "node_free: wrong parameter"
			exit
		end

		idx = @free_head.next_idx
		if idx == FREE_NODE then
			#if there was no free nodes, simply updates the header pointer with the new free node
			@free_head.next_idx = fidx					#the start index of free nodes
			@trie_buf[fidx].free.size = size			# the size of free nodes
			@trie_buf[fidx].free.next_idx = FREE_NODE	#the end of the free node list
			return
		end

		if fidx < idx then
			#the new free nodes are in front compared to the existing free node list
			@free_head.next_idx	= fidx
			if idx == fidx + size then
				#if they are consecutive, they are merged.
				@trie_buf[fidx].free.size = size + @trie_buf[idx].free.size
				@trie_buf[fidx].free.next_idx = @trie_buf[idx].free.next_idx
			else
				#if they are not consecutive, they are separated
				@trie_buf[fidx].free.size = size
				@trie_buf[fidx].free.next_idx = idx
			end
			return
		end

		#checks the location of the existing free node list and merge them
		while idx != FREE_NODE and idx < fidx do
			pidx = idx
			idx = @trie_buf[idx].free.next_idx
		end
		start = @trie_buf[pidx].free

		if fidx + size == idx then
			#free nodes in back
			size += @trie_buf[idx].free.size
			start.next_idx = @trie_buf[idx].free.next_idx
		end

		if pidx + start.size == fidx then
			#free nodes in front
			start.size += size
		else
			#merges the free nodes
			@trie_buf[fidx].free.size = size
			@trie_buf[fidx].free.next_idx = start.next_idx
			start.next_idx = fidx
		end
	end

	def node_look(key, idx)
		TNODE parent = nil

		if idx == 1 then
			parent = @node_head
		else
			parent = @trie_buf[idx]
		end

    i = parent.child_idx
    while i<parent.child_idx+parent.child_size do
      if @trie_buf[i].key == key then
        return i
      end
      i+=1
    end

		return 0
	end

	def print_result( tagSet)

		#try {
		#	PrintWriter pw = new PrintWriter("data/kE/output.txt");
		#	for (int k = 0; k < node_head.child_size; k++) {
		#		print_trie(pw, node_head.child_idx + k, 0, tagSet);
		#	}
		#	for (int ii = free_head.next_idx; ii != 0; ii = trie_buf[ii].free.next_idx) {
		#		pw.print("[n:" + ii + " s:" + trie_buf[ii].free.size + "] ");
		#	}
		#	pw.println();
		#	pw.flush();
		#	pw.close();
		#} catch (FileNotFoundException e) {
		#	e.printStackTrace();
		#}
	end

	def print_trie( pw, idx, depth,tagSet)
	#public void print_trie(PrintWriter pw, int idx, int depth, TagSet tagSet) {
	#	for (int i = 0; i < depth; i++) {
	#		pw.print("\t");
	#	}
	#	pw.print(idx + ":" + Code.toCompatibilityJamo(trie_buf[idx].key) + " ");
	#	if (trie_buf[idx].info_list != null) {
	#		for (int k = 0; k < trie_buf[idx].info_list.size(); k++) {
	#			pw.print("t:" + tagSet.getTagName(trie_buf[idx].info_list.get(k).tag) + " ");
	#		}
	#	}
	#	pw.println();
	#	for (int i = 0; i < trie_buf[idx].child_size; i++) {
	#		print_trie(pw, trie_buf[idx].child_idx + i, depth + 1, tagSet);
	#	}
	#}
  end


	def read_dic(dictionaryFileName, tagSet)
		str = ""
    f = File.open(dictionaryFileName, "r:utf-8")
    info_list = Array.new(255){INFO.new}

    while f.eof? == false do
		  str= f.readline()
      str.strip

			if str == "" then
				next
			end

      tok = str.split(/\t/)
			word = tok[0]

			isize = 0

      for i in 1..(tok.size-1) do
        data = tok[i]
        tok2 = data.split(/\./)
        curt = tok2[0]
        x = tagSet.get_tag_id(curt)
        if x==-1 then
          puts "ERROR"
          next
        end

        if tok2.size >1 then
          info_list[isize].phoneme = tagSet.get_irregular_id(tok2[1])
        else
          info_list[isize].phoneme = TagSet:PHONEME_TYPE_ALL
        end
        info_list[isize].tag = x
        isize+=1
      end

			info_list[isize].tag = 0
			info_list[isize].phoneme = 0

			word3 = Code.to_triple_array(word)
      for i in 0..(isize-1) do
        store(word3,info_list[i])
      end
    end
  end

  def search(word)
    widx = 0
		nidx = 0
		i = 0

		#cache - it reuses the previous search result, if available
    i=0
    while widx < word.length and i< @search_end do
      if word[i] == @search_key[i] then
        widx+=1
      else
        break
      end
      i+=1
    end

    @search_end = i

		if @search_end == 0 then
			# some of data in cache is used
			cs = @node_head.child_size
			child = @node_head.child_idx
			nidx = 0
		else
			# without previous search result
			child = @search_idx[@search_end - 1]
			cs = @trie_buf[child].child_size
			child = @trie_buf[child].child_idx
			nidx = @search_idx[@search_end - 1]
		end

		while widx < word.length do
			if cs == 0 then
				return 0
			end

			# checks the children of the node
			key = word[widx]
			rnode = nil
			nidx = 0
      for j in child..(child+cs-1) do
        if key	== @trie_buf[j].key then
					rnode = @trie_buf[j]
					nidx = j
					break
				end
			end

			if rnode == nil then
				# matching finished
				break
			else
				# matching not finished
				@search_key[@search_end] = key
				@search_idx[@search_end] = nidx
				@search_end++
				widx++
				child = @trie_buf[nidx].child_idx
				cs = @trie_buf[nidx].child_size
			end
		end

		if @trie_buf[nidx].info_list == null or @trie_buf[nidx].info_list.size() == 0 then
			return 0
		else
			return @search_end
		end
	end

  def store( word, inode)

		if word.length == 0 then
			return -1
		end
		# it first searches the trie structure with the word
		search(word)

		# it stores the part of the word not in the structure
		widx = @search_end
		if @search_end == 0 then
			parent = @node_head
		else
			parent = @trie_buf[@search_idx[@search_end - 1]]
		end

		while widx < word.length then
			c = word[widx]
			cs = parent.child_size
			if cs == 0 then
				# if it has no child, allocates a new child
				new_index = node_alloc(1)
				@trie_buf[new_index].key = c
				@trie_buf[new_index].child_idx = 0
				@trie_buf[new_index].child_size = 0
				parent.child_size = 1
				parent.child_idx = new_index
				search_idx[search_end] = new_index
				search_key[search_end] = c
				search_end+=1
				widx+=1
				parent = @trie_buf[new_index]
			else
				# if it has more than one child, allocates (cs + 1) nodes, and copy the existing children
				new_index = node_alloc(cs + 1)
				child_index = parent.child_idx
				for i in 0..(cs-1) do
					if @trie_buf[child_index + i].key < c then
						tmp = @trie_buf[new_index + i]
						@trie_buf[new_index + i] = @trie_buf[child_index + i]
						@trie_buf[child_index + i] = tmp
					else
						break
					end
				end
				@trie_buf[new_index + i].key = c
				@trie_buf[new_index + i].child_idx = 0
				@trie_buf[new_index + i].child_size = 0
				@search_idx[search_end]	= new_index + i
				@search_key[search_end]	= c
				@search_end+=1
				widx+=1

        j = i
        while j < cs do
        	tmp = @trie_buf[new_index + j + 1]
					@trie_buf[new_index + j + 1]	= @trie_buf[child_index + j]
					@trie_buf[child_index + j] = tmp
          j+=1
        end

				parent.child_idx = new_index
				parent.child_size = cs + 1)

				node_free(child_index, cs)
				parent = @trie_buf[new_index + i]
			end
		end

		#inserts the information to the word
		if parent.info_list == nil then
			parent.info_list = []
		end

		in = INFO.new
		in.phoneme = inode.phoneme
		in.tag = inode.tag

		parent.info_list << in

		return 0
	end
end
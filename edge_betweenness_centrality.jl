function node_edge_dict(g::AbstractGraph)
  node_edge_dict = Dict{Tuple{Int64,Int64},Int64}()
  edgess = collect(edges(g))
  for e in 1:ne(g)
    push!(node_edge_dict,(src(edgess[e]),dst(edgess[e]))=>e)
    push!(node_edge_dict,(dst(edgess[e]),src(edgess[e]))=>e)
  end
  return node_edge_dict
end

function edge_betweenness_centrality(g::AbstractGraph,node_edge_dict::Dict{Tuple{Int64,Int64},Int64}) 
  edge_betweenness = zeros(Float64,ne(g))
  for root in vertices(g)
    values = zeros(Float64,ne(g))
    dist_array = zeros(Int64,nv(g))
    n_paths_array = zeros(Int64,nv(g))
    dict = Dict{Int64,Vector{Int64}}(1=>[root])
    queue = Int64[root]
    visited = Int64[root]
    dist_array[root] = 0
    n_paths_array[root] = 1

    while !isempty(queue)
      for i in neighbors(g,queue[1])
        if !(i in visited)
          push!(queue,i)
          push!(visited,i)
          dist_array[i] = dist_array[queue[1]]+1

          if haskey(dict,Int64(dist_array[i]+1))
            push!(dict[Int64(dist_array[i]+1)],i)
          else
            push!(dict,Int64(dist_array[i]+1) => [i])
          end
          n_paths_array[i] = sum((has_edge(g,i,j) ? n_paths_array[j] : 0) for j in dict[Int64(dist_array[i])])
        end
      end
      popfirst!(queue)
    end

    weights = zeros(nv(g))
    visit = dict[length(keys(dict))]
    for i in length(keys(dict))-1:-1:1
      nodes = dict[i]
      for k in 1:length(nodes)
        for j in neighbors(g,nodes[k])
          if j in visit
            values[node_edge_dict[(j,nodes[k])]] = n_paths_array[nodes[k]]/n_paths_array[j]*(weights[j]+1)
            weights[nodes[k]]+=values[node_edge_dict[(j,nodes[k])]]
          end
        end
      end
      visit = nodes
    end
    edge_betweenness.+=values
  end

  return edge_betweenness./2
end
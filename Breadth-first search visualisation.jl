using GLMakie, GraphMakie, Graphs # packages

function visualize_BFS(N,M,root)
  fig = Figure() # create a Figure
  graph_ax = Axis(fig[1:3,1:2],title = "graph",titlesize = 30) # create an axis for the graph
  hidedecorations!(graph_ax) # hide ticks and labels of the graph axis
  spt_ax = Axis(fig[1:3,3:4],title = "shortest path tree",titlesize = 30) # create an axis for the shortest path tree
  hidedecorations!(spt_ax) # hide ticks and labels of the shortest path tree axis
  qv_ax = Axis(fig[4,1:4]) # create an axis for the queue and visited arrays
  hidedecorations!(qv_ax) # hide ticks and labels of the queue and visited array axis

  # create the node color legend ######################################################
  elem_1 = [MarkerElement(color = :black, marker = "●", markersize = 30)]
  elem_2 = [MarkerElement(color = :blue, marker = "●", markersize = 30)]
  elem_3 = [MarkerElement(color = :darkred, marker = "●", markersize = 30)]
  elem_4 = [MarkerElement(color = :green, marker = "●", markersize = 30)]
  Legend(fig[5,1:4],
  [elem_1,elem_2,elem_3,elem_4],
  ["remaining","visited","all neighbors checked","root"],
  patchsize = (35, 35),
  rowgap = 10,
  orientation = :horizontal,
  tellwidth = false)
  #####################################################################################

  node_colors = Node(pushfirst!(fill(:black,N-1),:green)) # initialize the observable that holds the colors of the nodes
  queue_text = Node("queue=[$root]") # initialize the observable that holds the string representing the values of the queue array
  visited_text = Node("visited=[]") # initialize the observable that holds the string representing the values of the visited array

  # plot the queue and visited arrays #################################################
  text!(qv_ax,queue_text,position = (0, .5), align = (:center, :center))
  text!(qv_ax,visited_text,position = (0, -.5), align = (:center, :center))
  ylims!(qv_ax,-1,1)
  #####################################################################################

  g = SimpleGraph(N,M) # create a random undirected graph with N nodes and M edges (you can also set this to a specific graph)
  shortest_path_tree = Node(SimpleGraph(nv(g),0)) # create an ovservalbe that holds an undirected graph with N nodes and 0 edges

  # plot the graph and the shortest path tree into their axis #########################
  p = graphplot!(graph_ax,g,
  node_size = [30 for i in 1:nv(g)],
  nlabels_align=(:center, :center),
  nlabels=string.(1:nv(g)),
  node_color = node_colors,
  nlabels_color = :white
  )
  p2 = graphplot!(spt_ax,shortest_path_tree,
  node_size = [30 for i in 1:nv(g)],
  nlabels_align=(:center, :center),
  nlabels=string.(1:nv(g)),
  node_color = node_colors,
  nlabels_color = :white
  )
  p2[:node_pos][] = p[:node_pos][] # make both graphs have the same layout
  autolimits!(spt_ax)
  #####################################################################################

  display(fig) # display the figure in a seperate window
  sleep(1) # wait before starting the algorithm

  # Breadth-first search algorithm ####################################################
  begin
    queue = Int64[root] 
    visited = Int64[root] 
    while !isempty(queue) 
      for i in neighbors(g,queue[1]) 
        if !(i in visited)
          push!(queue,i)
          push!(visited,i)

          # add edge to the shortest path tree #########################
          t = shortest_path_tree[]
          add_edge!(t,queue[1],i)
          shortest_path_tree[] = t
          p2[:node_pos][] = p[:node_pos][]
          autolimits!(spt_ax)
          ##############################################################

          # color visited node blue ####################################
          c = node_colors[]
          c[i]=:blue
          node_colors[] = c
          ##############################################################

          queue_text[]="queue="*string(queue) # update the queue array plot
          visited_text[]="visited="*string(visited) # update the visited array plot
          sleep(0.4) # wait for human comprehension
        end
      end

      # color node red when all neighbors visited ######################
      if queue[1] != root
        c = node_colors[]
        c[queue[1]]=:darkred 
        node_colors[] = c
      end
      ##################################################################

      popfirst!(queue)
      if length(queue) != 0
        queue_text[]="queue="*string(queue) # update the queue array plot
        sleep(0.4) # wait for human comprehension
      end
    end
    queue_text[]="queue=[]" # update the queue array plot
  end
  #####################################################################################

  return
end

visualize_BFS(10,15,1) # run the function for N = 10, M = 15 and root = 1

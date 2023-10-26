abstract type SpanningTreeAlgorithm end

struct BFS <: SpanningTreeAlgorithm end
struct RandomBFS <: SpanningTreeAlgorithm end
struct DFS <: SpanningTreeAlgorithm end

default_spanning_tree_alg() = BFS()

default_root_vertex(g) = last(findmax(eccentricities(g)))

function spanning_tree(g::AbstractNamedGraph; root_vertex=default_root_vertex(g))
  return spanning_tree(default_spanning_tree_alg(), g; root_vertex)
end

function spanning_tree(::BFS, g::AbstractNamedGraph; root_vertex=default_root_vertex(g))
  @assert !NamedGraphs.is_directed(g)
  return undirected_graph(bfs_tree(g, root_vertex))
end

function spanning_tree(
  ::RandomBFS, g::AbstractNamedGraph; root_vertex=default_root_vertex(g)
)
  @assert !NamedGraphs.is_directed(g)
  return undirected_graph(random_bfs_tree(g, root_vertex))
end

function spanning_tree(::DFS, g::AbstractNamedGraph; root_vertex=default_root_vertex(g))
  @assert !NamedGraphs.is_directed(g)
  return undirected_graph(dfs_tree(g, root_vertex))
end

#Given a graph, split it into its connected components, construct a spanning tree over each of them
# and take the union.
function spanning_forest(g::AbstractNamedGraph; spanning_tree_function=spanning_tree)
  return reduce(union, (spanning_tree_function(g[vs]) for vs in connected_components(g)))
end

#Given an undirected graph g with vertex set V, build a set of forests (each with vertex set V) which covers all edges in g
# (see https://en.wikipedia.org/wiki/Arboricity) We do not find the minimum but our tests show this algorithm performs well
function forest_cover(g::AbstractNamedGraph; spanning_tree_function=spanning_tree)
  edges_collected = edgetype(g)[]
  remaining_edges = edges(g)
  forests = NamedGraph[]
  while !isempty(remaining_edges)
    g_reduced = rem_edges(g, edges_collected)
    g_reduced_spanning_forest = spanning_forest(g_reduced; spanning_tree_function)
    push!(edges_collected, edges(g_reduced_spanning_forest)...)
    push!(forests, g_reduced_spanning_forest)
    setdiff!(remaining_edges, edges(g_reduced_spanning_forest))
  end

  return forests
end
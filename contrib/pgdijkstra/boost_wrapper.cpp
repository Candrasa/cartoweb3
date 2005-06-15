#include <boost/config.hpp>
#include <iostream>
#include <fstream>

#include <boost/graph/graph_traits.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>

#include "dijkstra.h"

using namespace std;
using namespace boost;

/*
//	FIXME: use this to avoid heap allocation ?

void* operator new(size_t size)
{
return palloc(size);
}

void operator delete(void *p)
{
    pfree(p);
}

*/

// Maximal number of nodes in the path (to avoid infinite loops)
#define MAX_NODES 1000000

struct Vertex
{
    int id;
    float8 cost;
};


int 
boost_dijkstra(edge_t *edges, unsigned int count, int start_vertex, int end_vertex,
	       bool directed, bool has_reverse_cost,
	       path_element_t **path, int *path_count, char **err_msg)
{

    // FIXME: use a template for the directedS parameters
    typedef adjacency_list < listS, vecS, directedS, no_property, Vertex> graph_t;

    typedef graph_traits < graph_t >::vertex_descriptor vertex_descriptor;
    typedef graph_traits < graph_t >::edge_descriptor edge_descriptor;
    typedef std::pair<int, int> Edge;

    // FIXME: compute this value
    const unsigned int num_nodes = ((directed && has_reverse_cost ? 2 : 1) * count) + 100;

    graph_t graph(num_nodes);

    property_map<graph_t, edge_weight_t>::type weightmap = get(edge_weight, graph);

    for (std::size_t j = 0; j < count; ++j)
    {
	edge_descriptor e; bool inserted;
	tie(e, inserted) = add_edge(edges[j].source, edges[j].target, graph);

	graph[e].cost = edges[j].cost;
	graph[e].id = edges[j].id;
				
	if (!directed || (directed && has_reverse_cost))
	{
	    tie(e, inserted) = add_edge(edges[j].target, edges[j].source, graph);
	    graph[e].id = edges[j].id;

	    if (has_reverse_cost)
	    {
		graph[e].cost = edges[j].reverse_cost;
	    }
	    else 
	    {
		graph[e].cost = edges[j].cost;
	    }
	}
    }

    std::vector<vertex_descriptor> predecessors(num_vertices(graph));

    vertex_descriptor _source = vertex(start_vertex, graph);

    if (_source < 0 || _source >= num_nodes) 
    {
	*err_msg = "Starting vertex not found";
	return -1;
    }

    vertex_descriptor _target = vertex(end_vertex, graph);
    if (_target < 0 || _target >= num_nodes)
    {
	*err_msg = "Ending vertex not found";
	return -1;
    }

    std::vector<float8> distances(num_vertices(graph));
    dijkstra_shortest_paths(graph, _source,
			    predecessor_map(&predecessors[0]).
			    weight_map(get(&Vertex::cost, graph))
			    .distance_map(&distances[0]));

    vector<int> path_vect;
    int max = MAX_NODES;
    path_vect.push_back(_target);
    while (_target != _source) 
    {
	if (_target == predecessors[_target]) 
	{
	    *err_msg = "No path found";
	    return -1;
	}
	_target = predecessors[_target];

	path_vect.push_back(_target);
	if (!max--) 
	{
	    *err_msg = "Overflow";
	    return -1;
	}
    }

    *path = (path_element_t *) malloc(sizeof(path_element_t) * (path_vect.size() + 1));
    *path_count = path_vect.size();

    for(int i = path_vect.size() - 1, j = 0; i >= 0; i--, j++)
    {
	graph_traits < graph_t >::vertex_descriptor v_src;
	graph_traits < graph_t >::vertex_descriptor v_targ;
	graph_traits < graph_t >::edge_descriptor e;
	graph_traits < graph_t >::out_edge_iterator out_i, out_end;

	(*path)[j].vertex_id = path_vect.at(i);

	(*path)[j].edge_id = -1;
	(*path)[j].cost = distances[_target];
	
	if (i == 0) 
	{
	    continue;
	}

	v_src = path_vect.at(i);
	v_targ = path_vect.at(i - 1);

	for (tie(out_i, out_end) = out_edges(v_src, graph); 
	     out_i != out_end; ++out_i)
	{
	    graph_traits < graph_t >::vertex_descriptor v, targ;
	    e = *out_i;
	    v = source(e, graph);
	    targ = target(e, graph);
								
	    if (targ == v_targ)
	    {
		(*path)[j].edge_id = graph[*out_i].id;
		(*path)[j].cost = graph[*out_i].cost;
		break;
	    }
	}
    }

    return EXIT_SUCCESS;
}

#if 0

// Testing function

#define NUM_EDGES 100
int main() {
		
    edge_t *e;

    e = (edge_t *)malloc(NUM_EDGES * sizeof(edge_t));
    if (!e)
	return -1;

    for (int i = 0; i < NUM_EDGES; i++) 
    {
	e[i].id = i;
	e[i].source = i;
	e[i].target = (i + 1 > NUM_EDGES) ? 0 : i + 1;
	e[i].cost = 1;
    }

    char *err_msg = NULL;
    path_element_t *path;
    int ret;
    int path_count;

    int final_edges = NUM_EDGES - 1;

    ret = boost_dijkstra(e, NUM_EDGES, 0, final_edges, 1, 0, &path, &path_count, &err_msg);

    if (ret < 0) 
    {
	printf("Error: %s\n", err_msg);

    } else {
	printf("Path is :\n");
	for (int i = 0; i < path_count; i++) 
	{
	    printf("Step %i vertex_id  %i \n", i, path[i].vertex_id);
	    printf("        edge_id    %i \n", path[i].edge_id);
	    printf("        cost       %f \n", path[i].cost);
	}
	free(path);
    }
    printf("\n");
    free(e);
}
#endif

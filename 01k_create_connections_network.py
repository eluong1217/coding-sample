'''
*Program: 01k_create_connections_network.py
*Written by: Eric Luong
*Created: 20/07/25
/* Purpose: Create network connections from an adjacency matrix.

How to use:
1. Input your adjacency matrix file as variable `matrix_input`.
2. Set `smallFile` to True if the file is small enough to print a graph
3. Create graphs using nth_degree_network function
4. Export the data to GML and CSV files using the export function.

Testing Finished: 20/07/25
'''

import numpy as np
import pandas as pd
import networkx as nx
import os
import matplotlib.pyplot as plt
from timeit import default_timer as timer

# Set up the working directory and input file
origin = "/Users/ericluong/Documents/ECON_Research/LN_MJ001/Data"
destination = "/Users/ericluong/Documents/ECON_Research/LN_MJ001/Output/01k"
os.chdir(origin)
matrix_input = 'testing_network.csv'
smallFile = False  # Set to True if the file is small enough to print a graph (less than 30 nodes)

# Declare Variables
df = pd.read_csv(matrix_input, index_col=0)
np_array = df.values

# Create defintions
def printGraph(np_array, g):
    print(np_array[:5, :5])
    print("Nodes:", g.nodes())
    print("Edges:", g.edges())

def create_network(np_array):
    graph = nx.from_numpy_array(np_array)
    mapping = dict(zip(range(len(df.index)), df.index))
    graph = nx.relabel_nodes(graph, mapping)
    #printGraph(np_array, graph)
    return graph

def nth_degree_network(np_array, n):
    # Compute shortest path distances
    G = nx.from_numpy_array(np_array)
    shortest_paths = dict(nx.all_pairs_shortest_path_length(G))
    
    # Create matrix where entry is 1 if shortest path = n
    result = np.zeros_like(np_array)
    for i in shortest_paths:
        for j in shortest_paths[i]:
            if shortest_paths[i][j] == n:
                result[i][j] = 1
    
    graph = create_network(result)
    return graph

def drawGraph(gml_file,name, title):
    G = nx.read_gml(gml_file)
    pos = nx.spring_layout(G, seed=42)
    plt.figure(figsize=(10, 8))
    nx.draw_networkx_nodes(G, pos, node_color='skyblue', node_size=500, alpha=0.8)
    nx.draw_networkx_edges(G, pos, edge_color='gray', alpha=0.5)
    nx.draw_networkx_labels(G, pos, font_size=12)
    plt.title(title)
    plt.axis('off')
    plt.savefig(name, format='png', dpi=300)

def export(matrix, filename, title):
    nx.write_gml(matrix, filename + '_graph.gml')
    nx.write_edgelist(matrix, filename + '_edgelist.csv', delimiter=',')
    if smallFile == True:
        drawGraph(filename + '_graph.gml', filename + '.png', title)

# Main Function
t1 = timer()
adj1 = create_network(np_array)
t2 = timer()
print(f"Time taken for first network: {t2 - t1:.4f} seconds")
adj2 = nth_degree_network(np_array, 2)
t3 = timer()
print(f"Time taken for second degree network: {t3 - t1:.4f} seconds")
adj3 = nth_degree_network(np_array, 3)
t4 = timer()
print(f"Time taken for all degree networks: {t4 - t1:.4f} seconds")

os.chdir(destination)
export(adj1, 'adj_matrix1', '1st Degree Network')
print(f"Exported 1st degree network to adj_matrix1")
export(adj2, 'adj_matrix2', '2nd Degree Network')
print(f"Exported 2nd degree network to adj_matrix2")
export(adj3, 'adj_matrix3', '3rd Degree Network')
print(f"Exported 3rd degree network to adj_matrix3")
t5 = timer()

print(f"Total time taken: {t5 - t1:.4f} seconds")
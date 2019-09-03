########## Data Preparation ##########
# Load necessary packages
library(igraph)
library(sfsmisc)

# Set directory and parse inputs
setwd("~/Dropbox/Internship/Network/data/")
routes = read.delim("routes.dat", sep=",", header=FALSE, stringsAsFactors=FALSE)
airports = read.delim("airports.dat", sep=",", header=FALSE, stringsAsFactors=FALSE)

# Drop unnecessary columns and reorder, rename columns
routes = subset(routes, select = c(V3, V5))
airports = subset(airports, select = c(V1, V2, V4, V5, V8, V7))
colnames(routes) = c("dep", "arr")
colnames(airports) = c("id", "name", "country", "iata_id", "longitude", "latitude")

# Drop rows without valid IATA code (private airports / air force base)
null_value = "\\N"
routes = routes[!(routes$dep %in% c(null_value)) & !(routes$arr %in% c(null_value)),]
airports = airports[!(airports$iata_id %in% c(null_value)),]

# Drop routes whose origin/destination airport does not appear in the airport data
global_airport_list = sort(unique(c(routes$dep, routes$arr)))
global_airports = airports[airports$iata_id %in% global_airport_list,]
global_airports = global_airports[order(global_airports$iata_id),]
m = length(global_airport_list)
global_airport_list = global_airports$iata_id
routes = routes[(routes$dep %in% global_airport_list)&(routes$arr %in% global_airport_list),]

########## Network Analysis ##########
# Extract data from the East Asian region
east_asian_airports = airports[airports$country %in% c("South Korea", "China", "Japan", "Taiwan", "Hong Kong", "Macau"),]
east_asian_routes = routes[(routes$dep %in% east_asian_airports$iata_id)&(routes$arr %in% east_asian_airports$iata_id),]
east_asian_airport_list = sort(unique(c(east_asian_routes$dep, east_asian_routes$arr)))
east_asian_airports = east_asian_airports[east_asian_airports$iata_id %in% east_asian_airport_list,]
east_asian_airports = east_asian_airports[order(east_asian_airports$iata_id),]
n = length(east_asian_airport_list)

# Create graph
east_asian_graph = graph.data.frame(east_asian_routes, vertices=east_asian_airport_list, directed = FALSE)
east_asian_graph = simplify(east_asian_graph, remove.multiple = TRUE, remove.loops = TRUE)
east_asian_layout = as.matrix(east_asian_airports[,5:6])
rownames(east_asian_layout) = east_asian_airports[,4]

# Plot graph
V(east_asian_graph)$size = 3
V(east_asian_graph)$color = "red"
V(east_asian_graph)$label = ""
E(east_asian_graph)$color = "gray80"
E(east_asian_graph)$width = 1 
plot(east_asian_graph, layout=east_asian_layout)

# Plot k-P(k) results
plot(x=0:max(degree(east_asian_graph)), 
     y=degree_distribution(east_asian_graph, cumulative=T),
     type="p",
     main="Degree to Cumulative Degree",
     xlab="k",
     ylab="P(k)",
     log="xy",
     xaxt="n",
     yaxt="n"
     )
eaxis(1, at=c(1, 10, 100))
eaxis(2, at=c(10^-2, 10^-1, 10^0))

# Plot k-knn results
plot(x=degree(east_asian_graph), 
     y=knn(east_asian_graph)[[1]],
     type="p",
     main="Degree to Average Neighbor Degree",
     xlab="k",
     ylab="knn"
     )
par(xpd=FALSE)
abline(lm(knn(east_asian_graph)[[1]] ~ degree(east_asian_graph)))

# Plot k-C results
plot(x=degree(east_asian_graph), 
     y=transitivity(east_asian_graph, type="local"),
     type="p",
     main="Degree to Clustering Coefficient",
     xlab="k",
     ylab="C"
)
par(xpd=FALSE)
abline(lm(transitivity(east_asian_graph, type="local") ~ degree(east_asian_graph)))

# Plot k-B results
plot(x=degree(east_asian_graph), 
     y=betweenness(east_asian_graph),
     type="p",
     main="Degree to Betweenness",
     xlab="k",
     ylab="B",
     log="xy",
     xaxt="n",
     yaxt="n"
)
eaxis(1, at=c(10^0, 10^1, 10^2))
eaxis(2, at=c(10^0, 10^1, 10^2, 10^3, 10^4))

########## Robustness Analysis ##########
# Calculate the betweenness of each airport and order the airports in decreasing order of betweenness
east_asian_betweenness = east_asian_airports[,4:6]
east_asian_betweenness$betweenness = betweenness(east_asian_graph)
east_asian_betweenness = east_asian_betweenness[order(east_asian_betweenness$betweenness, decreasing=TRUE),]

# Copy the graph into a new graph
east_asian_graph2 = east_asian_graph
east_asian_layout2 = east_asian_layout

# Repeatedly remove the airport with the next highest betweenness
n_remove = floor(0.3 * n)
east_asian_max_cluster_size_list = integer(n_remove)
for (i in 1:n_remove) {
  attacked_vertex = which(V(east_asian_graph2)$name==east_asian_betweenness[i,1]) # find the next airport to be removed
  east_asian_graph2 = delete.vertices(east_asian_graph2, v=attacked_vertex) # remove the airport from the graph
  max_cluster_size = max(clusters(east_asian_graph2)$csize) # calculate the size of the largest component
  east_asian_max_cluster_size_list[i] = max_cluster_size # store the result
  east_asian_layout2 = east_asian_layout2[rownames(east_asian_layout2)!=east_asian_betweenness[i,1],] # remove the airport from the layout
  # plot(east_asian_graph2, layout=east_asian_layout2)
}

# Plot the result
plot(x=(1:n_remove)/n,
     y=east_asian_max_cluster_size_list/n,
     type="l",
     main="Largest Component Size under Node Attacks",
     xlab="Fraction of nodes removed",
     ylab="Relative size of the largest component"
)

########## Comparison with the Global ATN ##########
# Create global graph
global_graph = graph.data.frame(routes, vertices=global_airport_list, directed = FALSE)
global_graph = simplify(global_graph, remove.multiple = TRUE, remove.loops = TRUE)
global_layout = as.matrix(global_airports[,5:6])
rownames(global_layout) = global_airports[,4]

# Calculate the betweenness of each airport and order the airports in decreasing order of betweenness
global_betweenness = global_airports[,4:6]
global_betweenness$betweenness = betweenness(global_graph)
global_betweenness = global_betweenness[order(global_betweenness$betweenness, decreasing=TRUE),]

# Copy the graph into a new graph
global_graph2 = global_graph
global_layout2 = global_layout

# Repeatedly remove the airport with the next highest betweenness
m_remove = floor(0.3 * m)
global_max_cluster_size_list = integer(m_remove)
for (i in 1:m_remove) {
  attacked_vertex = which(V(global_graph2)$name==global_betweenness[i,1]) # find the next airport to be removed
  global_graph2 = delete.vertices(global_graph2, v=attacked_vertex) # remove the airport from the graph
  max_cluster_size = max(clusters(global_graph2)$csize) # calculate the size of the largest component
  global_max_cluster_size_list[i] = max_cluster_size # store the result
  global_layout2 = global_layout2[rownames(global_layout2)!=global_betweenness[i,1],] # remove the airport from the layout
  # plot(global_graph2, layout=global_layout2)
}

# Plot the result
lines(x=(1:m_remove)/m, y=global_max_cluster_size_list/m, col="blue")

########## East Asian airports in the Global ATN ##########
# Order the East Asian airports in decreasing order of betweenness in the global network
east_asian_betweenness2 = global_betweenness[global_betweenness$iata_id %in% east_asian_airport_list,]
comparison = data.frame(east_asian_betweenness$iata_id, east_asian_betweenness2$iata_id)
colnames(comparison) = c("Subnetwork", "Global Network")
comparison$difference = match(east_asian_betweenness2$iata_id, east_asian_betweenness$iata_id) - 1:n
View(comparison)

# Copy the graph into a new graph
east_asian_graph2 = east_asian_graph
east_asian_layout2 = east_asian_layout

# Repeatedly remove the airport with the next highest betweenness
n_remove = floor(0.3 * n)
east_asian_max_cluster_size_list = integer(n_remove)
for (i in 1:n_remove) {
  attacked_vertex = which(V(east_asian_graph2)$name==east_asian_betweenness2[i,1]) # find the next airport to be removed
  east_asian_graph2 = delete.vertices(east_asian_graph2, v=attacked_vertex) # remove the airport from the graph
  max_cluster_size = max(clusters(east_asian_graph2)$csize) # calculate the size of the largest component
  east_asian_max_cluster_size_list[i] = max_cluster_size # store the result
  east_asian_layout2 = east_asian_layout2[rownames(east_asian_layout2)!=east_asian_betweenness2[i,1],] # remove the airport from the layout
  # plot(east_asian_graph2, layout=east_asian_layout2)
}

# Plot the result
lines(x=(1:n_remove)/n, y=east_asian_max_cluster_size_list/n, col="red")


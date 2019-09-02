# Load packages
library(igraph)
library(sfsmisc)
#library(OpenStreetMap)

# Parse inputs
setwd("~/Dropbox/Internship/Network/data/")
routes = read.delim("routes.dat", sep=",", header=FALSE, stringsAsFactors=FALSE)
airports = read.delim("airports.dat", sep=",", header=FALSE, stringsAsFactors=FALSE)

# Drop unnecessary columns and reorder columns
routes = subset(routes, select = c(V3, V5))
airports = subset(airports, select = c(V1, V2, V4, V5, V8, V7))

# Rename dataframe columns
colnames(routes) = c("dep", "arr")
colnames(airports) = c("id", "name", "country", "iata_id", "latitude", "longitude")

# Drop rows without valid IATA code
null_value = "\\N"
routes = routes[!(routes$dep %in% c(null_value)) & !(routes$arr %in% c(null_value)),]
airports = airports[!(airports$iata_id %in% c(null_value)),]

# Extract data from the East Asian region
east_asian_airports = airports[airports$country %in% c("South Korea", "China", "Japan", "Taiwan", "Hong Kong", "Macau"),]
east_asian_routes = routes[(routes$dep %in% east_asian_airports$iata_id)&(routes$arr %in% east_asian_airports$iata_id),]
east_asian_airport_list = sort(unique(c(east_asian_routes$dep, east_asian_routes$arr)))
east_asian_airports = east_asian_airports[east_asian_airports$iata_id %in% east_asian_airport_list,]
east_asian_airports = east_asian_airports[order(east_asian_airports$iata_id),]
n = length(east_asian_airport_list)

# Create graph
g = graph.data.frame(east_asian_routes, vertices=east_asian_airport_list, directed = FALSE)
g = simplify(g, remove.multiple = TRUE, remove.loops = TRUE)
lo = as.matrix(east_asian_airports[,5:6])
rownames(lo) = east_asian_airports[,4]

# Plot map
#east_asian_map = openmap(c(55, 58), c(15, 155), type="osm")
#plot(east_asian_map)
#library(raster)
#greece <- getData('GADM', country='GRC', level=1)
#plot(greece)

# Plot graph
V(g)$size = 3
V(g)$color = "red"
V(g)$label = ""
E(g)$color = "gray80"
E(g)$width = 1 
plot(g, layout=lo)
#plot(g, layout=lo, add=TRUE, rescale=FALSE)

# plot(delete.vertices(g, V(g)[degree(g) < 60]), layout=lo)


# Plot k-P(k) results
plot(x=0:max(degree(g)), 
     y=degree_distribution(g, cumulative=T),
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
plot(x=degree(g), 
     y=knn(g)[[1]],
     type="p",
     main="Degree to Average Neighbor Degree",
     xlab="k",
     ylab="knn"
     )
par(xpd=FALSE)
abline(lm(knn(g)[[1]] ~ degree(g)))

# Plot k-C results
plot(x=degree(g), 
     y=transitivity(g, type="local"),
     type="p",
     main="Degree to Clustering Coefficient",
     xlab="k",
     ylab="C"
)
par(xpd=FALSE)
abline(lm(transitivity(g, type="local") ~ degree(g)))

# Plot k-B results
plot(x=degree(g), 
     y=betweenness(g),
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
#par(xpd=FALSE)
#abline(lm(log(betweenness(g)) ~ log(degree(g))))

# Robustness analysis
betweenness_table = east_asian_airports[,4:6]
betweenness_table$betweenness = betweenness(g)
betweenness_table = betweenness_table[order(betweenness_table$betweenness, decreasing=TRUE),]

g2 = g
lo2 = lo
max_cluster_size_list = integer(100)
for (i in 1:100) {
  attacked_vertex = which(V(g2)$name==betweenness_table[i,1])
  g2 = delete.vertices(g2, v=attacked_vertex)
  max_cluster_size = max(clusters(g2)$csize)
  max_cluster_size_list[i] = max_cluster_size
  lo2 = lo2[rownames(lo2) != betweenness_table[i,1], ]
  # plot(g2, layout=lo2)
}

plot(x=(1:100)/n,
     y=max_cluster_size_list/n,
     main="Largest Component Size under Node Attacks",
     xlab="Fraction of nodes removed",
     ylab="Relative size of the largest component"
)

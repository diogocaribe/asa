# Load libraries
library('raster')
library('rgdal')

# Load a SpatialPolygonsDataFrame example
# Load Brazil administrative level 2 shapefile
mcv <- readOGR("vector/mi_25_cerrado.shp")

# Convert NAMES level 2 to factor 
mcv$codigo <- as.factor(mcv$codigo)

# Plot BRA_adm2
plot(mcv)
box()

# Define RasterLayer object
r.raster <- raster()

# Define raster extent
extent(r.raster) <- extent(mcv)

# Define pixel size
res(r.raster) <- 5

# Multithread -------------------------------------------------------------

# Load 'parallel' package for support Parallel computation in R
library('parallel')

# Calculate the number of cores
no_cores <- detectCores() - 2

# Number of polygons features in SPDF
features <- 1:nrow(mcv[,])

# Split features in n parts
n <- 100
parts <- split(features, cut(features, n))

# Initiate cluster (after loading all the necessary object to R environment: BRA_adm2, parts, r.raster, n)
cl <- makeCluster(no_cores, type = "FORK")
print(cl)

# Parallelize rasterize function
system.time(rParts <- parLapply(cl = cl, X = 1:n, fun = function(x) rasterize(mcv[parts[[x]],], r.raster, 'codigo')))

# Finish
stopCluster(cl)

# Merge all raster parts
rMerge <- do.call(merge, rParts)

# Plot raster
plot(rMerge)
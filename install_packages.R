packageList <- readLines("R_packages.txt")

for(package in packageList) {
	install.packages(package, repos='http://cran.rstudio.com/')
}

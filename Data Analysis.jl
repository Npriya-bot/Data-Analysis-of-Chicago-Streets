
# Setup:
# Install package for reading in csv and forming the dataframes
using Pkg
using CSV
using DataFrames

# Load in data from files
# Link to files found in the README
buildings = CSV.read(FILEPATH)
lights = CSV.read(FILEPATH)

#Storing the dataframe of the name of the streets of the abandoned buildings in column l and unit value stored in the
#respective c column which will be used to add the occurences of the streets
df_buildings = DataFrame(l = buildings[:13], c = 1)

#grouping the common street names into groups while skipping the the rows if the cell of the street is missing/empty
gd = groupby(df_buildings, :1, skipmissing = true);

#sums up all the common entries of the streets and places the values in the respective column c_sum
streets_buildings = combine(gd, :c => sum)

#sorts the streets name based on the frequency of their occurences in the descending order
most_streets = sort(streets_buildings, :c_sum, rev=true)

#storing the dataframe of the address of the places where the street lights are not working
df_lights = DataFrame(l = lights[:6])

#storing the address column from the lights.csv which will be used to split the address and just store the street name
s = lights[:6];

#forming a multi-dimensional array of the words in the address after splitting it and removing the cells which contain
#missing values
arr = map(x -> ismissing(x) ? x : split(x, ' '), s);

#storing the street name in a separate array
street_lights = map(x -> ismissing(x) ? x : x = x[3], arr);

#forming the dataframe of the streeet name with a unit value assigned to the respective column
df_lights = DataFrame(l = street_lights, c = 1)

#grouping the common names of the streets and skipping the missing vakue cells
gd_lights = groupby(df_lights, :1, skipmissing = true);

#storing the sum of common occurences of the street names
streets_lights = combine(gd_lights, :c => sum)

#sorts the name of the streets based on their occurence in the descending order
sorted = sort(streets_lights, :c_sum, rev=true)

using Plots

using StatsPlots

#storing the dataframe of the sorted street names for the vacant buildings
df_buildings_sorted = DataFrame(streets = most_streets[:l], freq_buildings = most_streets[:c_sum])

#storing the dataframe of the sorted street name where the street lights are not working with the same name of the 
#column of the street name as that of the building variable but with a differnt frequecy variable
df_lights_sorted = DataFrame(streets = sorted[:l], freq_lights = sorted[:c_sum])

#finds the intersection between the two dataframes based on the street names and displays the respective frequencies
#for the buildings and lights
total = join(df_buildings_sorted, df_lights_sorted, kind=:inner, on=[:streets])

#stores and calculates the total occurences 
total[:total_freq] =(total[:freq_buildings] + total[:freq_lights]);

#displays the table formed
total

#displays the scatter plot for the comparison of the frequencies of the abandoned buildings and light outage
@df total scatter(:freq_buildings, :freq_lights, xaxis = (0:100:800), yaxis = (0:1000:3600), title = ("Abandoned Buildings vs Light Outage"))
xlabel!("Frequency of Abandoned Buildings")
ylabel!("Frequency of Light Outage")

@df total scatter(:streets, :total_freq, yaxis = (0:1000:4000), title = ("Total Frequency of Issues on Chicago Streets"))
xlabel!("Streets")
ylabel!("Total Frequency")

#Selects the top 6 street names having high number of abandoned buildings
head(df_buildings_sorted)

#Selects the top 6 street names having high number of light outages
head(df_lights_sorted)

#Selects the top 6 street names having total number of conditions together
head(total)

#Displays the graph of the top six street names having the high probability of crime occuring
@df head(total) bar(:streets, :total_freq, yaxis = (0:100:2200), xlabel = "Streets")

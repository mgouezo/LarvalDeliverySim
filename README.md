# LarvalDeliverySim
The code select particles that are always moving within a define area throughout the entire dispersal phase for each dispersal simulation. Include batch processing. 

The code:
1. converts a dispersal output (.json file) into a dataframe
2. for each particleID, it calculate distance in decimal degrees between consecutive time points for each particle
3. approximately converts decimal degrees into meters
4. create a new variable with 2 categories, stationary if the same particles through time does not more over 50 m amd moving for the opposite
5. the loop runs for all the .json file in a chosen folder
6. the output is a .csv file per dispersal simulation showing the all the particles within that are moving or becoming staitonary within the defined areas 

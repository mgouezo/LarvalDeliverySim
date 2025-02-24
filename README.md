# LarvalDeliverySim

Codes from: Gouezo et al. 2025. Going with the flow: leveraging reef-scale hydrodynamics for upscaling larval-based restoration. Ecological Applications. 

The code selects particles that are always moving within a defined area throughout the entire dispersal phase for each dispersal simulation. Include batch processing.

The code:
1. converts a dispersal output (.json file) into a dataframe
2. for each particleID, it calculates the distance in decimal degrees between consecutive time points for each particle
approximately converts decimal degrees into meters
3. creates a new variable with 2 categories, 'stationary' if the same particles through time do not move less or equal than 50 m and 'moving' for the opposite
4. the loop runs for all the .json files in a chosen folder
5. the output is a .csv file per dispersal simulation showing all the particles at each time step and categorize them as moving or stationary within the defined areas

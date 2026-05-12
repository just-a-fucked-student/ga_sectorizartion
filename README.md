# Sectorisation Voronoi

Code for MGTA Sectorisation project.

## Overview
SectorisationVoronoi is a MATLAB-based toolkit designed for optimizing airspace sectorization using Voronoi diagrams and user-defined workload sectoring cost functions. 
It utilizes various algorithms to calculate and minimize complexity in airspace management, such as aircraft distribution, airway intersections, and sector area. 
The toolkit is structured to allow easy modifications to the cost functions and includes visualization capabilities for analyzing optimization outcomes.

## Repository Structure
- /data/: Contains all necessary data files including airspace and traffic data.
- /functions/: Contains all MATLAB functions required for loading airspace data, generating Voronoi diagrams, calculating intersections, and other utility functions.
- /objectives/: Contains objective functions that define different workload sectoring costs.
- main.m: The main script that orchestrates data loading, optimization configuration, running the optimization, and plotting the results.

## Running the Optimization
- Open the main.m script in MATLAB.
- Run the script by pressing the Run button or typing main in the Command Window.
- The script will load necessary data from the /data/ folder, configure the optimization parameters, and start the optimization process.
- Upon completion, the results and various plots will be displayed to visualize the optimized airspace sectorization.

## Customization
- Modifying Cost Functions: Navigate to the /objectives/ folder and adjust the existing functions or add new ones to change how the airspace sectoring costs are calculated.
- Data Management: Add or modify the data files in the /data/ folder to use different airspace and traffic scenarios.

## License
Distributed under the MIT License.

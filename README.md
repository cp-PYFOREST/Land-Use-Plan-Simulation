<h1 align="center">

PYFOREST

</h1>

<h2 align="center">

Informing Forest Conservation Regulations in Paraguay

</h2>

<h2 align="center">

![Banner](https://github.com/cp-PYFOREST/Land-Use-Plan-Simulation/blob/b31f243a025d718321b7ec219f0e091dc9856a81/img/logo.png)

</h2>

# Land-Use-Plan-Simulation


<h2 align="center">

[Land-Use-Assesment](https://github.com/cp-PYFOREST/Land-Use-Assessment) | [Land-Use-Plan-Simulation](https://github.com/cp-PYFOREST/Land-Use-Plan-Simulation) | [PYFOREST-ML](https://github.com/cp-PYFOREST/PYFOREST-ML) | [PYFOREST-Shiny](https://github.com/cp-PYFOREST/PYFOREST-Shiny)

</h2>

## Description

To quantify the designated forest reserve in the undeveloped Chaco under current and alternate laws, we have developed a simulation that divides the region into mock properties. We apply a set of custom functions for each mock property that generates LUP configurations based on the specified legal requirements. By simulating various scenarios with different conservation requirements, we can estimate the potential impact of policy changes on forest conservation in the Paraguayan Chaco.

### Usage

Creating the undeveloped region of the Paraguayan Chaco:
•	The datasets in Table 2, in conjunction with the study boundary, were used to define the areas considered developed or protected from further development.
•	The developed region took the difference with the study boundary to create the undeveloped region. 
Creating the mock properties in the undeveloped region:
•	The custom function propety_dimensions was used to determine the dimensions to pass to the cellsize parameter of the R library sf function st_make_grid to make properties of 40000000 meters squared. The value for the property size was chosen based on some bank reason.
•	Only properties above 200000 meters squared were selected as this is the minimum required to register land use plans. 
Creating simulated land use plans for each mock property:
•	Each property goes through a series of custom functions to create a simulation of land use plans. Each land use plan has three main categories of forest reserve, paddocks, and hedgerows. If a river crosses the property, an additional category of riparian corridor is added. The functions are flexible enough to create different-size properties and paddocks with customizable aspect ratios. Flexibility is extended to the width of the hedgerows and riparian corridors.
o	Functions are sourced from lup_simulator.qmd file.
o	The first three simulations ran varied in the amount of forest reserve requirement, 5%, 25%, and 50%. A new create_optimal_dimensions.qmd file was created for each simulation where after the first pass of each property through the functions, the dataset was filtered repeatedly and reran, lowering the paddock size each time to ensure that every property was below a three percent margin of error but above the minimum requirement. The repeated process could have been incorporated into the parallel process, but the process was done manually to remain consistent and maintain a quality check. This process returns the optimal dimensions to reach the minimum forest reserve and provides the area statistics for each category type within a property. 
o	Once the optimal dimension was determined for each property, the create_maps_with_optimal_dimensions.qmd was created for each simulation. This follows the same process as the previous pass and returns a dataset of the polygons of the category types created with the optimal dimensions for visualizations. 
o	The final simulation of allowing the hedgerows between paddocks to be counted towards the 25% minimum required reorganizing the lup_simulator.qmd file and the order of functions called. Changes are reflected in the following:
	lup_simulator_hedges.qmd, 
	create_optimal_dimensions_hedges.qmd, and 
	create_maps_with_optimal_dimensions_hedges.qmd.

Table 2: Data Information

| Dataset | Year(s) | Source | Data Type | Spatial Reference/Resolution | Metadata |
|---------|----------|----------|---------|----------|----------|
| C. Permitted land use  |	1994-2022	INFONA |	Polygons |	CRS: WGS 84 / UTM zone 21S | Metadata |
| D. Wildlife Protection Areas |	2022 |	Ministry of the Environment and Sustainable Development |	Polygons | 	CRS: WGS 84 / UTM zone 21S | 	Metadata |
| E. Indigenous Land |	2022 |	Federation for the Self-determination of Indigenous Peoples |	Polygons |	CRS: WGS 84 / UTM zone 21S |	Metadata |
| F. Forest Biome |	2022 |	INFONA |	Polygons |	CRS: WGS 84 / UTM zone 21S |	Metadata |
| H. Hydrography and paths |	2022 |	National Cadastre Service |	Polygons |	CRS: WGS 84 / UTM zone 21S | Metadata |





## Contributors
[Atahualpa Ayala](Atahualpa-Ayala), [Dalila Lara](https://github.com/dalilalara), [Alexandria Reed](https://github.com/reedalexandria)

Any advise for common problems or issues.

## License

This project is licensed under the Apache-2.0 License - see the LICENSE.md file for details

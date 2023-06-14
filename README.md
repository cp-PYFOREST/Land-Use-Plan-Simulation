<h1 align="center">

PYFOREST

</h1>

<h2 align="center">

Informing Forest Conservation Regulations in Paraguay

</h2>

<h2 align="center">

<img src="https://github.com/cp-PYFOREST/Land-Use-Plan-Simulation/blob/main/img/pyforest_hex_sticker.png" alt="Banner" width="200">

</h2>

# Land-Use-Plan-Simulation


<h2 align="center">

[Land-Use-Assesment](https://github.com/cp-PYFOREST/Land-Use-Assessment) | [Land-Use-Plan-Simulation](https://github.com/cp-PYFOREST/Land-Use-Plan-Simulation) | [PYFOREST-ML](https://github.com/cp-PYFOREST/PYFOREST-ML) | [PYFOREST-Shiny](https://github.com/cp-PYFOREST/PYFOREST-Shiny)

</h2>

# Documentation
 For more detailed information about our project, including our methodologies, data sources, and technical specifications, please refer to our [technical documentation](https://bren.ucsb.edu/projects/informing-forest-conservation-regulations-paraguay).
  
 ## Table of Contents
- [Description](#description)
- [Defining the undeveloped region of the Paraguayan Chaco](#defining-the-undeveloped-region-of-the-paraguayan-chaco)
- [Creating the mock properties in the undeveloped region](#creating-the-mock-properties-in-the-undeveloped-region)
- [Creating simulated land use plans for each mock property](#creating-simulated-land-use-plans-for-each-mock-property)
- [Results](#results)
- [Data Information](#data-information)
- [License](#license)
- [Contact](#contact)
- 
## Description

**Estimating Forest Reserve in Undeveloped Regions**

To quantify the area of forest that would be designated for protection under current and alternative laws, we have developed a simulation model that divides the undeveloped Paraguayan Chaco into mock properties. We apply custom functions for each mock property that generate LUP configurations based on the specified legal requirements. By simulating various scenarios with different conservation requirements, we can estimate the potential impact of policy changes on forest conservation in the Paraguayan Chaco.

- _Current Forest Law_
This scenario follows the current policy and legal requirements for LUPs enforced by INFONA. It includes a 25% forest reserve, a 100-meter hedgerow buffer, a 100-meter riparian forest, and paddocks of less than 100 ha for authorized deforestation. The purpose of this scenario is to simulate the continuation of existing practices and policies without any significant changes (Paraguay, 1986; Paraguay, 1995).

### **Alternative Forest Laws**

- _Promotes Forest Conservation_
This scenario aims to enhance forest conservation efforts. It proposes increasing the forest reserve requirement to 50%, along with maintaining a 100-meter hedgerow buffer, a 100-meter riparian forest, and paddocks of less than 100 ha. The objective is to simulate the potential outcomes of a policy that was proposed in Paraguay’s National Congress in 2017 that would prioritize the preservation and protection of forests (National Congress, 2017).

- _Prioritize Cattle Production_
This scenario aims to find a balance between cattle production and forest conservation. It proposes a 25% total forest cover, which includes the combined area of the 100-meter riparian forest and 100-meter hedgerow buffer. Any additional forest area required to reach the 25% target would be designated as forest reserve. This policy includes paddocks of less than 100 ha. The intention is to simulate potential effects of a policy goal that prioritizes land use for economic purposes, while maintaining a 25% forest cover goal.

- _Law Ambiguity_
This scenario addresses a potential ambiguity in the law's interpretation. It suggests that if a property has been deforested beyond the approved amount, an immediate reforestation of 5% of the property is required in the areas of forest reserve. This is in addition to maintaining the 100-meter hedgerow buffer, the 100-meter riparian forest, and paddocks of less than 100 ha. However, some property owners have interpreted this policy as allowing them to deforest their entire property and only needing to replant 5%. This misinterpretation could lead to substantial deforestation, undermining the current forest law’s original intent (National Congress, 2009).

These scenarios were selected to evaluate and compare the potential outcomes of different policy approaches concerning land use planning and forest conservation. Simulating a range of scenarios makes it possible to assess the trade-offs, benefits, and impacts associated with each policy option. The chosen scenarios represent distinct policy directions that Paraguay has considered adopting. 

## Defining the undeveloped region of the Paraguayan Chaco

Within the study boundary, two distinct regions are defined:

1. **The developed region** takes into account urban areas (including roadways), indigenous lands, national parks, and all private cattle ranches registered with INFONA. To develop a ranch, the
landowners require deforesting part of the property to plant grass for cattle. Deforestation occurring within the property requires submission of a LUP for approval by INFONA.

2. **The undeveloped region**, which accounts for approximately 40% of the Paraguayan Chaco, is defined as the study area excluding the developed region.

The undeveloped region is composed of properties that are likely to become cattle ranches in the future. This area lacks property boundaries and associated LUPs, motivating our creation of mock properties and simulated LUPs, under current and alternative forest laws, in the undeveloped region. 

<h2 align="center">

<img src="https://github.com/cp-PYFOREST/.github/blob/main/img/undeveloped-region.png" alt="Undeveloped Region">

</h2>

## Creating the mock properties in the undeveloped region

The custom function propety_dimensions was used to determine the dimensions to pass to the cellsize parameter of the R library sf function st_make_grid to make properties of 4,000 ha. The value for the property size was based on the average size of the land plots that the national government sold through the National Institute of Rural Development and Land (INDERT) for livestock farming establishments in the western region  (Rojas Villagra & Areco, 2017).

Only properties above 20 ha were selected, as this is the minimum required to register LUPs (Instituto Forestal Nacional, 2001).

<h2 align="center">

<img src="https://github.com/cp-PYFOREST/.github/blob/main/img/obj2-mock-properties.png" alt="Mock Properties">

</h2>

## Creating simulated land use plans for each mock property

Each property iterates through a series of custom functions to create a simulation of LUPs. Each LUP has three main categories: forest reserve, paddocks, and hedgerows. If a river crosses the property, an additional category of riparian corridor is added. The functions are flexible enough to create different-size properties and paddocks with customizable aspect ratios. In addition, flexibility is extended to the width of the hedgerows and riparian corridors. 

- A new create_optimal_dimensions.qmd file was created for each simulation where, after the first pass of each property through the functions, the dataset was filtered repeatedly and reran, lowering the paddock size each time. For each simulation a minimum requirement is set for the category of forest reserve (i.e. 25%, 50%, 5%), the iterative process of lowering the paddock size ensures that each property has less than a three percent margin of error (e.g. <28%, <53%, <8%) but above the minimum forest reserve requirement. The repeated process could have been incorporated into the parallel process, but the process was done manually to remain consistent and maintain a quality check. This process returns the optimal dimensions to reach the minimum forest reserve and provides the area statistics for each category type within a property. 

- Once the optimal dimension was determined for each property, the create_maps_with_optimal_dimensions.qmd was created for each simulation. This follows the same process as the previous pass and returns a dataset of the polygons of the category types created with the optimal dimensions for visualizations. 

- The prioritize cattle production scenario, allowing the hedgerows between paddocks to be counted towards the 25% minimum, required reorganizing the lup_simulator.qmd file and the order of functions called. Changes are reflected in the following: lup_simulator_hedges.qmd, create_optimal_dimensions_hedges.qmd, and create_maps_with_optimal_dimensions_hedges.qmd.

## Results
- The decision was made to use the areas calculated from the rasters created in objective 3 as they are derived from the simulations created in Objective 2. The detailed reasoning for this decision can be found in Appendix A. 

### Estimates
**Land Use Plan Simulation Estimates for Forest Conserved**

| Policy Scenario/ Simulation | Forest Conserved | Area Authorized For Deforestation |
|---------|----------|----------|
| Current Forest Law  | 3,702,454	| 5,497,236 | 
| Promotes Forest Conservation |	5,589,018 |	3,611,169 |	
| Prioritize Cattle Production |	2,401,457 |	6,798,97 |	
| Law Ambiguity |	2,233,436 |	6,965,255 |	

- The scenario that prioritizes cattle production decreases forest conserved by approximately 1.30 million hectares.

- When comparing the current law to the one that promotes forest conservation, we see an increase of approximately 1.89 million hectares of forest cover. 

- When comparing the current law to the law ambiguity scenario, we estimate a decrease of approximately 1.47 million hectares of forest cover. 

- When compared side by side, you can see that the estimated range of forest conserved is 2.2 to 5.6 million hectares. This is a potential difference of approximately 3.4 million hectares.  Though the difference of forest conserved between the Law Ambiguity and Prioritizing Cattle Production simulations appears to be minimal, it equates to approximately  a 7% difference amounting to ~168,021 hectares which is more than twice the size of New York City (77816.19 hectares) (U.S. Census Bureau, 2022). 

- This suggests that the Law Ambiguity could have a more detrimental impact on forest conservation than prioritizing cattle production, assuming all other factors are equal. However, it's important to note that these are simplified calculations and the actual impact would depend on a variety of factors, including the specific laws and regulations in place, enforcement of those laws, and the practices of the cattle industry.

Table 2: Data Information

| Dataset | Year(s) | Source | Data Type | Spatial Reference/Resolution | Metadata |
|---------|----------|----------|---------|----------|----------|
| C. Permitted land use  |	1994-2022	| INFONA | Polygons |	CRS: WGS 84 / UTM zone 21S | Metadata |
| D. Wildlife Protection Areas |	2022 |	Ministry of the Environment and Sustainable Development |	Polygons | 	CRS: WGS 84 / UTM zone 21S | 	Metadata |
| E. Indigenous Land |	2022 |	Federation for the Self-determination of Indigenous Peoples |	Polygons |	CRS: WGS 84 / UTM zone 21S |	Metadata |
| F. Forest Biome |	2022 |	INFONA |	Polygons |	CRS: WGS 84 / UTM zone 21S |	Metadata |
| H. Hydrography and paths |	2022 |	National Cadastre Service |	Polygons |	CRS: WGS 84 / UTM zone 21S | Metadata |


<h2 align="center">

<img src="https://github.com/cp-PYFOREST/.github/blob/main/img/obj2-result.png" alt="SIM Results">

</h2>


## Contributors
[Atahualpa Ayala](Atahualpa-Ayala),  [Dalila Lara](https://github.com/dalilalara),  [Alexandria Reed](https://github.com/reedalexandria),  [Guillermo Romero](https://github.com/romero61)
Any advise for common problems or issues.

## License

This project is licensed under the Apache-2.0 License - see the LICENSE.md file for details

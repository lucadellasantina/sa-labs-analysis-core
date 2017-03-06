# Electrophysiology Data Analysis (In development)

It uses [ToolboxToolbox](https://github.com/ToolboxHub/ToolboxToolbox) for dependency management

### Installation

1. Download and install ToolboxToolbox from above link
2. Download the [startup.m](https://gist.github.com/ragavsathish/e4e58150c8a6c8ffe95b0ef632715fbe) and save it in MATLAB user path.
3. clone `git clone https://github.com/Schwartz-AlaLaurila-Labs/sa-labs-analysis-core.git` into `<userpath>\projects\sa-labs-analysis-core` folder 
4. To update `tbUseProject('data-acquisition')`

### Folder organization

1. It follows maven style source code organization
2. All the dependency will be present in toolbox folder

### Usage

TODO

## Requirements

- Matlab 2016a+
- [ToolboxHub](https://github.com/ToolboxHub/ToolboxToolbox) for dependency management

### Matlab dependencies
	
	 sa-labs-analysis-core
	 	|
		|____ app-toolboxes
				|____ mdepin (Matlab dependency injection framework) 
				|____ appbox (Model view presenter based user interface)
				|____ Java Table Wrapper
				|____ Property Grid	 
				|____ Matlab tree data structure  
				|____ Jsonlab 
				|____ Logging for Matlab		
				|____ Matlab Query (LINQ style query processor)		 
		
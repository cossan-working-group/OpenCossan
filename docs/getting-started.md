OpenCossan is open source and publicly available from **Github** at

``` bash
https://github.com/cossan-working-group/OpenCossan
```

## System Requirements

Matlab <span style="color: green">R2018b</span> is required to use the full functionality of OpenCossan. Additionally, the following Matlab toolboxes are required:

- Optimization Toolbox
- Statistics and Machine Learning Toolbox
- Global Optimization Toolbox
- Bioinformatics Toolbox (for Bayesian Network Analysis)

The software can be downloaded as a ZIP-file directly from Github by clicking on *Download or clone > Download ZIP*.

Currently OpenCossan has two major version we call **stable** and **development**. Generally we recommend using the **stable** version since it is (as the name suggests) much more stable and reliable than the **development** version. However, new algorithms are only implemented in the **development** version. 

If you plan on using both versions of OpenCossan, it is recommended to download using **Git** as seen below for easy switching between the two versions.

## Installation

### Using git
To download OpenCossan using the version control software **Git** you need to have it installed. It comes preinstalled on most systems, but if it is not available you can download it from [https://git-scm.com/](https://git-scm.com/).

On Github, the **stable** and **development** version are located in the *master* and *development* branches respectively.

To download the software using **Git** run the following command in a terminal:
``` bash
git clone https://github.com/cossan-working-group/OpenCossan
```

this will by default download the **stable**/*master* version of OpenCossan.

To switch to the **development** version run
``` bash
git switch development
```
and 
``` bash
git switch master
```
to switch back to the **stable** version.

!!! tip "Baysian Network Analysis"
    If you plan on using the *Bayesian Network Analysis* available in the **development** version you are required to download an additional submodule after switching to the **development** version.

    ``` bash
    git submodule update --init
    ```


### From Matlab File Exchange

OpenCossan is available via Matlab file exchange (as a Matlab toolbox) at [https://de.mathworks.com/matlabcentral/fileexchange/72108-opencossan](https://de.mathworks.com/matlabcentral/fileexchange/72108-opencossan) and can be download through Matlab's Add-ons interface.

To download click on *Home > Add-ons > Get Add-ons*, search for *OpenCossan* and click on *Add from Github*.

!!! warning "File Exchange"
    While this is a fast and easy way of getting the software, it only gives you access to the **stable** version not the **development** version.

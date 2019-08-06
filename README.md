# OpenCossan

[![Build Status](https://jenkins.cossan.co.uk/buildStatus/icon?job=OpenCossan%2Fdevelopment)](https://jenkins.cossan.co.uk/job/OpenCossan/job/development/)
[![codecov](https://codecov.io/gh/cossan-working-group/OpenCossan/branch/development/graph/badge.svg)](https://codecov.io/gh/cossan-working-group/OpenCossan)

OpenCossan is a Matlab-based toolbox for uncertainty quantification and management. The implemented framework includes third-party software integration (e.g. ANSYS), efficient numeric algorithms (e.g. Line Sampling) and parallelization for high performance computing. OpenCossan functionalities can be summarized in:

* Uncertainty Quantification
* Simulation-based Reliability Analysis
* Sensitivity Analysis
* Meta-Modelling
* Stochastic Finite Elements Analysis
* Reliability-Based Optimization

OpenCossan is being jointly developed at the Institute for Risk and Uncertainty, University of Liverpool, UK and the Institute for Risk and Reliability, Leibniz University Hannover, Germany.

https://cossan.co.uk

## Getting started

To clone it to your local machine type in the terminal:

```bash
git clone https://github.com/cossan-working-group/OpenCossan.git
```

## Usage

Comprehensive documentation is available in the wiki available at https://cossan.co.uk/wiki.

### Case studies 

- [Reliability-based optimization of non linear viscous dampers](https://cossan.co.uk/casestudy/COSSAN_ViscousDampersCaseStudy.pdf)
- [Analysis of the Grenfell Tower Fire with Bayesian Networks](https://cossan.co.uk/casestudy/COSSAN_FireCaseStudy.pdf)
- [Baysian Optimisation](https://cossan.co.uk/wiki/index.php/Bayesian_optimisation)

## Support

If you encounter any problem working with OpenCossan please do not hesitate to create an issue.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## External dependencies

The following packages are used by OpenCossan and are required for some functionalities:

1. Statistical and Machine learning toolbox
2. Optimization toolbox

## How to cite

If you use this software, please read and cite these open-access articles:

1. Patelli, E., 2017. COSSAN: a multidisciplinary software suite for uncertainty quantification and risk management. Handbook of uncertainty quantification, pp.1909-1977. DOI: https://dx.doi.org/10.1007/978-3-319-11259-6_59-1

## Publications

The following publications have used OpenCossan:

1. Edoardo Patelli and Diego A. Alvarez and Matteo Broggi and Marco de Angelis 2015 Uncertainty management in multidisciplinary design of critical safety systems Journal of Aerospace Information Systems, 12, 140-169 https://doi.org/10.2514/1.I010273
2. Silvia Tolo and Edoardo Patelli and Michael Beer 2018 An open toolbox for the reduction, inference computation and sensitivity analysis of Credal Networks, Advances in Engineering Software, 115, 126-148 https://doi.org/10.1016/j.advengsoft.2017.09.003

## License
[LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

function addPackage(this, package)
%ADDPACKAGE Summary of this function goes here
%   Detailed explanation goes here

this.packages = [this.packages; package];
this.addStats(package);
end


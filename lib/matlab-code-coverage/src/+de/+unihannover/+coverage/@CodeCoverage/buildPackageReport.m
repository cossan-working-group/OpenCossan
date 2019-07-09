function buildPackageReport(this, metaPackage, profData)
%BUILDPACKAGEREPORT Build the report for one package including classes and
%functions

package = de.unihannover.coverage.stats.PackageStats(metaPackage.Name);

%classes
for i = 1:numel(metaPackage.Classes)
    package.addClass(this.buildClassReport(metaPackage.Classes{i}, profData));
end

%package functions
for i = 1:numel(metaPackage.Functions)
    package.addClass(this.buildFunctionReport(metaPackage.Name, metaPackage.Functions{i}, profData));
end

if ~isempty(package.classes)
    this.addPackage(package);
end

end


function buildReportFromDir(this, profData)
%BUILDREPORTFROMDIR Collect all packages inside the source folders and
%build the reports.

import de.unihannover.util.PackageUtils;
%% get package names
packageNames = {};
for i = 1:size(this.sources, 1)
    packageNames = [packageNames; PackageUtils.getPackageNamesFromDir(this.sources{i,1})]; %#ok<AGROW>
end
packageNames = unique(packageNames);

%% build report
for i = 1:numel(packageNames)
    this.buildPackageReport(meta.package.fromName(packageNames{i}), profData);
end

end


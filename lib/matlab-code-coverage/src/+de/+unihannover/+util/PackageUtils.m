classdef PackageUtils
    %PACKAGEUTILS Contains functions to get information about packages
    
    methods (Static)
        function packageNames = getPackageNamesFromDir(source)
            %GETPACKAGENAMESFROMDIR Returns all package names found inside
            %a directory
            
            import de.unihannover.util.PackageUtils;
            if source(end) ~= filesep
                source = [source filesep];
            end
            packageNames = {};
            
            idx = strfind(source,filesep);
            idx = idx(end-1)+1;
            if source(idx) == '+'
                metaPackage = meta.package.fromName(source(idx+1:end-1));
                packageNames = PackageUtils.getSubPackageNamesFromPackage(metaPackage);
            else
                files = dir(source);
                for i = 1:numel(files)
                    if files(i).isdir && files(i).name(1) ~= '.'
                        if files(i).name(1) == '+'
                            metaPackage = meta.package.fromName(files(i).name(2:end));
                            if isempty(metaPackage); continue; end
                            packageNames = [packageNames;
                                PackageUtils.getSubPackageNamesFromPackage(metaPackage)]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        function packageNames = getSubPackageNamesFromPackage(metaPackage)
            %GETSUBPACKAGENAMESFROMPACKAGE Returns all subpackages for a
            %given package
            import de.unihannover.util.PackageUtils;
            packageNames = {metaPackage.Name};
            
            for i = 1:numel(metaPackage.Packages)
                packageNames = [packageNames; PackageUtils.getSubPackageNamesFromPackage(metaPackage.Packages{i})]; %#ok<AGROW>
            end
        end
    end
    
end
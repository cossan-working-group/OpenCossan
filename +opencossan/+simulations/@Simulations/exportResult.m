function exportResult(obj, pf)
    %EXPORTRESULTS  This private methods of the class simulations is used
    %to store the results of the simulation, i.e. the batches, on the
    %disk
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of OpenCossan.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % OpenCossan is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % OpenCossan is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    import opencossan.OpenCossan
    
    if ~isfolder(obj.ResultFolder)
        [status, err] = mkdir(obj.ResultFolder);
        if ~status
            warning(err);
        end
    end
    
    file = fullfile(obj.ResultFolder, "pf.mat");
    save(file, 'pf');
    
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver();
    if ~isempty(XdbDriver)
        id = XdbDriver.getNextPrimaryID('Result');
        XdbDriver.insertRecord('StableType','Result',...
            'Nid', id, ...
            'CcossanObjects',{pf},...
            'CcossanObjectsNames',{'pf'});
    end
end

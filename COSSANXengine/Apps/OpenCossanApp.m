function varargout = OpenCossanApp(varargin)
% OPENCOSSANAPP MATLAB code for OpenCossanApp.fig
%      OPENCOSSANAPP, by itself, creates a new OPENCOSSANAPP or raises the existing
%      singleton*.
%
%      H = OPENCOSSANAPP returns the handle to a new OPENCOSSANAPP or the handle to
%      the existing singleton*.
%
%      OPENCOSSANAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPENCOSSANAPP.M with the given input arguments.
%
%      OPENCOSSANAPP('Property','Value',...) creates a new OPENCOSSANAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OpenCossanApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OpenCossanApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Author: Edoardo Patelli
% OpenCOSSAN Copyright (C) 2017 Edoardo Patelli
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================


% Edit the above text to modify the response to help OpenCossanApp

% Last Modified by GUIDE v2.5 11-Jan-2017 18:27:24

%% Be sure that the minimum requirements of cossan are satisfied

SrequiredMatlabVersion='9.0';

 if verLessThan('matlab', '8.1')    
    error('OpenCOSSAN:OpenCOSSAN:checkMatlabversion', ...
                    ['A Matlab version %s or higher is required!!!!' ...
                    '\nCurrent Matlab release is R%s\n\n',...
                    'It is not possible to install OpenCossan using this version of Matlab\n',...
                    'You can download the zip file from the cossan website (https://cossan.co.uk) and extract it manually in a folder\n'],...
                    SrequiredMatlabVersion,version)
elseif verLessThan('matlab', SrequiredMatlabVersion)
        warning('OpenCOSSAN:OpenCOSSAN:checkMatlabversion', ...
                    ['A Matlab version %s or higher is suggested!!!!' ...
                    '\nCurrent Matlab release is R%s\n\n',...
                    'Please be aware that some features of OpenCossan may not function properly or this Matlab version!!!!\n'],...
                    SrequiredMatlabVersion,version)
end


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OpenCossanApp_OpeningFcn, ...
    'gui_OutputFcn',  @OpenCossanApp_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before OpenCossanApp is made visible.
function OpenCossanApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OpenCossanApp (see VARARGIN)


% Always initialize variables
initializeVariables(hObject, eventdata, handles);
handles=guidata(hObject);

try
    axis(handles.axesLogo);
    imshow('OpenCossanIcon2.png')
catch
    set(handles.axesLogo,'Visible','off');
end


% Choose default command line output for OpenCossanApp
handles.output = hObject;

Sapps=matlab.apputil.getInstalledAppInfo;
mg = arrayfun(@(x)strcmp(x.name,'OpenCossanApp'),Sapps);

if isempty(mg)
    % Use local path since the Apps path is not available
    handles.OpenCossanData.SAppPath=pwd;
else
    handles.OpenCossanData.SAppPath=Sapps(mg).location;
end

if exist(fullfile(handles.OpenCossanData.SAppPath,'OpenCossanData.mat'),'file')
    handles.OpenCossanData=load(fullfile(handles.OpenCossanData.SAppPath,'OpenCossanData.mat'));
    set(handles.textInformation,...
        'String',...
        'Welcome back to OpenCossanApp')    
    if handles.OpenCossanData.LicenseAgreement
        set(handles.LicensePanel,'visible','off')
    end
else
    set(handles.textInformation,...
    'String',...
    'Check the license agreement')
end


% install (or initialize) display
set(handles.textInstallationPath,'string',handles.OpenCossanData.InstallationPath);
set(handles.textSourcePath,'string',handles.OpenCossanData.SourcePath);
set(handles.textOpenCossan,'string',handles.OpenCossanData.OpenCossanInstalledVersion);
set(handles.textVersionApp,'string',handles.OpenCossanData.AppInstalledVersion);

SlicenceShort=['BY CLICKING ON THE "ACCEPT" BUTTON BELOW YOU AGREE TO THE TERMS OF THIS LICENCE WHICH WILL BIND YOU.',...
    'IF YOU DO NOT AGREE TO THE TERMS OF THIS LICENCE, CLICK ON THE "REJECT" BUTTON BELOW.',...
    ];

set(handles.LicenseText,'string',SlicenceShort);


try
    axes(handles.logoLicense)
    matlabImage = imread('OpenCossanLogo.WhiteBG.png');
    image(matlabImage)
    axis off
    axis image
catch
    set(handles.logoLicense,'Visible','off');
end

if handles.OpenCossanData.LicenseAgreement
    set(handles.Run,'Enable','On');
else
    set(handles.Run,'Enable','off');
end

%% Check if some already downloaded packages are available
if exist(handles.OpenCossanData.ToolboxFullPath,'file')
    set(handles.Install,'Enable','On');
else
    set(handles.Install,'Enable','off');
end

%% Check if OpenCossan toolbox is installed
toolboxes = matlab.addons.toolbox.installedToolboxes;

if ~isempty(toolboxes)
    handles.OpenCossanData.tableToolboxesOpenCossan=toolboxes(arrayfun(@(x)strcmp(x.Name,'OpenCossan'),toolboxes));
    
    if ~isempty(handles.OpenCossanData.tableToolboxesOpenCossan)
        set(handles.Run,'Enable','On');
        set(handles.Install,'String','Update');
    else
        set(handles.Run,'Enable','off');
        set(handles.Install,'String','Install');
    end
else
    set(handles.Run,'Enable','off');
    set(handles.Install,'String','Install');
end

% install handles structure
guidata(hObject,handles)

function initializeVariables(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to pushbuttonManualInstall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%
% This function initialize the variables stored in the matlab file
% OpenCossanData.mat

if isempty(userpath)
    handles.OpenCossanData.InstallationPath='N/A';
else
    handles.OpenCossanData.InstallationPath=fullfile(userpath,'Add-Ons','Toolboxes');
end

handles.OpenCossanData.SourcePath=pwd;
handles.OpenCossanData.OpenCossanInstalledVersion='N/A';
handles.OpenCossanData.AppInstalledVersion='N/A';
handles.OpenCossanData.updateOpenCossanNeeded=1;
handles.OpenCossanData.updateAppNeeded=0;
handles.OpenCossanData.InstallationFileNameOpenCossan='OpenCossan.mltbx';
handles.OpenCossanData.InstallationFileNameApp='OpenCossanApp.mlappinstall';
handles.OpenCossanData.ServerSVNInfoPath='http://cossan.co.uk/svninfo/stable/';
handles.OpenCossanData.ServerSVNInfoFileOpenCossan='svn_OpenCossan.mltbx.xml';
handles.OpenCossanData.ServerSVNInfoFileApp='svn_OpenCossanApp.mlappinstall.xml';
handles.OpenCossanData.URL='https://cossan.co.uk/svn/OpenCossan/branches/Archives/stable/';
handles.OpenCossanData.toolboxFile = 'OpenCossan.mltbx';
handles.OpenCossanData.LicenseAgreement=0;
handles.OpenCossanData.LicenseAgreementText=0;
handles.OpenCossanData.WebCredentials=weboptions;
handles.OpenCossanData.AppFullPath='';
handles.OpenCossanData.ToolboxFullPath='';
handles.OpenCossanData.tableToolboxesOpenCossan=[];


%Get revision for the COSSAN APP. I am assuming that when the CossanAPP is
% used for the first time it is up-to-date

try
    Crevision=getRevision(handles.OpenCossanData.ServerSVNInfoFileApp,handles);
    handles.OpenCossanData.AppInstalledVersion=Crevision;
catch
    set(handles.textInformation,...
        'String',...
        ['Unable to connect with COSSAN server. Download the file ' handles.OpenCossanData.ServerSVNInfoPath handles.OpenCossanData.ServerSVNInfoFileApp])
end


guidata(hObject,handles)

hold=guidata(hObject); %#ok<NASGU>

% --- Outputs from this function are returned to the command line.
function varargout = OpenCossanApp_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handlePlease OpenCossan not found.  to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    OpenCossan('ScossanRoot',fullfile(handles.OpenCossanData.InstallationPath,'OpenCossan','code'))
    close OpenCossanApp
catch ME
    set(handles.textInformation,'String',['OpenCossan not found. Please check your installation path', ME.message])
end


% --- Executes on button press in CheckUpdates.
function CheckUpdates_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to CheckUpdates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Main
handles.OpenCossanData.OpenCossanServerVersion=getRevision(handles.OpenCossanData.ServerSVNInfoFileOpenCossan,handles);

% Compare with the local version
if ~strcmp(handles.OpenCossanData.OpenCossanServerVersion,handles.OpenCossanData.OpenCossanInstalledVersion)
    handles.OpenCossanData.updateCossanNeeded=1;
else
    handles.OpenCossanData.updateCossanNeeded=0;
end

set(handles.textOpenCossan,'string',['Current version: ' char(handles.OpenCossanData.OpenCossanInstalledVersion) ' Available: ' char(handles.OpenCossanData.OpenCossanServerVersion)])


% CossanApp
handles.OpenCossanData.AppServerVersion=getRevision(handles.OpenCossanData.ServerSVNInfoFileApp,handles);
% Compare with the local version
if ~strcmp(handles.OpenCossanData.AppServerVersion,handles.OpenCossanData.AppInstalledVersion)
    handles.OpenCossanData.updateAppNeeded=1;
else
    handles.OpenCossanData.updateAppNeeded=0;
end

set(handles.textVersionApp,'string',['Current version: ' char(handles.OpenCossanData.AppInstalledVersion) ' Available: ' char(handles.OpenCossanData.AppServerVersion)])

if any([handles.OpenCossanData.updateCossanNeeded handles.OpenCossanData.updateAppNeeded])
    set(handles.textInformation,'String','One or more Update(s) are available and can be downloaded.')
end

guidata(hObject,handles);

% --- Executes on button press in Download.
function Download_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to Download (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Download

%[u,p] = getMyCredentials(handles.OpenCossanData.WebCredentials);
[u,p] = logindlg('Title','OpenCossan account');

if isempty(u) || isempty(p)
    set(handles.textInformation,'String',...
        'Without a valid account it is not possible to estabilish a connection with the cossan server');
    set(handles.textInformation,'ForegroundColor','red');
    return
end

options = weboptions('Username',u,'Password',p);
handles.OpenCossanData.WebCredentials=options;

    % Collect old status
    RunOldStatus=get(handles.Run,'Enable');
    InstallOldStatus=get(handles.Install,'Enable');
    UpdateOldStatus=get(handles.CheckUpdates,'Enable');
    ResetOldStatus=get(handles.pushbuttonReset,'Enable');
    DownloadOldStatus=get(handles.Download,'Enable');
    
    % Make bottons unavailable while downloading files
    set(handles.Run,'Enable','off');
    set(handles.Install,'Enable','off');
    set(handles.CheckUpdates,'Enable','off');
    set(handles.pushbuttonReset,'Enable','off');
    set(handles.Download,'Enable','off');


if handles.OpenCossanData.updateAppNeeded
    set(handles.textInformation,'String','Downloading the OpenCossanApp');
   
    drawnow();
    % Remove old file if exists
    if exist(handles.OpenCossanData.InstallationFileNameApp,'file')
        delete(handles.OpenCossanData.InstallationFileNameApp)
    end
    
    try
        handles.OpenCossanData.AppFullPath=websave('OpenCossanApp',...
            [handles.OpenCossanData.URL handles.OpenCossanData.InstallationFileNameApp],options);
        
    catch ME
        set(handles.textInformation,'String',ME.message);
    end
end

if handles.OpenCossanData.updateOpenCossanNeeded==1
    set(handles.textInformation,'String','Downloading the OpenCossan Toolbox! This is a big package and it might take a while');
    drawnow();
    
    % Remove old file if exists
    if exist(handles.OpenCossanData.InstallationFileNameOpenCossan,'file')
        delete(handles.OpenCossanData.InstallationFileNameOpenCossan)
    end
    
    try
        handles.OpenCossanData.ToolboxFullPath=websave('OpenCossan',...
            [handles.OpenCossanData.URL handles.OpenCossanData.InstallationFileNameOpenCossan],options);
        
        set(handles.textInformation,'String','OpenCossan Toolbox downloaded');
    catch ME
        set(handles.textInformation,'String',ME.message);
    end
    
end

%% Enable install button
set(handles.Install,'Enable','On')

% Restore old status
set(handles.Run,'Enable',RunOldStatus);
set(handles.CheckUpdates,'Enable',UpdateOldStatus);
set(handles.pushbuttonReset,'Enable',ResetOldStatus);
set(handles.Download,'Enable',DownloadOldStatus);
    
% refresh GUI
drawnow();

guidata(hObject,handles);

% --- Executes on button press in Install.
function Install_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to Install (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Collect old status
RunOldStatus=get(handles.Run,'Enable');
InstallOldStatus=get(handles.Install,'Enable');
UpdateOldStatus=get(handles.CheckUpdates,'Enable');
ResetOldStatus=get(handles.pushbuttonReset,'Enable');
DownloadOldStatus=get(handles.Download,'Enable');

% Make bottons unavailable while downloading files
set(handles.Run,'Enable','off');
set(handles.Install,'Enable','off');
set(handles.CheckUpdates,'Enable','off');
set(handles.pushbuttonReset,'Enable','off');
set(handles.Download,'Enable','off');

drawnow();
    
% This function is used to install OpenCossan
if handles.OpenCossanData.updateOpenCossanNeeded
    
    if ~isempty(handles.OpenCossanData.tableToolboxesOpenCossan)
        Stextupdate='Updating OpenCosssan toolbox. This can take a while.. be patient.';
        set(handles.textInformation,'String',Stextupdate,'ForegroundColor',[0 0.45 0.74])
        
        try
            matlab.addons.toolbox.uninstallToolbox(handles.OpenCossanData.tableToolboxesOpenCossan)
            Stextupdate='Old toolbox removed. Installing the new version. This can take a while.. be patient.';
        catch ME
            set(handles.textInformation,'String',ME.message,'ForegroundColor','red');
        end
    else
        Stextupdate='Installing OpenCosssan toolbox. This can take a while.. be patient.';
    end
    
    set(handles.textInformation,'String',Stextupdate,'ForegroundColor',[0 0.45 0.74])
    
    try
        handles.OpenCossanData.tableToolboxesOpenCossan = matlab.addons.toolbox.installToolbox(handles.OpenCossanData.ToolboxFullPath);
        
        Stextupdate=['Installation completed. Unique toolbox identifier: ', handles.OpenCossanData.tableToolboxesOpenCossan.Guid];
        set(handles.textInformation,'String',Stextupdate)
        set(handles.Install,'String','Update');
    catch ME
        set(handles.textInformation,'String',ME.message,'ForegroundColor','red');
    end
end

if handles.OpenCossanData.updateAppNeeded
    Stextupdate='Updating OpenCosssan App. ';
    set(handles.textInformation,'String',Stextupdate)

    try 
        installedToolbox = matlab.addons.toolbox.installToolbox(handles.OpenCossanData.AppFullPath);
        Stextupdate=['Installation completed. Unique toolbox identifier: ', installedToolbox.Guid];
        set(handles.textInformation,'String',Stextupdate)
    catch ME
       set(handles.textInformation,'String',ME.message,'ForegroundColor','red');
    end
    drawnow();
end

    % Restore old status
    set(handles.Run,'Enable',RunOldStatus);
    set(handles.Install,'Enable',InstallOldStatus);
    set(handles.CheckUpdates,'Enable',UpdateOldStatus);
    set(handles.pushbuttonReset,'Enable',ResetOldStatus);
    set(handles.Download,'Enable',DownloadOldStatus);

guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
OpenCossanData = handles.OpenCossanData;
save(fullfile(handles.OpenCossanData.SAppPath,'OpenCossanData.mat'),'-struct','OpenCossanData');

delete(hObject);


% --- Executes on button press in pushbuttonReset.
function pushbuttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textInformation,'String','Remove all the information stored in the App.')
drawnow

if exist('OpenCossanData.mat','file')
    delete('OpenCossanData.mat')
end

initializeVariables(hObject, eventdata, handles);

set(handles.LicensePanel,'visible','on')
set(handles.AcceptLicense,'enable','off')
set(handles.NoLicense,'enable','off')


function [Srevision]=getRevision(filename,handles)
% Private function to retrieve the revision number from the server

try
    Xfile=xmlread([handles.OpenCossanData.ServerSVNInfoPath filename]);
    Xout=Xfile.getDocumentElement;
    Xelement=Xout.getElementsByTagName('entry');
    Xitem=Xelement.item(0);
    Srevision=char(Xitem.getAttribute('revision'));
catch
    warndlg({[' Problem retriving information from : ' handles.OpenCossanData.ServerSVNInfoPath filename]; ...
        'Please check that you can connect with the Cossan server'},'OpenCossanApp','replace')
    Srevision='N/A';
end

% --- Executes during object creation, after setting all properties.
function textSourcePath_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to textOpenCossan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function textOpenCossan_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to textOpenCossan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in LicenseAgreement.
function LicenseAgreement_Callback(hObject, eventdata, handles)
% hObject    handle to LicenseAgreement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('OpenCossan License agreement \n The full version of the agreement is available here: http://www.cossan.co.uk/software/license.txt', ...
    'License Agreement ', ...
    'Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        disp([choice ' Thank you'])
        handles.OpenCossanData.LicenseAgreement= 1;
    case 'No'
        disp([choice ' If you proceed with the installation you implicitly accepting the license agreement'])
        handles.OpenCossanData.LicenseAgreement= 0;
end

guidata(hObject,handles)


% --- Executes on button press in AcceptLicense.
function AcceptLicense_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptLicense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OpenCossanData.LicenseAgreement= 1;
set(handles.LicensePanel,'visible','off')

guidata(hObject,handles)

% --- Executes on button press in NoLicense.
function NoLicense_Callback(hObject, eventdata, handles)
% hObject    handle to NoLicense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(gcf);

% --- Executes on button press in WebLicense.
function WebLicense_Callback(hObject, eventdata, handles)
% hObject    handle to WebLicense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
url = 'license.html';
web(url)

set(handles.NoLicense,'enable','on')
set(handles.AcceptLicense,'enable','on')

% --- Executes during object creation, after setting all properties.
function LicensePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LicensePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes when LicensePanel is resized.
function LicensePanel_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to LicensePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Install.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to Install (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

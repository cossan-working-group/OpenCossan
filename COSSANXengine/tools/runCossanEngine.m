%% read .m file
function runCossanEngine(Sname)

initializeCOSSAN('NverboseLevel',3);

if nargin<1
    error('openCOSSAN:runCossanEngine', ...
          'please specify the full path of your script')
end

fid = fopen(Sname);

tline = fgetl(fid);
while ischar(tline)
    disp(tline)
    eval(tline)
    tline = fgetl(fid);
end

fclose(fid);


function stats = buildLinesReport(code, runLineIndex, firstLine, lastLine, profData)
%BUILDLINESREPORT Summary of this function goes here
%   Detailed explanation goes here

stats = de.unihannover.coverage.stats.LineStats(sum(lastLine - firstLine + 1));

for line = firstLine:lastLine
    
    hits = 0;
    time = 0;
    if ~isempty(profData)
        idx = find(profData.ExecutedLines(:, 1) == line);
        if ~isempty(idx)
            hits = profData.ExecutedLines(idx, 2);
            time = profData.ExecutedLines(idx, 3);
        end
    end
    
    branch = ~isempty(regexp(code{line}, '\<(if|switch|try)\>', 'once', 'tokens'));
    complex = ~isempty(regexp(code{line},'(\<otherwise\>)|(\<catch\>)|(\<elseif\>)|(\<if\>)|(\<while\>)|(\<for\>)|(\<case\>)|(\<continue\>)|(&&)|(||)','once','tokens'));
    valid = any(runLineIndex == line) && ~(isequal(strtrim(code{line}),'end'));
    
    stats.addLine(line-firstLine+1,line,valid,hits,branch,time,complex);
end

end


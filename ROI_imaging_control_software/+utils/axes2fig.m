function axes2fig(UIAxes,fileName)
    % Create a temporary figure with axes.
    fig = figure;
    fig.Visible = 'off';
    figAxes = axes(fig);
    % Copy all UIAxes children
    allChildren = UIAxes.XAxis.Parent.Children;
    copyobj(allChildren, figAxes)
    figAxes.XLim = UIAxes.XLim;
    figAxes.YLim = UIAxes.YLim;
    figAxes.ZLim = UIAxes.ZLim;
    figAxes.DataAspectRatio = UIAxes.DataAspectRatio;
    figAxes.YAxis.TickLength = UIAxes.YAxis.TickLength;
    figAxes.YTick = UIAxes.YTick;
    figAxes.YTickLabel =  UIAxes.YTickLabel;
    figAxes.XAxis.Visible = UIAxes.XAxis.Visible;

    pause(0.5);
    figAxes.YRuler.Axle.Visible = UIAxes.YRuler.Axle.Visible;
    % 因为设置visible off必须这样设置，才能正常打开fig文件
    set(fig, 'CreateFcn', 'set(gcbo,''Visible'',''on'')')
    % Save as png and fig files.
    savefig(fig, fileName);
    delete(fig);
end


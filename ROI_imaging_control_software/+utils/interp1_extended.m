function vq = interp1_extended(x,v,xq,varargin)
    if isempty(x)
        vq = xq;
    elseif isscalar(x)
        vq = xq-x+v;
    else 
	% 插值
        vq = interp1(x,v,xq,varargin{:});
    end
end
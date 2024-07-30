function frame_shifted = shift_frame(frame, dy, dx)
%SHIFT_FRAME Shifts the input frame by dy and dx.
%   frame_shifted = SHIFT_FRAME(frame, dy, dx) returns the frame shifted by
%   dy (vertical shift) and dx (horizontal shift).
%
%   Parameters
%   ----------
%   frame: Ly x Lx
%       The input frame to be shifted.
%   dy: int
%       The vertical shift amount.
%   dx: int
%       The horizontal shift amount.
%
%   Returns
%   -------
%   frame_shifted: Ly x Lx
%       The shifted frame.

    % Shift the frame using circshift function in MATLAB
    frame_shifted = circshift(frame, [-dy, -dx]);
end
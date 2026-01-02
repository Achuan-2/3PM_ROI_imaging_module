classdef SegmentationPy < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        model
        img_nparray
        ops
        seg_mask = [];
        seg_flow = [];
        seg_mask_matlab = [];
        auto_rerun =false;
        enable = false;
    end
    methods(Static)
        function result = mat2nparray(matarray)
            %mat2nparray Convert a Matlab array into an nparray
            %   Convert an n-dimensional Matlab array into an equivalent nparray
            data_size=size(matarray);
            if length(data_size)==1
                % 1-D vectors are trivial
                result=py.numpy.array(matarray);
            elseif length(data_size)==2
                % A transpose operation is required either in Matlab, or in Python due
                % to the difference between row major and column major ordering
                transpose=matarray';
                % Pass the array to Python as a vector, and then reshape to the correct
                % size
                result=py.numpy.reshape(transpose(:)', int32(data_size));
            else
                % For an n-dimensional array, transpose the first two dimensions to
                % sort the storage ordering issue
                transpose=permute(matarray,length(data_size):-1:1);
                % Pass it to python, and then reshape to the python style of matrix
                % sizing
                result=py.numpy.reshape(transpose(:)', int32(fliplr(size(transpose))));
            end
        end

    end

    methods
        function self = SegmentationPy()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            self.ops = py.pycellpose.default_ops();
            self.model = py.pycellpose.init(self.ops);
        end

        function [mask_matlab]= run(self,img,flow_threshold,norm_blocksize)
            self.ops{'flow_threshold'} = flow_threshold;
            self.ops{'tile_norm_blocksize'} = norm_blocksize;
            self.img_nparray = self.mat2nparray(img);

            % run segmentation
            results = py.pycellpose.seg(self.model,self.img_nparray,self.ops);


            % segment result

            self.seg_mask = results{1};
            self.seg_flow = results{2};
            mask_matlab = uint16(self.seg_mask);
            self.seg_mask_matlab = mask_matlab;
        end

        function mask_matlab = change_threshold(self,threshold)

            self.ops{'flow_threshold'} = threshold;
            self.seg_mask = py.pycellpose.recompute_masks_from_flows( ...
                self.seg_mask, ...
                self.seg_flow, ...
                self.ops);
            mask_matlab = uint8(self.seg_mask);
        end

    end
end


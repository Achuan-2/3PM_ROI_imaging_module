"""
用于处理 cellpose 流数据的模块，包括：
1. 从 model.eval() 处理流数据
2. 从现有流重新计算掩码
"""
from cellpose import models
import cv2
import numpy as np
from cellpose import models, dynamics
from cellpose.transforms import normalize99, resize_image



def default_ops():
    """ default options to run pipeline """
    return {
        'gpu': True,  # whether or not to use GPU, will check if GPU available
        # which gpu device to use, use an integer for torch, or mps for M1, (default: '0')
        'device': '0',
        'do_3D': False,
        'net_avg': True,
        'augment': False,
        'resample': True,
        'flow_threshold': 0.4,
        'cellprob_threshold': 0,
        'stitch_threshold': 0,
        # minimum number of pixels per mask, can turn off with -1, (default: 15)
        'min_size': 15,
        'invert': False,  # invert grayscale channel
        'batch_size': 8, # inference batch size. Default: %(default)s
        'interp': False,  # interpolate when running dynamics (default: False)
        'normalize': True,
        # axis of image which corresponds to image channels (default: None)
        'channel_axis': None,
        'z_axis': None,
        'anisotropy': 1.0,  # anisotropy of volume in 3D (default: 1.0)
        'model_loaded': True,
        'logger': None,
        'nIter': 0,
        'tile_norm_blocksize': 128, # compute normalization in tiles across image to brighten dark areas, to turn on set to window size in pixels (e.g. 100)
        'NZ':1 # number of z slices in 3D image
    }

def seg(img, ops):
    # Parameter settings
    device, gpu = models.assign_device(
        use_torch=True, gpu=ops['gpu'], device=ops['device'])

    model = models.CellposeModel(gpu=gpu, device=device)  # model for cellpose segmentation

    out = model.eval(img,batch_size=ops['batch_size'], flow_threshold=ops['flow_threshold'], cellprob_threshold=ops['cellprob_threshold'],
                                  normalize={"tile_norm_blocksize": ops['tile_norm_blocksize']} )
    mask, flows = out[:2]
    return mask, flows

def recompute_masks_from_flows(mask,flows,ops):
    """
    从现有的流和概率图重新计算掩码，使用新的阈值参数
    
    Parameters
    ----------
    mask : ndarray
        原始掩码
    flows : ndarray
        流向量
    ops : dict
        选项字典，包含以下键：
        - cellprob_threshold : float
            细胞概率图的阈值
        - flow_threshold : float
            流误差的阈值
        - niter : int
            迭代次数
        - do_3D : bool
            是否使用3D处理
        - min_size : int
            最小细胞大小
        
    Returns
    -------
    masks : ndarray
        整数标记的掩码，0表示背景，1,2,...表示细胞
    """
    try:
        flow_threshold = ops.get('flow_threshold', 0.4)
        cellprob_threshold = ops.get('cellprob_threshold', 0)
        niter = ops.get('niter', 0)
        do_3D = ops.get('do_3D', False)
        min_size = ops.get('min_size', 0)
        logger = ops.get('logger', None)

        # 获取流向量和细胞概率图
        flows = process_flows_from_eval(flows, mask,ops)
        print(flows)
        dP = flows[2].squeeze()  # XY流向量
        cellprob = flows[3].squeeze()  # 原始细胞概率图
        
        if logger:
            logger.info(f"重新计算掩码：细胞概率阈值={cellprob_threshold:.3f}, 流误差阈值={flow_threshold:.3f}")
        
        # 使用新参数计算掩码
        masks = dynamics.resize_and_compute_masks(
            dP=dP,
            cellprob=cellprob,
            niter=niter,
            do_3D=do_3D,
            min_size=min_size,
            cellprob_threshold=cellprob_threshold, 
            flow_threshold=flow_threshold
        )
        print(masks)
            
        if logger:
            logger.info(f"找到 {len(np.unique(masks)[1:])} 个细胞")
            
        return masks
    
    except Exception as e:
        if logger:
            logger.error(f"重新计算掩码时出错: {str(e)}")
        else:
            print(f"ERROR: 重新计算掩码时出错: {str(e)}")
        return None

def process_flows_from_eval(flows, mask,ops):
    """
    处理从 model.eval() 返回的流，转换为GUI使用的格式
    
    Parameters
    ----------
    flows : list
        model.eval() 返回的流列表
    original_size : tuple, optional
        原始图像大小 (Ly, Lx)，如果需要调整大小
    NZ : int, optional
        z轴上的层数
    load_3D : bool, optional
        是否使用3D处理
    stitch_threshold : float, optional
        3D拼接的阈值
        
    Returns
    -------
    flows_processed : list
        处理后的流列表，用于GUI显示和掩码计算
    """
    flows_processed = []
    NZ = ops['NZ']
    load_3D = ops['do_3D']
    original_size = (mask.shape[-2], mask.shape[-1]) if mask is not None else (None, None)
    stitch_threshold = ops['stitch_threshold']
    
    # 转换flows为适合GUI的格式
    flows_processed.append(flows[0].copy())  # RGB flow
    flows_processed.append((np.clip(normalize99(flows[2].copy()), 0, 1) * 255).astype("uint8"))  # cellprob
    flows_processed.append(flows[1].copy())  # XY flows
    flows_processed.append(flows[2].copy())  # original cellprob

    if load_3D:
        if stitch_threshold == 0.:
            flows_processed.append((flows[1][0] / 10 * 127 + 127).astype("uint8"))
        else:
            flows_processed.append(np.zeros(flows[1][0].shape, dtype="uint8"))
    
    # 如果需要调整大小
    if original_size is not None:
        Ly, Lx = original_size
        
        if not load_3D:
            if flows_processed[0].shape[-3:-1] != (Ly, Lx):
                resized_flows = []
                for flow in flows_processed:
                    resized_flows.append(
                        resize_image(flow, Ly=Ly, Lx=Lx, interpolation=cv2.INTER_NEAREST)
                    )
                flows_processed = resized_flows
        else:
            resized_flows = []
            Lz0, Ly0, Lx0 = flows_processed[0].shape[:3]
            Lz = NZ
            
            for flow in flows_processed:
                flow0 = flow
                if Ly0 != Ly:
                    flow0 = resize_image(flow0, Ly=Ly, Lx=Lx,
                                       no_channels=flow0.ndim==3, 
                                       interpolation=cv2.INTER_NEAREST)
                if Lz0 != Lz:
                    flow0 = np.swapaxes(
                        resize_image(np.swapaxes(flow0, 0, 1),
                                   Ly=Lz, Lx=Lx,
                                   no_channels=flow0.ndim==3, 
                                   interpolation=cv2.INTER_NEAREST),
                        0, 1
                    )
                resized_flows.append(flow0)
            flows_processed = resized_flows
    
    # 添加第一个轴（如果是单张图像）
    if NZ == 1:
        flows_processed = [flow[np.newaxis, ...] if flow.ndim < 4 else flow for flow in flows_processed]
    
    return flows_processed

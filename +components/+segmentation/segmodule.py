import numpy as np
import cv2
from cellpose import models, dynamics
from cellpose.transforms import normalize99, resize_image


def cal_diam(std_image, ops):
    """
    """
    device, gpu = models.assign_device(
        use_torch=True, gpu=ops['gpu'], device=ops['device'])
    pretrained_size = models.size_model_path('cyto', True)
    cp = models.CellposeModel(device=device, gpu=gpu,
                              model_type='cyto',
                              diam_mean=30,
                              net_avg=ops['net_avg'])  # model for diameter calculation
    sz = models.SizeModel(device=device, pretrained_size=pretrained_size,
                          cp_model=cp)
    sz.model_type = ops['model_type']
    diameter, _ = sz.eval(std_image, channels=ops['channels'], channel_axis=None, invert=ops['invert'],
                          batch_size=ops['batch_size'],
                          augment=ops['augment'], tile=True, normalize=ops['normalize'])
    return diameter


def seg(std_image, ops):
    # Parameter settings
    device, gpu = models.assign_device(
        use_torch=True, gpu=ops['gpu'], device=ops['device'])

    model = models.Cellpose(gpu=gpu, device=device, model_type=ops['model_type'],
                            net_avg=ops['net_avg'])  # model for cellpose segmentation

    out = model.eval(std_image, channels=ops['channels'], diameter=ops['diameter'],
                     do_3D=ops['do_3D'], net_avg=ops['net_avg'],
                     augment=ops['augment'],
                     resample=ops['resample'],
                     flow_threshold=ops['flow_threshold'],
                     cellprob_threshold=ops['cellprob_threshold'],
                     stitch_threshold=ops['stitch_threshold'],
                     min_size=ops['min_size'],
                     invert=ops['invert'],
                     batch_size=ops['batch_size'],
                     interp=ops['interp'],
                     normalize=ops['normalize'],
                     channel_axis=ops['channel_axis'],
                     z_axis=ops['z_axis'],
                     anisotropy=ops['anisotropy'],
                     model_loaded=True)
    mask, flows = out[:2]
    return mask, flows


def seg_default_ops():
    """ default options to run pipeline """
    chan1 = 1
    chan2 = 0
    diameter = 21.5
    return {
        'gpu': True,  # whether or not to use GPU, will check if GPU available
        # which gpu device to use, use an integer for torch, or mps for M1, (default: '0')
        'device': '0',
        'model_type': 'cyto2',
        'channels': [chan1, chan2],
        'diameter': diameter,
        'do_3D': False,
        'net_avg': True,
        'augment': False,
        'resample': True,
        'flow_threshold': 0.1,
        'cellprob_threshold': 0,
        'stitch_threshold': 0,
        # minimum number of pixels per mask, can turn off with -1, (default: 15)
        'min_size': 15,
        'invert': False,  # invert grayscale channel
        'batch_size': 8,
        'interp': False,  # interpolate when running dynamics (default: False)
        'normalize': True,
        # axis of image which corresponds to image channels (default: None)
        'channel_axis': None,
        'z_axis': None,
        'anisotropy': 1.0,  # anisotropy of volume in 3D (default: 1.0)
        'model_loaded': True
    }

def test():
    print("hello")
def dynamic_compute(masks, flows, ops):
    transform_flow = [[], [], []]
    transform_flow[0] = flows[0].copy()  # RGB flow
    transform_flow[1] = (np.clip(normalize99(flows[2].copy()),
                                 0, 1) * 255).astype(np.uint8)  # dist/prob
    masks = masks[np.newaxis, ...]
    transform_flow[0] = resize_image(transform_flow[0], masks.shape[-2], masks.shape[-1],
                                     interpolation=cv2.INTER_NEAREST)
    transform_flow[1] = resize_image(
        transform_flow[1], masks.shape[-2], masks.shape[-1])
    transform_flow[2] = np.zeros(masks.shape[1:], dtype=np.uint8)
    transform_flow = [transform_flow[n][np.newaxis, ...]
                      for n in range(len(transform_flow))]
    transform_flow.append(flows[3].squeeze())  # p
    transform_flow.append(np.concatenate(
        (flows[1], flows[2][np.newaxis, ...]), axis=0))  # dP, dist/prob

    flow_threshold = ops['flow_threshold']
    cellprob_threshold = ops['cellprob_threshold']
    maski = dynamics.compute_masks(transform_flow[4][:-1],
                                   transform_flow[4][-1],
                                   p=transform_flow[3].copy(),
                                   cellprob_threshold=cellprob_threshold,
                                   flow_threshold=flow_threshold,
                                   resize=masks.shape[-2:])[0]

    return maski

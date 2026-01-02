# train_periodic_denoising.py
import os
import argparse
import itertools
import datetime
import random
import numpy as np
import torch
import torch.backends.cudnn as cudnn
from torch.utils.data import DataLoader
from torch.autograd import Variable
# Local imports
from model.models_periodic_denoise import Generator, Discriminator
from utils.utils_periodic_denoise import ReplayBuffer, LambdaLR, weights_init_normal
from datasets_load.datasets_periodic_denoise import PeriodicDenoiseDataset
# Visdom for visualization
from visdom import Visdom
def setup_seed(seed):
    """Set all seeds for reproducibility."""
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
def worker_init_fn(worker_id):
    """Ensure DataLoader workers respect global seed."""
    np.random.seed(int(torch.initial_seed()) % (2**32 - 1))
    random.seed(int(torch.initial_seed()) % (2**32 - 1))
# ==============================
# Argument Parser
# ==============================
parser = argparse.ArgumentParser()
parser.add_argument('--epoch', type=int, default=0, help='starting epoch')
parser.add_argument('--n_epochs', type=int, default=30, help='total epochs')
parser.add_argument('--batchSize', type=int, default=10, help='batch size')
parser.add_argument('--raw_tif', type=str, default='./datasets/file_00020_ch1.tif', help='Path to raw noisy multi-page TIFF')
parser.add_argument('--noise_tif', type=str, default='./datasets/file_00020_ch1-ripple.tif', help='Path to dependent noise multi-page TIFF')
parser.add_argument('--datanum', type=int, default=10000, help='Number of training samples')
parser.add_argument('--trainoutput', type=str, default='./train_out/periodic_denoise_pth_model')
parser.add_argument('--lr', type=float, default=0.0001)
parser.add_argument('--decay_epoch', type=int, default=20)
parser.add_argument('--size', type=int, default=512, help='Signal length')
parser.add_argument('--input_nc', type=int, default=1)
parser.add_argument('--output_nc', type=int, default=1)
parser.add_argument('--cuda', action='store_true', default=torch.cuda.is_available())
parser.add_argument('--n_cpu', type=int, default=0, help='Number of workers for DataLoader')
parser.add_argument('--seed', type=int, default=2, help='Random seed for reproducibility')
parser.add_argument('--visdom_port', type=int, default=10000, help='Visdom server port')
parser.add_argument('--visdom_env', type=str, default='periodic_denoising', help='Visdom environment name')
opt = parser.parse_args()
# Set seed
setup_seed(opt.seed)
print("Options:", opt)
# ==============================
# Setup Visdom
# ==============================
viz = Visdom(port=opt.visdom_port, env=opt.visdom_env)
if not viz.check_connection():
    raise RuntimeError("Failed to connect to Visdom server. Run: python -m visdom.server")
# Initialize plots
loss_win = None
signal_win = None
# ==============================
# Setup Models
# ==============================
netG_A2B = Generator(opt.input_nc, opt.output_nc)
netG_B2A = Generator(opt.output_nc, opt.input_nc)
netD_A = Discriminator(opt.input_nc)
netD_B = Discriminator(opt.output_nc)

device = torch.device('cuda' if opt.cuda else 'cpu')
netG_A2B.to(device)
netG_B2A.to(device)
netD_A.to(device)
netD_B.to(device)

netG_A2B.apply(weights_init_normal)
netG_B2A.apply(weights_init_normal)
netD_A.apply(weights_init_normal)
netD_B.apply(weights_init_normal)
# ==============================
# Losses & Optimizers
# ==============================
criterion_GAN = torch.nn.MSELoss()
criterion_cycle = torch.nn.L1Loss()
criterion_identity = torch.nn.L1Loss()

optimizer_G = torch.optim.Adam(
    itertools.chain(netG_A2B.parameters(), netG_B2A.parameters()),
    lr=opt.lr, betas=(0.5, 0.999)
)
optimizer_D_A = torch.optim.Adam(netD_A.parameters(), lr=opt.lr, betas=(0.5, 0.999))
optimizer_D_B = torch.optim.Adam(netD_B.parameters(), lr=opt.lr, betas=(0.5, 0.999))

lr_scheduler_G = torch.optim.lr_scheduler.LambdaLR(
    optimizer_G, lr_lambda=LambdaLR(opt.n_epochs, opt.epoch, opt.decay_epoch).step
)
lr_scheduler_D_A = torch.optim.lr_scheduler.LambdaLR(
    optimizer_D_A, lr_lambda=LambdaLR(opt.n_epochs, opt.epoch, opt.decay_epoch).step
)
lr_scheduler_D_B = torch.optim.lr_scheduler.LambdaLR(
    optimizer_D_B, lr_lambda=LambdaLR(opt.n_epochs, opt.epoch, opt.decay_epoch).step
)
# ==============================
# Data Loading
# ==============================
dataset_A = PeriodicDenoiseDataset(
    raw_tif_path=opt.raw_tif,
    noise_tif_path=opt.noise_tif,
    num_samples=opt.datanum,
    size=opt.size,
    domain='A'
)

dataset_B = PeriodicDenoiseDataset(
    raw_tif_path=opt.raw_tif,
    noise_tif_path=opt.noise_tif,
    num_samples=opt.datanum,
    size=opt.size,
    domain='B'
)
print(f"Dataset A size: {len(dataset_A)}")
dataloader_A = DataLoader(
    dataset_A, batch_size=opt.batchSize, shuffle=False,
    num_workers=opt.n_cpu, worker_init_fn=worker_init_fn
)
dataloader_B = DataLoader(
    dataset_B, batch_size=opt.batchSize, shuffle=False,
    num_workers=opt.n_cpu, worker_init_fn=worker_init_fn
)
total_batches = min(len(dataloader_A), len(dataloader_B))

target_real = torch.ones(opt.batchSize, 1, device=device)
target_fake = torch.zeros(opt.batchSize, 1, device=device)

fake_A_buffer = ReplayBuffer()
fake_B_buffer = ReplayBuffer()

# ==============================
# Training Setup
# ==============================
current_time = datetime.datetime.now().strftime("%Y%m%d%H%M")
training_save = os.path.join(opt.trainoutput, f'dperiodic_denoise_pth_model_{current_time}')
if not os.path.exists(training_save): 
    os.mkdir(training_save)
# ==============================
# Training Loop with Visdom
# ==============================
for epoch in range(opt.epoch, opt.n_epochs):
    dataloader = zip(dataloader_A, dataloader_B)
    epoch_losses = {
        'loss_G': 0, 'loss_G_identity': 0, 'loss_G_GAN': 0,
        'loss_G_cycle': 0, 'loss_D': 0
    }
    num_batches = 0

    for i, (batch_A, batch_B) in enumerate(dataloader):
        real_A = batch_A.to(device)
        real_B = batch_B.to(device)
        # >>>>>>>>>>>>>> DEBUG: Visualize first batch of first epoch on the same plot <<<<<<<<<<<<<<
        # if epoch == opt.epoch and i == 0:
        #     print("🔍 Debug: Inspecting real_A and real_B shapes and stats")
        #     print(f"real_A shape: {real_A.shape}, dtype: {real_A.dtype}")
        #     print(f"real_B shape: {real_B.shape}, dtype: {real_B.dtype}")
        #     print(f"real_A range: [{real_A.min().item():.4f}, {real_A.max().item():.4f}]")
        #     print(f"real_B range: [{real_B.min().item():.4f}, {real_B.max().item():.4f}]")

        #     x = torch.arange(real_A.shape[2])  # Assuming you want to plot along the length dimension
            
        #     # Plot both real_A[0] and real_B[0] on the same graph
        #     viz.line(
        #         X=x,
        #         Y=torch.stack([
        #             real_A[0, 0, :, 0].cpu(),
        #             real_B[0, 0, :, 0].cpu()
        #         ], dim=1),
        #         win='debug_real_AB',
        #         opts=dict(
        #             title='Debug: real_A vs real_B (first sample)',
        #             xlabel='Sample',
        #             ylabel='Value',
        #             legend=['real_A', 'real_B']
        #         )
        #     )
        # <<<<<<<<<<<<<< End Debug >>>>>>>>>>>>>>
        # --- Generators ---
        optimizer_G.zero_grad()
        
        same_B = netG_A2B(real_B)
        loss_identity_B = criterion_identity(same_B, real_B) * 5.0
        same_A = netG_B2A(real_A)
        loss_identity_A = criterion_identity(same_A, real_A) * 5.0

        fake_B = netG_A2B(real_A)
        pred_fake = netD_B(fake_B)
        loss_GAN_A2B = criterion_GAN(pred_fake, target_real)

        fake_A = netG_B2A(real_B)
        pred_fake = netD_A(fake_A)
        loss_GAN_B2A = criterion_GAN(pred_fake, target_real)

        recovered_A = netG_B2A(fake_B)
        loss_cycle_ABA = criterion_cycle(recovered_A, real_A) * 10.0
        recovered_B = netG_A2B(fake_A)
        loss_cycle_BAB = criterion_cycle(recovered_B, real_B) * 10.0

        loss_G = loss_identity_A + loss_identity_B + loss_GAN_A2B + loss_GAN_B2A + loss_cycle_ABA + loss_cycle_BAB
        loss_G.backward()
        optimizer_G.step()

        # --- Discriminator A ---
        optimizer_D_A.zero_grad()
        pred_real = netD_A(real_A)
        loss_D_real = criterion_GAN(pred_real, target_real)
        fake_A_ = fake_A_buffer.push_and_pop(fake_A)
        pred_fake = netD_A(fake_A_.detach())
        loss_D_fake = criterion_GAN(pred_fake, target_fake)
        loss_D_A = (loss_D_real + loss_D_fake) * 0.5
        loss_D_A.backward()
        optimizer_D_A.step()

        # --- Discriminator B ---
        optimizer_D_B.zero_grad()
        pred_real = netD_B(real_B)
        loss_D_real = criterion_GAN(pred_real, target_real)
        fake_B_ = fake_B_buffer.push_and_pop(fake_B)
        pred_fake = netD_B(fake_B_.detach())
        loss_D_fake = criterion_GAN(pred_fake, target_fake)
        loss_D_B = (loss_D_real + loss_D_fake) * 0.5
        loss_D_B.backward()
        optimizer_D_B.step()

        # Accumulate losses
        epoch_losses['loss_G'] += loss_G.item()
        epoch_losses['loss_G_identity'] += (loss_identity_A + loss_identity_B).item()
        epoch_losses['loss_G_GAN'] += (loss_GAN_A2B + loss_GAN_B2A).item()
        epoch_losses['loss_G_cycle'] += (loss_cycle_ABA + loss_cycle_BAB).item()
        epoch_losses['loss_D'] += (loss_D_A + loss_D_B).item()
        num_batches += 1
        
        current_loss_G = loss_G.item()
        current_loss_D = (loss_D_A + loss_D_B).item()
       
        # Update Visdom every N steps (optional)
        
        if i % max(1, len(dataloader_A) // 10) == 0:
            # Plot signals (first sample in batch)
            update = 'replace' if signal_win else None
            with torch.no_grad():
                
                clean_est = real_A[0, 0, :, 0] - fake_B[0, 0, :, 0]  # [512]
                Y_lines = torch.stack([
                        real_A[0, 0, :, 0].cpu(),   
                        real_B[0, 0, :, 0].cpu(),   
                        fake_B[0, 0, :, 0].cpu(),   
                        clean_est.cpu()            
                        ], dim=1)  
    
                signal_win = viz.line(
                    Y=Y_lines,
                    X=torch.arange(opt.size),
                    win=signal_win,
                    update=update,
                    opts=dict(
                        title='Signals (Real A / Real B / Fake B / Clean Estimate)',
                        legend=['Real Noisy (A)', 'Real Noise (B)', 'Predicted Noise (B)', 'Clean = A - B'],
                        xlabel='Sample Index',
                        ylabel='Amplitude',
                showgrid=True
                    ))
        print(f"\r[Epoch {epoch+1}/{opt.n_epochs}] Batch {i+1}/{total_batches} | "
               f"G: {current_loss_G:.4f}, D: {current_loss_D:.4f}", end='', flush=True)
    # Average losses
    for k in epoch_losses:
        epoch_losses[k] /= num_batches
    print()  
    print(f"[Epoch {epoch+1}/{opt.n_epochs}] "
          f"Avg G: {epoch_losses['loss_G']:.4f}, "
          f"Avg D: {epoch_losses['loss_D']:.4f}")
    # Update loss curves
    x = np.array([epoch])
    y = np.array([[epoch_losses['loss_G']], [epoch_losses['loss_D']]])
    loss_win = viz.line(
        Y=y.T,
        X=x,
        win=loss_win,
        update='append' if loss_win else None,
        opts=dict(
            title='Loss Curves',
            legend=['Generator', 'Discriminator'],
            xlabel='Epoch'
        ))
    # Update LR
    lr_scheduler_G.step()
    lr_scheduler_D_A.step()
    lr_scheduler_D_B.step()

    # Save model
    torch.save(netG_A2B.state_dict(), os.path.join(training_save, f'net_deperiodic_denoise_G{epoch+1}.pth'))

    print(f"[Epoch {epoch+1}/{opt.n_epochs}] "
          f"G: {epoch_losses['loss_G']:.4f}, "
          f"D: {epoch_losses['loss_D']:.4f}")
print("Training finished.")